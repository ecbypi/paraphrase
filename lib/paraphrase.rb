module Paraphrase
  class DuplicateMappingError < StandardError
    def initialize(scope_name)
      @scope_name = scope_name
    end

    def message
      "scope :#{@scope_name} has already been mapped"
    end
  end

  class NoQueryDefined < StandardError
    def initialize(query_name)
      @query_name = query_name
    end

    def message
      "No query class found. #{@query_name} must be defined as a subclass of `Paraphrase::Query`"
    end
  end

  class UndefinedKeyError < StandardError
    def initialize(invalid_key, keys)
      @invalid_key, @keys = invalid_key, keys
    end

    def message
      "key `#{@invalid_key}' is not a valid key for this query; valid keys are: #{@keys.join(', ')}"
    end
  end
end

require 'paraphrase/query'
require 'paraphrase/rails' if defined?(Rails)
