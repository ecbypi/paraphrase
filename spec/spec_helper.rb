require 'rspec'
require 'paraphrase'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false

  ActiveRecord::Schema.define do
    create_table(:users, :force => true) {}
    create_table(:accounts, :force => true) {}
    create_table(:foobars, :force => true) {}
  end
end

class Foobar < ActiveRecord::Base
end

class Account < ActiveRecord::Base
  extend Paraphrase::Syntax
end

class User < ActiveRecord::Base
end

class UserSearch < Paraphrase::Query
end
