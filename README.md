# paraphrase

paraphrase provides a way to map one or multiple request params to model
scopes.

paraphrase is geared towards building a query-based public API where you may
want to require certain parameters to prevent consumers from scraping all your
information or to mitigate large, performance-intensive database queries.

## Installation

Via a gemfile:

```ruby
gem 'paraphrase'
```

```
$ bundle
```

Or manually:

```
$ gem install paraphrase
```

## Usage

### Setup

paraphrase aims to be as flexible as possible. `Query` classes can be created
in the following ways:

* Calling `register_mapping` in an `ActiveRecord::Base` subclass:

```ruby
class Post < ActiveRecord::Base
  register_mapping do
    scope :by_user, :key => :author
  end

  def self.by_user(author_name)
    joins(:user).where(:user => { :name => author_name })
  end
end
```

* A configuration block through `Paraphrase.configure`:

```ruby
# config/initializers/paraphrase.rb

Paraphrase.configure do |mappings|
  mappings.register :post do
    paraphrases Post
    scope :by_user, :key => :author
  end
end
```

* Subclassing `Paraphrase::Query`:

```ruby
class PostQuery < Paraphrase::Query
  paraphrases Post

  scope :by_user, :key => :author
end
```

### Making a Query

In your controller, call the relevant method based on your setup:

```ruby
class PostsController < ApplicationController
  respond_to :html, :json

  def index
    @posts = Post.paraphrase(params)

    # Or
    # @posts = Paraphrase.query(:post, params)

    # If you created a subclass
    # @posts = PostQuery.new(params)

    respond_with(@posts)
  end
end
```

### Configuring Scopes

In any of these contexts, the `:key` option of the `:scope` method registers
attribute(s) to extract from the params supplied and what method to pass them
to. An array of keys can be supplied to pass multiple arguments to a scope.

```ruby
class Post < ActiveRecord::Base
  register_mapping do
    scope :by_user, :key => [:first_name, :last_name]
    scope :published_on, :key => :pub_date
  end

  def self.by_user(first_name, last_name)
    joins(:user).where(:user => { :first_name => first_name, :last_name => last_name })
  end

  def self.published_on(pub_date)
    where(:published_on => pub_date)
  end
end
```

If a scope is required for a query to be considered valid, pass `:require =>
true` or `:require => [:array, :of, :keys]` to the options. If any values are
missing for the scope, an empty result set will be returned. If a key is an
array of attributes, you can specify a subset of the key to be required. The
rest of the attributes will be allowed to be nil.

```ruby
class Post < ActiveRecord::Base
  register_mapping do
    scope :published_on, :key => :pub_date, :require => true
    scope :by_author, :key => [:first_name, :last_name], :require => :last_name # requires :last_name, whitelists :first_name
  end
end

Post.paraphrase.results # => []
```

Alternatively, a scope can be whitelisted allowing nil values to be passed to the scope.

```ruby
class Post < ActiveRecord::Base
  register_mapping do
    scope :by_author, :key => [:first_name, :last_name], :allow_nil => :first_name # :first_name does not need to be specified
  end
end
```

## Plans / Thoughts for the Future

* Support nested hashes in params.

```ruby
scope :by_author, :key => { :author => [:first_name, :last_name] }
```
