require 'active_support/core_ext/array/wrap'

module Paraphrase
  # @api private
  class Mapping
    attr_reader :keys, :name, :required_keys

    def initialize(keys, options)
      @keys = keys
      @name = options[:to]

      @required_keys = if options[:whitelist] == true
        []
      else
        @keys - Array.wrap(options[:whitelist])
      end
    end

    def satisfied?(params)
      required_keys.all? { |key| params[key] }
    end

    def values(params)
      keys.map { |key| params[key] }
    end
  end
end
