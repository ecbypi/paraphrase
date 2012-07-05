module Paraphrase
  class ScopeMapping
    # @!attribute [r] param_keys
    #   @return [Array<Symbol>] param keys to extract
    #
    # @!attribute [r] method_name
    #   @return [Symbol] scope method name
    #
    # @!attribute [r] options
    #   @return [Hash] configuration options
    attr_reader :param_keys, :method_name, :options


    # @param [Symbol] name name of the scope
    # @param [Hash] options options to configure {ScopeMapping ScopeMapping} instance
    # @option options [Symbol, Array<Symbol>] :key param key(s) to extract values from
    # @option options [true] :require lists scope as required
    def initialize(name, options)
      @method_name = name
      @param_keys = Array(options.delete(:key))

      @options = options.freeze
    end


    # True if scope is required for query
    def required?
      !options[:require].nil?
    end


    # True if nil param values can be passed to scope
    def whitelisted?
      !options[:allow_nil].nil?
    end


    # Sends {#method_name} to `chain`, extracting arguments from `params`.  If
    # values are missing for any {#param_keys}, return the `chain` unmodified.
    # If {#required? required}, errors are added to the {Query} instance as
    # well.
    #
    # @param [Query] query {Query} instance applying the scope
    # @param [Hash] params hash of query parameters
    # @param [ActiveRecord::Relation, ActiveRecord::Base] chain current model scope
    # @return [ActiveRecord::Relation]
    def chain(query, params, chain)
      inputs = param_keys.map do |key|
        input = params[key]

        if input.nil? && ( required? || !whitelisted? )
          query.errors.add(key, 'is required') if required?
          break []
        end

        input
      end

      inputs.empty? ? chain : chain.send(method_name, *inputs)
    end
  end
end
