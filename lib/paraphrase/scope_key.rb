module Paraphrase
  class ScopeKey
    attr_reader :name, :scope, :options

    def initialize(options)
      @name, @scope = options.first

      options.delete(@name)
      @options = options.freeze
    end

    def required?
      !options[:required].nil?
    end

    alias :param_key :name
  end
end
