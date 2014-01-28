require 'active_support/core_ext/object/blank'

module Paraphrase
  class Scope
    # @!attribute [r] keys
    #   @return [Array<Symbol>] param keys to extract
    #
    # @!attribute [r] name
    #   @return [Symbol] scope name
    #
    # @!attribute [r] required
    #   @return [Array] keys required for query
    #
    # @!attribute [r] whitelist
    #   @return [Array] keys allowed to be nil
    attr_reader :keys, :name, :required, :whitelist

    # @param [Symbol] name name of the scope
    # @param [Hash] options options to configure {Scope Scope} instance
    # @option options [Symbol, Array<Symbol>] :to param key(s) to extract values from
    # @option options [true, Symbol, Array<Symbol>] :require lists all or a
    #   subset of param keys as required
    # @option options [true, Symbol, Array<Symbol>] :whitelist lists all or a
    #   subset of param keys as whitelisted
    def initialize(keys, options)
      @keys = keys
      @name = options[:to]

      @required = register_keys(options[:require])
      @whitelist = register_keys(options[:whitelist])

      if @whitelist.empty? && !@required.empty?
        @whitelist = @keys - @required
      end

      if (whitelist & required).any?
        raise ArgumentError, "cannot whitelist and require the same keys"
      end
    end

    # Sends {#name} to `chain`, extracting arguments from `params`.  If
    # values are missing for any {#keys}, return the `chain` unmodified.
    # If {#required? required}, errors are added to the {Query} instance as
    # well.
    #
    # @param [Hash] params hash of query parameters
    # @param [ActiveRecord::Relation, ActiveRecord::Base] relation scope chain
    # @return [ActiveRecord::Relation]
    def chain(params, relation)
      scope = relation.respond_to?(:klass) ? relation.klass.method(name) : relation.method(name)

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

      scope.arity == 0 ? relation.send(name) : relation.send(name, *inputs)
    end

    private

    def register_keys(option)
      option == true ? Array(keys) : Array(option)
    end
  end
end
