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
    create_table(:accounts, :force => true) {}
  end
end

class Account < ActiveRecord::Base
  extend Paraphrase::Syntax
end

class AccountSearch < Paraphrase::Query
end
