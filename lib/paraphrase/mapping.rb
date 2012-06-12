module Paraphrase
  class Mapping
    attr_reader :param_key, :scope

    def initialize(mapping, options)
      @param_key, @scope = mapping.to_a.first
      @options = options.freeze
    end
  end
end
