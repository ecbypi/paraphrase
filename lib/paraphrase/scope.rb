module Paraphrase
  class Scope
    attr_reader :keys, :name, :options

    def initialize(name, options, params)
      @name = name
      @keys = [options.delete(:key)].flatten

      @options = options
      @inputs = @keys.map { |key| params[key] }
    end

    def required?
      !options[:required].nil?
    end

    def chain(chain)
      if !valid?
        return chain
      end

      if options[:preprocess]
        @inputs = [options[:preprocess].call(*@inputs)]
      end

      chain.send(name, *@inputs)
    end

    def valid?
      !@inputs.include?(nil)
    end
  end
end
