require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/class/attribute'
require 'active_model/naming'

module Paraphrase
  class Query
    extend ActiveModel::Naming

    cattr_reader :scopes, :source
    @@scopes = []

    def self.paraphrases(klass)
      if !klass.is_a?(Class)
        klass = Object.const_get(klass.to_s.classify)
      end

      @@source = klass.scoped

      Paraphrase.add(klass.name, self)
    end

    def self.scope(name, options)
      @@scopes << ScopeMapping.new(name, options)
    end

    def initialize(params = {})
      keys = scopes.map(&:keys)
      @params = params.dup
      @params.select! { |key, value| keys.include?(key) }
      @params.freeze

      @errors = ActiveModel::Errors.new(self)
    end

    def results
      scopes.inject(source) do |query, scope|
        scope.chain(self, @params, query)
      end
    end
  end
end

require 'paraphrase/scope_mapping'
