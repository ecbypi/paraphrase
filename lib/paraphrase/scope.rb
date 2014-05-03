require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/wrap'

module Paraphrase
  class Scope
    # @!attribute [r] keys
    #   @return [Array<Symbol>] param keys to extract
    #
    # @!attribute [r] name
    #   @return [Symbol] scope name
    #
    # @!attribute [r] required_keys
    #   @return [Array<Symbol>] keys required for query
    attr_reader :keys, :name, :required_keys

    # @param [Symbol] name name of the scope
    # @param [Hash] options options to configure {Scope Scope} instance
    # @option options [Symbol, Array<Symbol>] :to param key(s) to extract values from
    # @option options [true, Symbol, Array<Symbol>] :require lists all or a
    #   subset of param keys as required
    def initialize(keys, options)
      @keys = keys
      @name = options[:to]

      @required_keys = if options[:whitelist] == true
        []
      else
        @keys - Array.wrap(options[:whitelist])
      end
    end

    # Sends {#name} to `relation` if `query` has a value for all the
    # {Scope#required_keys}. Passes through `relation` if any
    # values are missing.  Detects if the scope takes no arguments to determine
    # if values should be passed to the scope.
    #
    # @param [Paraphrase::Query] query instance of {Query} class
    # @param [ActiveRecord::Relation] relation scope chain
    # @return [ActiveRecord::Relation]
    def chain(params, relation)
      if required_keys.all? { |key| params[key] }
        klass = relation.respond_to?(:klass) ? relation.klass : relation
        arity = klass.method(name).arity

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
