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

    def values(params)
      values = param_keys.map { |key| params[key] }

      if options[:preprocess]
        [options[:preprocess].call(*values)]
      else
        values
      end
    end
  end
end
