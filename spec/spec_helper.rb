if ENV.key?('CODECLIMATE_REPO_TOKEN')
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'rspec'
require 'pry'
require 'paraphrase'
require 'active_record'

RSpec.configure do |config|
  config.order = 'random'
end

I18n.enforce_available_locales = false

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :users, force: true do
  end

  create_table :posts, force: true do |t|
    t.string :title
    t.boolean :published
    t.datetime :published_at
    t.references :user
  end

  create_table :accounts, force: true do |t|
    t.string :name
    t.references :user
  end
end

ActiveRecord::Base.extend Paraphrase::Syntax

class User < ActiveRecord::Base
  has_many :accounts
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user

  scope :titled, ->(title) { where(title: title) }

  def self.published
    where(published: true)
  end

  def self.by_users(names)
    joins(:user).where(users: { name: names })
  end

  def self.published_between(start_date, end_date)
    where(published_at: start_date..end_date)
  end
end

class Account < ActiveRecord::Base
  belongs_to :user

  def self.named(name)
    where(name: name)
  end
end
