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


    # @param [Symbol] name name of the scope method
    # @param [Hash] options options to configure {ScopeMapping ScopeMapping} instance
    # @option options [Symbol, Array<Symbol>] :key key(s) to extract from params to send to scope method
    # @option options [true] :required lists a scope as required
    def initialize(name, options)
      @method_name = name
      @param_keys = [options.delete(:key)].flatten

      @options = options.freeze
    end


    # Checks if scope is required for query
    def required?
      !options[:required].nil?
    end


    # Send scope method {#method_name} to `chain`, extracting arguments from
    # `params`.  If arguments are missing for any of the {#param_keys}, return
    # the `chain` unmodified. If the {ScopeMapping scope} is required, errors
    # are added to the {Query} instance as well.
    #
    # @param [Query] query {Query} instance applying the scope
    # @param [Hash] params hash of query parameters
    # @param [ActiveRecord::Relation, ActiveRecord::Base] chain current model scope
    # @return [ActiveRecord::Relation]
    def chain(query, params, chain)
      inputs = param_keys.map { |key| params[key] }

      if inputs.include?(nil)
        param_keys.each do |key|
          query.errors.add(key, 'is required')
        end if required?

        chain
      else
        chain.send(method_name, *inputs)
      end
    end
  end
end
