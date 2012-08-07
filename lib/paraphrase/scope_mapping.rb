module Paraphrase
  class ScopeMapping
    # @!attribute [r] keys
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
    # @!attribute [r] whitelist_keys
    #   @return [Array] keys allowed to be nil
    attr_reader :keys, :method_name, :options, :required, :whitelist


    # @param [Symbol] name name of the scope
    # @param [Hash] options options to configure {ScopeMapping ScopeMapping} instance
    # @option options [Symbol, Array<Symbol>] :key param key(s) to extract values from
    # @option options [true] :require lists scope as required
    def initialize(name, options)
      @method_name = name
      @keys = Array(options.delete(:to))

      @required = register_keys(options[:require])
      @whitelist = register_keys(options[:allow_nil])

      if @whitelist.empty? && !@required.empty?
        @whitelist = @keys - @required
      end

      @options = options.freeze
    end


    # Sends {#method_name} to `chain`, extracting arguments from `params`.  If
    # values are missing for any {#keys}, return the `chain` unmodified.
    # If {#required? required}, errors are added to the {Query} instance as
    # well.
    #
    # @param [Query] query {Query} instance applying the scope
    # @param [Hash] params hash of query parameters
    # @param [ActiveRecord::Relation, ActiveRecord::Base] chain current model scope
    # @return [ActiveRecord::Relation]
    def chain(query, params, chain)
      inputs = keys.map do |key|
        input = params[key]

        if input.nil? && ( required.include?(key) || !whitelist.include?(key) )
          query.errors.add(key, 'is required') if required.include?(key)
          break []
        end

        input
      end

      inputs.empty? ? chain : chain.send(method_name, *inputs)
    end

    private

    def register_keys(option)
      option == true ? Array(keys) : Array(option)
    end
  end
end
