require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/array/extract_options'
require 'active_support/hash_with_indifferent_access'
require 'paraphrase/active_model'
require 'paraphrase/params'

module Paraphrase
  class Query
    include ActiveModel
    # @!attribute [r] scopes
    #   @return [Array<Scope>] scopes for query
    class_attribute :scopes, :_source, instance_writer: false
    class_attribute :_param_processor, instance_writer: false, instance_reader: false

    # @!attribute [r] params
    #   @return [HashWithIndifferentAccess] filters parameters based on keys defined in scopes
    #
    # @!attribute [r] result
    #   @return [ActiveRecord::Relation]
    attr_reader :params, :result

    # Set `scopes` on inheritance to ensure they're unique per subclass
    def self.inherited(klass)
      klass.scopes = []
    end

    # Specify the `ActiveRecord` source class if not determinable from the name
    # of the `Paraphrase::Query` subclass.
    #
    # @param [String, Symbol] name name of the source class
    def self.source(name)
      self._source = name.to_s
    end

    # Returns the class for processing and filtering query params.
    def self.param_processor
      self._param_processor ||= begin
        self::Params
      rescue NameError
        Paraphrase::Params
      end
    end

    # Add a {Scope} instance to {Query#scopes}. Defines a reader for each key
    # to read from {Query#params}.
    #
    # @see Scope#initialize
    def self.map(*keys)
      options = keys.extract_options!
      scope_name = options[:to]

      if scopes.any? { |scope| scope.name == scope_name }
        raise DuplicateScopeError, "scope :#{scope_name} has already been mapped"
      end

      scopes << Scope.new(keys, options)

      keys.each do |key|
        define_method(key) { params[key] }
      end
    end

    # Filters out parameters irrelevant to the query and sets the base scope
    # for to begin the chain.
    #
    # @param [Hash] params query parameters
    # @param [ActiveRecord::Relation] relation object to apply methods to
    def initialize(params = {}, relation = source)
      @params = process_params(params)

      @result = scopes.inject(relation) do |result, scope|
        scope.chain(@params, result)
      end
    end

    # Return an `ActiveRecord::Relation` corresponding to the source class
    # determined from the `_source` class attribute or the name of the query
    # class.
    #
    # @return [ActiveRecord::Relation]
    def source
      @source ||= begin
        name = _source || self.class.to_s.sub(/Query$/, '')
        name.constantize
      end
    end

    # Keys used in the query
    #
    # @return [Array<Symbol>]
    def keys
      scopes.flat_map(&:keys)
    end

    private

    def process_params(params)
      self.class.param_processor.new(params, keys).result
    end
  end
end
