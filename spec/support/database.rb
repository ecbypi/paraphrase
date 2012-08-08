require 'active_record'

ActiveRecord::Relation.send(:include, Paraphrase::RelationMethods)

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false

  ActiveRecord::Schema.define do
    create_table :users, :force => true do
    end

    create_table :accounts, :force => true do |t|
      t.references :user
    end
  end
end

class User < ActiveRecord::Base
  has_many :accounts
end

class Account < ActiveRecord::Base
  extend Paraphrase::Syntax
  belongs_to :user

  def self.name_like(*args)
    current_scope
  end
end
