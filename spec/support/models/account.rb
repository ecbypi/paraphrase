class Account < ActiveRecord::Base
  extend Paraphrase::Syntax::Base
  belongs_to :user

  def self.title_like(*args)
    ActiveRecord::VERSION::MAJOR > 3 ?  all : scoped
  end

  def self.name_like(*args)
    ActiveRecord::VERSION::MAJOR > 3 ?  all : scoped
  end
end
