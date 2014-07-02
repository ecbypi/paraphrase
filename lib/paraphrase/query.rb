require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/array/extract_options'
require 'active_support/hash_with_indifferent_access'

require 'paraphrase/active_model'
require 'paraphrase/mapping'
require 'paraphrase/params_filter'
require 'paraphrase/repository'

module Paraphrase
  class Query
    include ActiveModel
    # @!attribute [r] mappings
    #   @return [Array<Paraphrase::Mapping>] mappings for query
    # @!attribute [r] source
    #   @return [Symbol, String] name of the class to use as the source for the
    #   query
    class_attribute :mappings, instance_writer: false
    class_attribute :source, instance_writer: false, instance_reader: false
    class_attribute :params_filter, instance_writer: false
    class_attribute :repository, instance_writer: false

    # @!attribute [r] params
    #   @return [HashWithIndifferentAccess] filtered parameters based on keys defined in `mappings`
    #
    # @!attribute [r] result
    #   @return [ActiveRecord::Relation]
    attr_reader :params, :result

    # Set `mappings` on inheritance to ensure they're unique per subclass
    def self.inherited(klass)
      klass.mappings = []
      klass.source = klass.to_s.sub(/Query$/, '')

      klass.params_filter = Class.new(Paraphrase::ParamsFilter)
      klass.const_set(:ParamsFilter, klass.params_filter)

      klass.repository = Class.new(Paraphrase::Repository)
      klass.const_set(:Repository, klass.repository)
    end

    # Keys being mapped to scopes
    #
    # @return [Array<Symbol>]
    def self.keys
      mappings.flat_map(&:keys)
    end

    # Add a {Mapping} instance to {Query#mappings}. Defines a reader for each
    # key to read from {Query#params}.
    #
    # @overload map(*keys, options)
    #   Maps a key to a scope
    #   @param [Array<Symbol>] keys query params to be mapped to the scope
    #   @param [Hash] options options to configure {Mapping Mapping} instance
    #   @option options [Symbol, Array<Symbol>] :to scope to map query params to
    #   @option options [true, Symbol, Array<Symbol>] :whitelist lists all or a
    #     subset of param keys as optional
    def self.map(*keys)
      options = keys.extract_options!
      scope_name = options[:to]

      if mappings.any? { |mapping| mapping.name == scope_name }
        raise DuplicateMappingError.new(scope_name)
      end

      mappings << Mapping.new(keys, options)

      keys.each do |key|
        define_method(key) { params[key] }
      end
    end

    # Define a method on `ParamsFilter` to process the raw value of the query
    # param
    #
    # @param [Symbol] query_param query param to process
    # @param [Proc] block block to process the query param
    def self.param(query_param, &block)
      params_filter.class_eval do
        define_method(query_param, &block)
      end
    end

    # Define a scope on `Repository`
    def self.scope(scope_name, &block)
      repository.class_eval do
        define_method(scope_name, &block)
      end
    end

    # Filters out parameters irrelevant to the query and sets the base scope
    # for to begin the chain.
    #
    # @param [Hash] params query parameters
    # @param [ActiveRecord::Relation] relation object to apply methods to
    def initialize(query_params, relation = nil)
      @params = filter_params(query_params || {})

      @result = mappings.inject(relation || default_relation) do |result, mapping|
        repository.chain(result, mapping, @params)
      end
    end

    # Return an `ActiveRecord::Relation` corresponding to the source class
    # determined from the `source` class attribute that defaults to the name of
    # the class.
    #
    # @return [ActiveRecord::Relation]
    def default_relation
      klass = self.class.source.to_s.constantize
      klass.default_paraphrase_relation
    end

    # @see Query.keys
    def keys
      self.class.keys
    end

    private

    def filter_params(params)
      params_filter.new(params, keys).result
    end
  end
end
