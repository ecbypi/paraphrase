require 'paraphrase/mapping'

module Paraphrase
  class Query
    attr_reader :params

    class << self
      attr_reader :source, :mappings
    end

    def self.paraphrases(source_name)
      @source = Object.const_get(source_name)
    rescue NameError
      raise SourceMissingError, "source #{source} is not defined"
    end

    def self.key(mapping, options = {})
      @mappings ||=[]

      mapping = Mapping.new(mapping, options)
      @mappings << mapping

      attr_reader mapping.param_key
    end

    def initialize(params)
      @params = self.class.mappings.inject({}) do |hash, mapping|
        key = mapping.param_key
        value = params[key]

        if !value.empty? && !value.nil?
          instance_variable_set("@#{key}", value)
          hash[key] = value
        end

        hash
      end
    end
  end
end
