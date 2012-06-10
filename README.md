# paraphrase

paraphrase is a DSL to map one or multiple request params to model scopes.
Through `ActiveModel::Validations` you can validate inputs using the provided
validators or your own custom ones.

paraphrase was designed and geared towards building a query-based public API
where you may want to require certain parameters to prevent consumers from
scraping all your information or to mitigate the possibility of large,
performance-intensive data-dumps.

## Installation

Via a gemfile:

```ruby
gem 'guise'
```

```
$ bundle
```

Or manually:

```
$ gem install guise
```

## Usage

paraphrase aims to be as flexible as possible for your needs. You can use it:

* From within an `ActiveRecord` subclass:
```ruby
class Post < ActiveRecord::Base
  register_mapping do
    key :author, :to => :by_user
  end

  def self.by_user(author_name)
    joins(:user).where(:user => { :name => author_name })
  end
end
```

* In an initializer to register multiple mappings in one place:
```ruby
# config/initializers/paraphrase.rb
Paraphrase.confirgure do |mappings|
  mappings.register :post do
    # ...
  end
end
```

* By creating a subclass of `Paraphrase::Query`:
```ruby
# app/paraphrases/post_paraphrase.rb
class PostParaphrase < Paraphrase::Query
  paraphrases :post

  key :author, :to => :by_user
end
```

Then in a controller you can use it in any of the following ways:

```ruby
class PostsController < ApplicationController
  respond_to :html, :json

  def index
    # Filters out relevant attributes
    # and applies scopes relevant to each
    # parameter
    @posts = Post.paraphrase(params)

    # Or
    # @posts = Paraphrase.query(:post, params)

    # If you created a subclass
    # @posts = PostParaphrase.new(params)

    respond_with(@posts)
  end
end
```

In any of these contexts, the `key` method registers attribute(s) to extract
from the params supplied and what scope to pass them to. If you pass in a
block, you can preprocess the value.

```ruby
class Post < ActiveRecord::Base
  register_mapping do
    key :posted_on, :to => :by_user do |name|
      name.split
    end
  end

  def self.by_user(first_name, last_name)
    joins(:user).where(:user => { :first_name => first_name, :last_name => last_name })
  end
end
```

You can pass in multiple keys too if your scope requires multiple values.

```ruby
class Post < ActiveRecord::Base
  register_mapping do
    key [:first_name, :last_name], :to => :by_user
  end

  def self.by_user(first_name, last_name)
    joins(:user).where(:user => { :first_name => first_name, :last_name => last_name })
  end
end
```

You can declare `ActiveModel::Validations` in the mapping block as well.

```ruby
class Post < ActiveRecord::Base
  register_mapping do
    key [:first_name, :last_name], :to => :by_user

    validates :first_name, :last_name, :presence => true
  end
end
```
