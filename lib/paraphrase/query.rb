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

    # Delegate enumerable methods to results
    delegate :collect, :map, :each, :select, :to_a, :to_ary, :to => :results

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

      @params = HashWithIndifferentAccess.new(params)
      @params.select! { |key, value| keys.include?(key) && value.present? }
      @params.freeze

      @relation = relation
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

    # Loops through {#mappings} and apply scope methods to {#relation}. If values
    # are missing for a required key, an empty array is returned.
    #
    # @return [ActiveRecord::Relation, Array]
    def results
      return @results if @results

      ActiveSupport::Notifications.instrument('query.paraphrase', :params => params, :source_name => source.name, :source => relation) do
        @results = mappings.inject(relation) do |query, scope|
          query = scope.chain(params, query)

          break [] if query.nil?
          query
        end
      end
    end

    def respond_to_missing?(name, include_private = false)
      super || results.respond_to?(name, include_private)
    end

    protected

    def method_missing(name, *args, &block)
      if results.respond_to?(name)
        self.class.delegate name, :to => :results
        results.send(name, *args, &block)
      else
        super
      end
    end
  end
end

require 'paraphrase/scope_mapping'
