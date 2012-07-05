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
    #
    # @!attribute [r] required_keys
    #   @return [Array] keys required for query
    #
    # @!attribute [r] whitelisted_keys
    #   @return [Array] keys allowed to be nil
    attr_reader :param_keys, :method_name, :options, :required_keys, :whitelisted_keys


    # @param [Symbol] name name of the scope
    # @param [Hash] options options to configure {ScopeMapping ScopeMapping} instance
    # @option options [Symbol, Array<Symbol>] :key param key(s) to extract values from
    # @option options [true] :require lists scope as required
    def initialize(name, options)
      @method_name = name
      @param_keys = Array(options.delete(:key))

      @required_keys = register_keys(options[:require])
      @whitelisted_keys = register_keys(options[:allow_nil])

      if @whitelisted_keys.empty? && !@required_keys.empty?
        @whitelisted_keys = @param_keys - @required_keys
      end

      @options = options.freeze
    end


    # True if scope is required for query
    def required?(key)
      required_keys.include?(key)
    end


    # True if nil param values can be passed to scope
    def whitelisted?(key)
      whitelisted_keys.include?(key)
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

        if input.nil? && ( required?(key) || !whitelisted?(key) )
          query.errors.add(key, 'is required') if required?(key)
          break []
        end

        input
      end

      inputs.empty? ? chain : chain.send(method_name, *inputs)
    end

    private

    def register_keys(option)
      option == true ? Array(param_keys) : Array(option)
    end
  end
end
