module Paraphrase
  class ScopeKey
    attr_reader :name, :scope, :options

    def initialize(mapping, options = {})
      @name, @scope = mapping.to_a.first
      @options = options.freeze
    end

    alias :param_key :name
  end
end
