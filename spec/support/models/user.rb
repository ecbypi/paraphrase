class User < ActiveRecord::Base
  extend Paraphrase::Syntax

  has_many :accounts
  has_many :posts
end
