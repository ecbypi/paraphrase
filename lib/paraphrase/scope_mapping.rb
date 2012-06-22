module Paraphrase
  class ScopeMapping
    # @!attribute [r] keys
    #   @return [Array<Symbol>] param keys to extract
    #
    # @!attribute [r] name
    #   @return [Symbol] scope method name
    #
    # @!attribute [r] options
    #   @return [Hash] configuration options
    attr_reader :keys, :name, :options

    # @param [Symbol] name name of the scope method
    # @param [Hash] options options to configure {ScopeMapping ScopeMapping} instance
    # @option options [Symbol, Array<Symbol>] :key key(s) to extract from params to send to scope method
    # @option options [true] :required lists a scope as required
    def initialize(name, options)
      @name = name
      @keys = [options.delete(:key)].flatten

      @options = options.freeze
    end

    # Checks if scope is required for query
    def required?
      !options[:required].nil?
    end

    # Send scope method to chain, extracting arguments from params
    #
    # If any arguments are missing for any of the keys, return unmodified
    # ActiveRecord::Relation.
    #
    # If scope is required, add an error to {Query} instance and return
    # relation unmodified.
    #
    # @param [Query] query {Query} instance applying the scope
    # @param [Hash] params hash of query parameters
    # @param [ActiveRecord::Relation, ActiveRecord::Base] chain current model scope
    # @return [ActiveRecord::Relation]
    def chain(query, params, chain)
      inputs = keys.map { |key| params[key] }

      if inputs.include?(nil)
        keys.each do |key|
          query.errors.add(key, 'is required')
        end if required?

        chain
      else
        chain.send(name, *inputs)
      end
    end
  end
end
