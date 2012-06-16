module Paraphrase
  class ScopeKey
    attr_reader :param_keys, :scope, :options

    def initialize(options)
      mapping = options.first
      @param_keys = [mapping.first].flatten
      @scope = mapping.last

      options.delete(mapping.first)
      @options = options.freeze
    end

    def required?
      !options[:required].nil?
    end
  end
end
