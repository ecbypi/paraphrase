module Paraphrase
  class ScopeMapping
    # @!attribute [r] keys
    #   @return [Array<Symbol>] param keys to extract
    #
    # @!attribute [r] method_name
    #   @return [Symbol] scope method name
    #
    # @!attribute [r] required_keys
    #   @return [Array] keys required for query
    #
    # @!attribute [r] whitelist_keys
    #   @return [Array] keys allowed to be nil
    attr_reader :keys, :method_name, :required, :whitelist

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

      if (whitelist & required).any?
        raise ArgumentError, "cannot whitelist and require the same keys"
      end
    end

    # Sends {#method_name} to `chain`, extracting arguments from `params`.  If
    # values are missing for any {#keys}, return the `chain` unmodified.
    # If {#required? required}, errors are added to the {Query} instance as
    # well.
    #
    # @param [Hash] params hash of query parameters
    # @param [ActiveRecord::Relation, ActiveRecord::Base] relation current model scope
    # @return [ActiveRecord::Relation]
    def chain(params, relation)
      scope = relation.klass.method(method_name)

      inputs = keys.map do |key|
        input = params[key]

        if input.nil?
          break    if required.include?(key)
          break [] if !whitelist.include?(key)
        end

        input
      end

      if inputs.nil?
        return
      elsif inputs.empty?
        return relation
      end

      scope.arity == 0 ? scope.call : scope.call(*inputs)
    end

    private

    def register_keys(option)
      option == true ? Array(keys) : Array(option)
    end
  end
end
