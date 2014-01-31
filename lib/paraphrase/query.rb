require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/array/extract_options'
require 'active_support/hash_with_indifferent_access'

module Paraphrase
  class Query
    # @!attribute [r] scopes
    #   @return [Array<Scope>] scopes for query
    class_attribute :scopes, :_source, :instance_writer => false

    # Delegate enumerable methods to `relation`
    delegate :collect, :map, :each, :select, :to_a, :to_ary, :to => :relation

    # @!attribute [r] params
    #   @return [HashWithIndifferentAccess] filters parameters based on keys defined in scopes
    #
    # @!attribute [r] relation
    #   @return [ActiveRecord::Relation]
    attr_reader :params, :relation

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
        define_method(key) { params[key] } unless method_defined?(key)
      end
    end

    # Filters out parameters irrelevant to the query and sets the base scope
    # for to begin the chain.
    #
    # @param [Hash] params query parameters
    # @param [ActiveRecord::Relation] relation object to apply methods to
    def initialize(params = {}, relation = source)
      keys = scopes.map(&:keys).flatten.map(&:to_s)

      @params = params.with_indifferent_access.slice(*keys)
      scrub_params!

      ActiveSupport::Notifications.instrument('query.paraphrase', :params => params, :source_name => source.name, :source => relation) do
        @relation = scopes.inject(relation) do |r, scope|
          scope.chain(self, r)
        end
      end
    end

    alias :[] :send

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

    def respond_to_missing?(name, include_private = false)
      super || relation.respond_to?(name, include_private)
    end

    protected

    def method_missing(name, *args, &block)
      if relation.respond_to?(name)
        self.class.delegate name, :to => :relation
        relation.send(name, *args, &block)
      else
        super
      end
    end

    private

    def scrub_params!
      params.delete_if { |key, value| scrub(value) }
    end

    def scrub(value)
      value = case value
      when Array
        value.delete_if { |v| scrub(v) }
      when Hash
        value.delete_if { |k, v| scrub(v) }
      when String
        value.strip
      else
        value
      end

      value.blank?
    end
  end
end
