require 'rspec'
require 'pry'
require 'paraphrase'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)


RSpec.configure do |config|
  config.before :suite do
    ActiveRecord::Relation.send(:include, Paraphrase::Syntax)

    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :users, :force => true do
      end

      create_table :posts, :force => true do |t|
        t.string :title
        t.boolean :published
        t.datetime :published_at
        t.references :user
      end

      create_table :accounts, :force => true do |t|
        t.string :name
        t.references :user
      end
    end
  end
end
