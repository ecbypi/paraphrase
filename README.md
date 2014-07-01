# paraphrase

[![Code Climate](https://codeclimate.com/github/ecbypi/paraphrase.png)](https://codeclimate.com/github/ecbypi/paraphrase)
[![Build Status](https://travis-ci.org/ecbypi/paraphrase.png?branch=master)](https://travis-ci.org/ecbypi/paraphrase)

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
end
```

By default, the `ActiveRecord` class is introspected from the demodulized class
name of the `Paraphrase::Query` sublcass.  If the name of the query class is
not `<model>Query`, the source can be manually specified by passing a string or
symbol to the `source` method.

```ruby
# app/queries/admin_post_query.rb
class AdminPostQuery < Paraphrase::Query
  # This needs the source specific since it will look for an `AdminPost` model.
  self.source = :Post
end
```

To build the query, call `.paraphrase` on your model.  Only scopes whose keys are all
provided will be applied.

```ruby
# Based on the example `PostQuery` above, this will only apply `Post.by_user`
# and skip `Post.published_within` since `:end_date` is missing.
Post.paraphrase(author: 'Jim')
```

All unregistered keys are filered out of the params that are passed to `.paraphrase`.

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

`Paraphrase::Query` will recursively determine if the value of the query
param is empty. If the value is an array containing empty strings, the empty
strings will be removed before being passed to the scope. If the array is empty
after removing empty strings, the scope will not be called since an empty array
is considered a blank value.

```ruby
class UserQuery < Paraphrase::Query
  map :names, to: :with_name
end

class User < ActiveRecord::Base
  def self.with_name(names)
    where(name: names)
  end
end

User.paraphrase(names: ['', 'Jim']).to_sql
# => SELECT "users".* FROM "users" WHERE "users"."name" IN ['Jim']

User.paraphrase(names: ['', '']).to_sql
# => SELECT "users".* FROM "users"
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

Scopes are mapped to param keys using `map`.  You can specify one or more keys.

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

If multiple query params are mapped to a scope, but only a subset are required,
use the `:whitelist` option to allow them to be blank. The `:whitelist`
option can be set to `true`, an individual key or an array of keys.

```ruby
class PostQuery < Paraphrase::Query
  # requires only :last_name to be passed in, :first_name can be nil
  map :first_name, :last_name, to: :by_author, whitelist: :last_name
end

class Post < ActiveRecord::Base
  def self.by_author(first_name, last_name)
    query = where(user: { first_name: first_name })

    if last_name
      query = query.where(user: { last_name: last_name })
    end

    query
  end
end

Post.paraphrase(first_name: 'John').to_sql
  # => SELECT "posts".* FROM "posts" WHERE "posts"."first_name" = 'John'

Post.paraphrase(first_name: 'John', last_name: 'Smith').to_sql
  # => SELECT "posts".* FROM "posts" WHERE "posts"."first_name" = 'John' AND "posts"."last_name" = 'Smith'
```

### Boolean Scopes

For scopes that filter records based on a boolean column, it doesn't make to
force the scope to take an argument.

If the mapped query params are present and a scope takes no arguments,
`paraphrase` will not attempt to pass those values to the query.

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

Post.paraphrase(published: '1').to_sql
  # => SELECT "posts".* FROM "posts" WHERE "posts"."published" = 't'
```

### Pre-processing Query Params

To pre-process a query param, such as an ISO formatted date, you can either use
the `param` class method or re-open the `ParamsFilter` class that is defined
when inheriting from `Paraphrase::Query`. Using the `param` class method
defines the equivalent method on the `ParamsFilter` class.

In the method, you have access to the `params` attribute that represents the
original, unprocessed params.

```ruby
class PostQuery < Paraphrase::Query
  map :start_date, :end_date, to: :published_within

  class ParamsFilter
    def start_date
      Time.zone.parse(params[:start_date]) rescue nil
    end
  end

  param :end_date do
    Time.zone.parse(params[:end_date]) rescue nil
  end
end

class Post < ActiveRecord::Base
  def self.published_within(start_date, end_date)
    where(published_at: start_date..end_date)
  end
end

Post.parahrase(start_date: '201-03-21', end_date: '2013-03-25').to_sql
  # => SELECT "posts".* FROM "posts"
```

In the above example, if either `:start_date` or `:end_date` are incorrectly
formatted, the `pubished_within` scope will not be applied because the values
are will be `nil`.

### Using with `FormBuilder`

The `Paraphrase::Query` class implements the `ActiveModel` API required for use
with form builders.

```ruby
class PostQuery < Paraphrase::Query
  map :author, to: :by_user
end

class PostsController < ApplicationController
  def index
    @query = PostQuery.new(params[:q])
    @posts = query.result
  end
end
```

```erb
<%= form_for @query, url: posts_url, method: :get do |f| %>
  <%= f.label :author %>
  <%= f.select :author, options_from_collection_for_select(User.authors, :id, :name) %>
<% end %>

<% @posts.each do |post| %>
  ...
<% end %>
```

## Contributing

Contributions welcome. Be sure to include tests for any regressions or features.

1. Fork it ( http://github.com/[my-github-username]/paraphrase/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature with tests'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
