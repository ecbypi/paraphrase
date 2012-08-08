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
    class_attribute :mappings, :source, :instance_writer => false

    # Delegate enumerable methods to results
    delegate :collect, :map, :each, :select, :to_a, :to_ary, :to => :results

    # @!attribute [r] errors
    #   @return [ActiveModel::Errors] errors from determining results
    #
    # @!attribute [r] params
    #   @return [HashWithIndifferentAccess] filters parameters based on keys defined in mappings
    attr_reader :errors, :params

    # Set `mappings` on inheritance to ensure they're unique per subclass
    def self.inherited(klass)
      klass.mappings = []
    end

    # Specify the ActiveRecord model to use as the source for queries
    #
    # @param [String, Symbol, ActiveRecord::Base] klass name of the class to
    #   use or the class itself
    def self.paraphrases(klass)
      if !klass.is_a?(Class)
        klass = Object.const_get(klass.to_s.classify)
      end

      self.source = klass
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
    def initialize(params = {}, relation = nil)
      keys = mappings.map(&:keys).flatten.map(&:to_s)

      @relation = relation || source.scoped

      @params = HashWithIndifferentAccess.new(params)
      @params.select! { |key, value| keys.include?(key) }
      @params.freeze

      @errors = ActiveModel::Errors.new(self)
    end

    # Loops through {#mappings} and apply scope methods to {#source}. If values
    # are missing for a required key, an empty array is returned.
    #
    # @return [ActiveRecord::Relation, Array]
    def results
      return @results if @results

      ActiveSupport::Notifications.instrument('query.paraphrase', :params => params, :source => source.name) do
        results = mappings.inject(@relation) do |query, scope|
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
