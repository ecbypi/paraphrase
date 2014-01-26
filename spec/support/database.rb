require 'active_record'

ActiveRecord::Relation.send(:include, Paraphrase::Syntax::Relation)

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :users, :force => true do
  end

  create_table :accounts, :force => true do |t|
    t.references :user
  end
end

class User < ActiveRecord::Base
  has_many :accounts
end

class Account < ActiveRecord::Base
  extend Paraphrase::Syntax::Base
  belongs_to :user

  def self.title_like(*args)
    ActiveRecord::VERSION::MAJOR > 3 ?  all : scoped
  end

  def self.name_like(*args)
    ActiveRecord::VERSION::MAJOR > 3 ?  all : scoped
  end
end

class AccountQuery < Paraphrase::Query
end
