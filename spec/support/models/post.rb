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
