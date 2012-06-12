require 'paraphrase/mapping'

module Paraphrase
  class Query
    attr_reader :params

    class << self
      attr_accessor :source, :mappings
    end

    def self.paraphrases(class_name)
      self.source = class_name
    end

    def self.key(mapping, options = {})
      mapping = Mapping.new(mapping, options)
      (self.mappings ||= []) << mapping

      attr_reader mapping.param_key
    end

    def self.keys
      self.mappings.map(&:param_key)
    end

    def initialize(params)
      @params = self.class.keys.inject({}) do |hash, key|
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
