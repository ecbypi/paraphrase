require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'active_support/hash_with_indifferent_access'

module Paraphrase
  class Query
    # @!attribute [r] mappings
    #   @return [Array<ScopeMapping>] mappings for query
    class_attribute :mappings, :_source, :instance_writer => false

    # Delegate enumerable methods to `relation`
    delegate :collect, :map, :each, :select, :to_a, :to_ary, :to => :relation

    # @!attribute [r] params
    #   @return [HashWithIndifferentAccess] filters parameters based on keys defined in mappings
    #
    # @!attribute [r] relation
    #   @return [ActiveRecord::Relation]
    attr_reader :params, :relation

    # Set `mappings` on inheritance to ensure they're unique per subclass
    def self.inherited(klass)
      klass.mappings = []
    end

    # Specify the `ActiveRecord` source class if not determinable from the name
    # of the `Paraphrase::Query` subclass.
    #
    # @param [String, Symbol] name name of the source class
    def self.source(name)
      self._source = name.to_s
    end

    # Add a {ScopeMapping} instance to {@@mappings .mappings}
    #
    # @see ScopeMapping#initialize
    def self.map(name, options)
      if mappings.map(&:method_name).include?(name)
        raise DuplicateScopeError, "scope :#{name} has already been added"
      end

      mappings << ScopeMapping.new(name, options)
    end

    # Filters out parameters irrelevant to the query and sets the base scope
    # for to begin the chain.
    #
    # @param [Hash] params query parameters
    # @param [ActiveRecord::Relation] relation object to apply methods to
    def initialize(params = {}, relation = source)
      keys = mappings.map(&:keys).flatten.map(&:to_s)

      @params = params.with_indifferent_access.slice(*keys)
      scrub_params!

      ActiveSupport::Notifications.instrument('query.paraphrase', :params => params, :source_name => source.name, :source => relation) do
        @relation = mappings.inject(relation) do |query, scope|
          query = scope.chain(params, query)

          break [] if query.nil?
          query
        end
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
        klass = name.constantize

        ActiveRecord::VERSION::MAJOR > 3 ? klass.all : klass.scoped
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
