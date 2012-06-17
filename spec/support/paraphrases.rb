class User
  attr_accessor :name, :title

  def initialize(name)
    @name = name
  end

  def self.name_like(*names)
    self
  end

  def self.title_like(title)
    self
  end

  def self.to_a
    []
  end
end

class UserSearch < Paraphrase::Query
  paraphrases :User

  scope :name_like, :key => [:first_name, :last_name], :required => true, :preprocess => lambda { |first, last| first + ' ' + last }
  scope :title_like, :key => :title
end
