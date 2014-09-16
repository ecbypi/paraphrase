# paraphrase

[![Code Climate](https://codeclimate.com/github/ecbypi/paraphrase.png)](https://codeclimate.com/github/ecbypi/paraphrase)
[![Build Status](https://travis-ci.org/ecbypi/paraphrase.png?branch=master)](https://travis-ci.org/ecbypi/paraphrase)

`paraphrase` provides a way to map query params to model scopes and only apply
scopes when the mapped query params are present, removing all the conditional
checks you might perform in your controller to determine if a scope needs to be
applied.

With `paraphrase`, you can also de-clutter your model by removing
context-specific scopes into the query builder.

Take the following example:

```ruby
class PostsController < ActiveRecord::Base
  def index
    @posts = Post.all

    names = params[:names]

    if names && names.delete_if { |name| name.blank? }.present?
      @posts = @posts.published_by(names)
    end

    start_date = Time.zone.parse(params[:start_date])
    end_date = Time.zone.parse(params[:end_date])

    if start_date && end_date
      @posts = @posts.published_within(start_date, end_date)
    end
  end
end

class Post < ActiveRecord::Base
  def self.published_by(names)
    joins(:user).where(users: { name: names })
  end

  def self.published_within(start_date, end_date)
    where(published_at: start_date..end_date)
  end
end
```

As the number of options for the query grows, the `index` method will continue
to accrue with conditional checks and the model will become bloated with that
are might only used in the controller.

By using paraphrase, the controller and model can be simplified to:

```ruby
class PostsController < ActiveRecord::Base
  def index
    @posts = Post.paraphrase(params)
  end
end

class PostQuery < Paraphrase::Query
  map :names, to: :published_by
  map :start_date, :end_date, to: :published_within

  param :start_date do
    Time.zone.parse(params[:start_date]) rescue nil
  end

  param :end_date do
    Time.zone.parse(params[:end_date]) rescue nil
  end

  scope :published_by do |user_names|
    relation.joins(:user).where(users: { name: user_names })
  end
end

class Post < ActiveRecord::Base
  def self.published_within(start_date, end_date)
    where(published_at: start_date..end_date)
  end
end
```

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

Scopes are mapped to param keys using `map`.  You can specify one or more keys.
The scope will only be called if all the keys are present.

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

Post.paraphrase(first_name: 'Jon', last_name: 'Richards', pub_date: '2010-10-01')
  # => SELECT "posts".* FROM "posts"i
  #    WHERE "posts"."first_name" = 'Jon'
  #      AND "posts.last_name" = 'Richards'
  #      AND "posts.published_on" = '2010-10-01'

Post.paraphrase(first_name: 'Jon', pub_date: '2010-10-01')
  # => SELECT "posts".* FROM "posts" WHERE "posts.published_on" = '2010-10-01'
```

### Changing the Model Class Used

By default, the `ActiveRecord` class is determined from the `demodulize`'d name
of the `Paraphrase::Query` sublcass.  For instance, `DeliveryQuery` will use the
`Delivery` model by default.

If the name of the query class does not match this convention, the source can be
specified by setting the `source` class atribute.

```ruby
# app/queries/admin_post_query.rb
class AdminPostQuery < Paraphrase::Query
  self.source = :Post
end
```

### Whitelisting Query Params

If multiple query params are mapped to a scope, but only a subset are required,
use the `:whitelist` option to allow them to be blank. The `:whitelist` option
can be set to `true` to whitelist all keys, an individual key or an array of
keys.

```ruby
class PostQuery < Paraphrase::Query
  map :first_name, :last_name, to: :by_author, whitelist: :last_name
  map :pub_date, to: :pub_date
end

class Post < ActiveRecord::Base
  # `last_name` will be `nil` if not supplied.
  def self.by_author(first_name, last_name)
    query = where(users: { first_name: first_name })

    # Only filter by `:last_name` if supplied
    if last_name
      query = query.where(users: { last_name: last_name })
    end

    query
  end
end

Post.paraphrase(first_name: 'Jon', pub_date: '2010-10-01')
  # => SELECT "posts".* FROM "posts"i
  #    WHERE "posts"."first_name" = 'Jon'
  #      AND "posts.published_on" = '2010-10-01'
```

Whitelisting is also useful for query params that are optional and have a
default, implied value such as with sorting:

```ruby
class PostQuery < Paraphrase::Query
  map :sort, to: :sorted_by, whitelist: true
end

class Post < ActiveRecord::Base
  def self.sorted_by(sort_direction)
    case sort_direction
    when nil, 'newest'
      order(created_at: :desc)
    else
      order(:created_at)
    end
  end
end
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

### Filtering `blank` Values

By default, `paraphrase` will recursively determine if the value of a query
param is `blank?`. This is meant to deal with form submissions, since blank
values are submitted even if the input is not filled in.

For example, if the value is an array containing empty strings, the empty
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

### Pre-processing Values

To pre-process a query param, such as an ISO formatted date, you can use the
`param` class method or re-open the `ParamsFilter` class that is defined when
inheriting from `Paraphrase::Query`. Using the `param` class method defines the
equivalent method on the `ParamsFilter` class.

In the method, you have access to `params` that represents the original,
unprocessed params.

```ruby
class PostQuery < Paraphrase::Query
  map :start_date, :end_date, to: :published_within

  class ParamsFilter < Paraphrase::ParamsFilter
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

Post.parahrase(start_date: '2011-03-21', end_date: '2013-03-25').to_sql
  # => SELECT "posts".* FROM "posts"
       WHERE "posts"."published_at" BETWEEN '2011-03-21' AND '2013-03-25'

# The typo in the `start_date` query param causes `Time.zone.parse` to fail so
# the pre-procssed `start_date` is `nil`. Since not all params are present, the
# scope is not run.
Post.parahrase(start_date: '201-03-21', end_date: '2013-03-25').to_sql
  # => SELECT "posts".* FROM "posts"
```

In the above example, if either `:start_date` or `:end_date` are incorrectly
formatted, the `pubished_within` scope will not be applied since
`Time.zone.parse` will fail and return `nil`.

### Define scopes in the `Query` class

Scopes can be defined in the `Query` class using the `scope` keyword or
re-opening the `Repository` class defined in the `Query` subclass. This helps to
avoid cluttering the model class with scopes that are only used by the query
class.

When defining scopes this way, any `ActiveRecord::Relation` methods should be
called on the `relation` property of the `Repository` instance.

```ruby
class PostQuery < Paraphrase::Query
  map :title, to: :titled
  map :authors, to: :by_users
  map :is_published, to: :published

  scope :by_users do |authors|
    relation.joins(:user).where(users: { name: authors })
  end

  class Repository < Paraphrase::Repository
    def titled(post_title)
      relation.where(title: post_title)
    end
  end
end

class Post < ActiveRecord::Base
end

Post.paraphrase(authors: ['Robert', 'Susie'], title: 'Sunshine').to_sql
# => SELECT "posts".* FROM "posts"
#    INNER JOIN "users" ON "users"."id" = "posts"."user_id"
#    WHERE "users"."name" IN ('Robert', 'Susie')
```

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
