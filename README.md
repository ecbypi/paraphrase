# paraphrase

[![Code Climate](https://codeclimate.com/github/ecbypi/paraphrase.png)](https://codeclimate.com/github/ecbypi/paraphrase)

Paraphrase provides a way to map query params to model scopes and
only apply scopes when the mapped query params are present.

## Installation

Via a `Gemfile`:

```
gem 'paraphrase'
```

Or manually:

```
$ gem install paraphrase
```

## Usage

Subclass `Paraphrase::Query` and use `map` to define what query params should
be applied to which scopes.

```ruby
# app/queries/post_query.rb
class PostQuery < Paraphrase::Query
  map :author, to: :by_user
  map :start_date, :end_date, to: :published_within

  def by_user
    source.where(name: author)
  end

  def start_date
    Time.zone.parse(params[:start_date])
  end
end
```

By default, the `ActiveRecord` class is introspected from the demodulized class
name of the `Paraphrase::Query` sublcass.  If the name of the query class is
not `<model>Query`, the source can be manually specified by passing a string or
symbol to the `source` method.

```ruby
# app/queries/admin/post_query.rb
class Admin::PostQuery < Paraphrase::Query
  # this will correctly find the `Post` model
end

# app/queries/admin_post_query.rb
class AdminPostQuery < Paraphrase::Query
  # This needs the source specific since it will look for an `AdminPost` model.
  source :Post
end
```

In the controller, call `.paraphrase` on your model, passing a hash of query
params.  This will filter out the registered query params, calling the scopes
whose inputs are supplied. If a query param for a scope is missing or empty,
the scope is skipped.

```ruby
class PostsController < ApplicationController
  respond_to :html, :json

  def index
    # Will filter out keys such as `:action` and `:controller`
    @posts = Post.paraphrase(params)
    respond_with(@posts)
  end
end
```

You can chain queries on an `ActiveRecord::Relation`. This avoids adding scopes
that replicate the functionality of an association like
`Post.for_user(user_id)` or allow you to build a default scope.

```ruby
class PostsController < ApplicationController
  respond_to :html, :json

  # GET /users/:id/posts
  def index
    @user = User.find(params[:user_id])

    # This will scope the query to posts where `posts`.`user_id` = `users`.`id`
    @posts = @users.posts.paraphrase(params[:q])

    # Or you can build at a different point in a scope chain
    # @posts = @user.posts.published.paraphrase(params[:q])
    #
    # Order is independent too
    # @posts = @user.posts.paraphrase(params[:q]).published

    respond_with(@posts)
  end
end
```

### Query Class DSL

Scopes are mapped to param keys using the `map` class method provided by
`Paraphrase::Query`.  You can specify one or more keys.

```ruby
class PostQuery < Paraphrase::Query
  map :first_name, :last_name, to: :by_user
  map :pub_date, to: :pub_date
end

class Post < ActiveRecord::Base
  def self.by_user(first_name, last_name)
    joins(:user).where(user: { first_name: first_name, last_name: last_name })
  end

  def self.published_on(pub_date)
    where(published_on: pub_date)
  end
end
```

If a scope is required for a query to be considered valid, add `require: true`
or `require: [:array, :of, :keys]` in the options. If any values are missing,
an empty result set will be returned. If multiple keys are mapped to the scope,
you can specify a subset of the keys to be required. In this case, the rest of
the attributes will be whitelisted.

```ruby
class PostQuery < Paraphrase::Query
  # requires :pub_date to be supplied
  map :pub_date, to: :published_on, require: true

  # requires only :last_name to be passed in, :first_name can be nil
  map :first_name, :last_name, to: :by_author, require: :last_name
end

class Post < ActiveRecord::Base
  def self.by_author(first_name, last_name)
    query = where(user: { last_name: last_name })

    if first_name
      query.where(user: { first_name: first_name })
    end

    query
  end
end

Post.paraphrase.to_a # => []
Post.paraphrase(last_name: 'Smith').to_a # => [<#Post>]
Post.paraphrase(first_name: 'John').to_a # => []
```

Alternatively, a scope or a subset of its keys can be whitelisted allowing the
key to not be specified or blank. This is intended for scopes that alter their
behavior conditionally on a parameter being present. You should whitelist
inputs if you still want other scopes to be applied as requiring them will halt
execution of scopes and return an empty result set.

```ruby
class PostQuery < Paraphrase::Query
  # :first_name can be nil, :last_name is still required to apply the scope
  map :by_author, to: [:first_name, :last_name], whitelist: :first_name
end
```

### Boolean Scopes

Some filter records based on a boolean column. It doesn't make sense for these
methods to take any arguments.

Paraphrase will detect if the method specified takes no arguments.  If not, it
will call the method without any arguments, assuming the inputs are present and
valid.

```ruby
class PostQuery < Paraphrase::Query
  map :published, to: :published
end

class Post < ActiveRecord::Base
  # If the params supplied include a non-empty value for :published, this
  # method will be called.
  def self.published
    where('published_at IS NOT NULL')
  end
end
```

### Pre-processing Query Params

By default, for each query param specified that maps to a model scope, a method
is defined on the query class that fetches the value for that key. This is used
internally to determine if model scopes need to be applied. To pre-process a
query param, such as an ISO formatted date, override the method in the query
class.

```ruby
class PostQuery < Paraphrase::Query
  map :start_date, :end_date, to: :published_within

  def start_date
    @start_date ||= Time.zone.parse(params[:start_date]) rescue nil
  end

  def end_date
    @start_date ||= Time.zone.parse(params[:end_date]) rescue nil
  end
end

class Post < ActiveRecord::Base
  def self.published_within(start_date, end_date)
    where(published_at: start_date..end_date)
  end
end

Post.parahrase(start_date: '201-03-21', end_date: '2013-03-25') # => will not apply `published_within`.
```

In the above example, if either `:start_date` or `:end_date` are incorrectly
formatted, the `pubished_within` scope will not be applied because the values
are `nil`.

### Using with `FormBuilder`

The `Paraphrase::Query` class implements the `ActiveModel` API required for use with form builders.

```ruby
class PostQuery < Paraphrase::Query
  map :author, to: :by_user
end

class PostsController < ApplicationController
  def index
    @query = PostQuery.new(params[:q])
  end
end
```

```erb
<%= form_for @query, url: posts_url do |f| %>
  <%= f.label :author %>
  <%= f.select :author, User.authors %>
<% end %>
```

### Scrubbing Arrays

`Paraphrase::Query` will intelligently determine if the value of the query
param is empty. If the value is an array containing empty strings, the empty
strings will be removed before being passed to the scope. If the array is empty
after removing empty strings, the scope will not be called since an empty array
is considered a blank value.

### ActiveSupport::Notifications

You can subscribe to notifications when the query is applied.

```ruby
ActiveSupport::Notifications.subscribe('query.paraphrase') do |name, start, end, id, payload|
  # ...
end
```

`payload` contains:

* `:params`: the params filtered
* `:source_name`: name of the class being queried
* `:source`: `ActiveRecord::Relation` being used as the base for the query
