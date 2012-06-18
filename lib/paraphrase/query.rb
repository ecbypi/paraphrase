require 'paraphrase/scope'

module Paraphrase
  class Query

    class << self
      attr_reader :source
    end

    def self.scopes
      @scopes ||= {}
    end

    def self.paraphrases(source_name, options = {})
      @source = Object.const_get(source_name)

      store_name = options[:as] ? options[:as] : source_name
      Paraphrase.register(store_name, @source)
    rescue NameError
      raise SourceMissingError, "source #{source_name} is not defined"
    end

    def self.scope(name, options)
      scopes[name] = options
    end

    def initialize(params = {})
      @scopes = self.class.scopes.map { |name, options| Scope.new(name, options, params) }
    end

    def results
      @results ||= if scopes_valid?
                     results = @scopes.inject(self.class.source) do |results, scope|
                       scope.chain(results)
                     end

                     results.to_a
                   else
                     []
                   end
    end

    def scopes_valid?
      @scopes.select { |scope| scope.required? }.map(&:valid?).all?
    end
  end
end
