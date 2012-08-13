require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require 'active_support/hash_with_indifferent_access'
require 'active_model/naming'

module Paraphrase
  class Query
    extend ActiveModel::Naming

    # @!attribute [r] mappings
    #   @return [Array<ScopeMapping>] mappings for query
    #
    # @!attribute [r] source
    #   @return [ActiveRecord::Relation] source to apply scopes to
    class_attribute :mappings, :instance_writer => false

    # Delegate enumerable methods to results
    delegate :collect, :map, :each, :select, :to_a, :to_ary, :to => :results

    # @!attribute [r] errors
    #   @return [ActiveModel::Errors] errors from determining results
    #
    # @!attribute [r] params
    #   @return [HashWithIndifferentAccess] filters parameters based on keys defined in mappings
    #
    # @!attribute [r] source
    #   @return [ActiveRecord::Relation]
    attr_reader :errors, :params, :source

    # Set `mappings` on inheritance to ensure they're unique per subclass
    def self.inherited(klass)
      klass.mappings = []
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

    # Filters out parameters irrelevant to the query
    #
    # @param [Hash] params query parameters
    # @param [ActiveRecord::Base, ActiveRecord::Relation] source object to
    #   apply methods to
    def initialize(params, class_or_relation)
      keys = mappings.map(&:keys).flatten.map(&:to_s)

      @params = HashWithIndifferentAccess.new(params)
      @params.select! { |key, value| keys.include?(key) }
      @params.freeze

      @source = class_or_relation.scoped

      @errors = ActiveModel::Errors.new(self)
    end

    # Loops through {#mappings} and apply scope methods to {#source}. If values
    # are missing for a required key, an empty array is returned.
    #
    # @return [ActiveRecord::Relation, Array]
    def results
      return @results if @results

      ActiveSupport::Notifications.instrument('query.paraphrase', :params => params, :source => source.name) do
        results = mappings.inject(@source) do |query, scope|
          scope.chain(self, @params, query)
        end

        @results = @errors.any? ? [] : results
      end
    end

    def respond_to?(name)
      super || results.respond_to?(name)
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
