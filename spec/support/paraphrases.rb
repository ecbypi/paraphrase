class User
  attr_accessor :name, :title

  def initialize(name)
    @name = name
  end

  def self.name_like(name)
    self
  end

  def self.title_like(title)
    self
  end
end

class UserMapping < Paraphrase::MappingSet
  paraphrases :User

  key :name => :name_like, :required => true
  key :title => :title_like
end
