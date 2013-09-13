# paraphrase

[![Code Climate](https://codeclimate.com/github/ecbypi/paraphrase.png)](https://codeclimate.com/github/ecbypi/paraphrase)

Paraphrase provides a way to map request params to model scopes and apply those
scopes based on what params are supplied.  It adds a `.paraphrase` method to
your model classes and `ActiveRecord::Relation` instances that, after setting
up your scope => key mappings, will apply scopes if the parameters mapped to a
scope are present. You can also require and whitelist certain parameters to
provide more flexibility on complex scopes.

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

Create a subclass of `Paraphrase::Query` or call `register_mapping` from within
your model to setup mappings.

```ruby
# app/queries/post_query.rb
class PostQuery < Paraphrase::Query
  map :by_user, :to => :author
end

# or

# app/models/post.rb
class Post < ActiveRecord::Base
  belongs_to :user

  register_mapping do
    map :by_user, :to => :author
  end

  def self.by_user(author)
    where(:user => { :name => author })
  end
end
```

In the controller, call `.paraphrase` on your model, passing in the hash
containing the query params. This will filter out the registered parameters,
calling the scopes whose inputs are supplied. If inputs for a scope are
missing, it is skipped.

```ruby
class PostsController < ApplicationController
  respond_to :html, :json

  def index
    @posts = Post.paraphrase(params)
    respond_with(@posts)
  end
end
```

You can chain queries on an `ActiveRecord::Relation`. This avoids adding scopes
that replicate the functionality of an association like
`Post.for_user(user_id)` or allows you to build a default scope.

```ruby
class PostsController < ApplicationController
  respond_to :html, :json

  # GET /users/:id/posts
  def index
    @user = User.find(params[:user_id])

    # This will scope the query to posts where `posts`.`user_id` = `users`.`id`
    @posts = @users.posts.paraphrase(params)

    # Or you can build at a different point in a scope chain
    # @posts = @user.posts.published.paraphrase(params)

    respond_with(@posts)
  end
end
```

### Query Class DSL

Scopes are mapped to param keys using the `map` class method provided by
`Paraphrase::Query`.  You can specify one or more keys.

```ruby
class PostQuery < Paraphrase::Query
  map :by_user, :to => [:first_name, :last_name]
  map :published_on, :to => :pub_date
end

class Post < ActiveRecord::Base
  def self.by_user(first_name, last_name)
    joins(:user).where(:user => { :first_name => first_name, :last_name => last_name })
  end

  def self.published_on(pub_date)
    where(:published_on => pub_date)
  end
end
```

If a scope is required for a query to be considered valid, add `:require =>
true` or `:require => [:array, :of, :keys]` in the options. If any values are
missing, an empty result set will be returned. If the base key is an
array, you can specify a subset of the key to be required. In this case, the rest of the
attributes will be whitelisted.

```ruby
class Post < ActiveRecord::Base
  register_mapping do
    # requires :pub_date to be supplied
    map :published_on, :to => :pub_date, :require => true

    # requires only :last_name to be passed in, :first_name can be nil
    map :by_author, :to => [:first_name, :last_name], :require => :last_name
  end

  def self.by_author(first_name, last_name)
    query = where(:user => { :last_name => last_name })

    if first_name
      query.where(:user => { :first_name => first_name })
    end

    query
  end
end

Post.paraphrase({}).results # => []
```

Alternatively, a scope or a subset of its keys can be whitelisted allowing nil
values to be passed to the scope. This is intended for scopes that alter their
behavior conditionally on a parameter being present. You should whitelist
inputs if you still want other scopes to be applied as requiring them will halt
execution of scopes and return an empty result set.

```ruby
class Post < ActiveRecord::Base
  register_mapping do
    # :first_name can be nil, :last_name is still required to apply the scope
    map :by_author, :to => [:first_name, :last_name], :whitelist => :first_name
  end
end
```

### Boolean Scopes

Some scopes take the form of a switch, filtering records based on a boolean
column. It doesn't make sense for these methods to take any arguments and
requirng them to would couple them to `Paraphrase::Query` classes in a
complicated way.

Paraphrase will detect if the method specified takes no arguments.  If not, it
will call the method without any arguments, assuming the inputs are present and
valid.

```ruby
class Post < ActiveRecord::Base
  register_mapping do
    map :published, :to => :published
  end

  # If the params supplied include a non-nil value for :published,
  # this method will be called.
  def self.published
    where('published_at IS NOT NULL')
  end
end
```

### ActiveSupport::Notifications

You can subscribe to notifications when the query is built.

```ruby
ActiveSupport::Notifications.subscribe('query.paraphrase') do |name, start, end, id, payload|
  # ...
end
```

`payload` contains:

* `:params`: the params filtered
* `:source_name`: name of the class being queried
* `:source`: `ActiveRecord::Relation` being used as the base for the query
