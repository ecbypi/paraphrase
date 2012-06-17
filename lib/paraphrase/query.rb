require 'paraphrase/scope'

module Paraphrase
  class Query

    class << self
      attr_reader :source, :scopes
    end

    def self.paraphrases(source_name, options = {})
      @source = Object.const_get(source_name)

      store_name = options[:as] ? options[:as] : source_name
      Paraphrase.register(store_name, @source)
    rescue NameError
      raise SourceMissingError, "source #{source_name} is not defined"
    end

    def self.scope(name, options)
      @scopes ||= {}
      @scopes[name] = options
    end

    def initialize(params = {})
      @scopes = _scopes.map { |name, options| Scope.new(name, options, params) }
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

    private

    def _scopes
      self.class.scopes
    end
  end
end
