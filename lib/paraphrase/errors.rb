module Paraphrase
  class DuplicateMappingError < StandardError
    def initialize(scope_name)
      @message = "scope :#{scope_name} has already been mapped"
    end
  end

  class NoQueryDefined < StandardError
    def initialize(query_name)
      @message = "No query class found. #{query_name} must be defined as a subclass of `Paraphrase::Query`"
    end
  end
end
