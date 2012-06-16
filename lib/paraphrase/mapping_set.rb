require 'paraphrase/scope_key'

module Paraphrase
  class MappingSet

    class << self
      attr_reader :source, :scope_keys
    end

    def self.paraphrases(source_name, options = {})
      @source = Object.const_get(source_name)

      store_name = options[:as] ? options[:as] : source_name
      Paraphrase.register(store_name, @source)
    rescue NameError
      raise SourceMissingError, "source #{source} is not defined"
    end

    def self.key(options)
      @scope_keys ||=[]

      scope_key = ScopeKey.new(options)
      @scope_keys << scope_key
    end

    def initialize(params = {})
      valid_keys = _keys.map(&:param_keys).flatten
      @params = params.select { |key, value| valid_keys.include?(key) }
    end

    def results
      @results ||= _keys.inject(self.class.source) do |chain, key|
        inputs = key.param_keys.map { |key| @params[key] }

        if key.required?
          break []
        else
          next chain
        end if inputs.compact.empty?

        chain.send(key.scope, *inputs)
      end
    end

    private

    def _keys
      self.class.scope_keys
    end
  end
end
