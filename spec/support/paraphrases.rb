class User
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def self.name_like(name)
    [self.new(name)]
  end
end

class UserParaphrase < Paraphrase::Query
  paraphrases :User

  key :name => :name_like
end
