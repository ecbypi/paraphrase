require 'active_support/core_ext/object/blank'
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

    def chain(params, relation)
      if required_keys.all? { |key| params[key] }
        arity = relation.klass.method(name).arity

        if arity == 0
          relation.send(name)
        else
          values = keys.map { |key| params[key] }
          relation.send(name, *values)
        end
      else
        relation
      end
    end
  end
end
