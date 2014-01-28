class Account < ActiveRecord::Base
  extend Paraphrase::Syntax

  belongs_to :user

  def self.named(name)
    where(name: name)
  end
end
