class Post < ActiveRecord::Base
  belongs_to :user

  scope :titled, ->(title) { where(title: title) }

  def self.published
    where(published: true)
  end
end
