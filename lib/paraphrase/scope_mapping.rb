module Paraphrase
  class ScopeMapping
    attr_reader :keys, :name, :options

    def initialize(name, options)
      @name = name
      @keys = [options.delete(:key)].flatten

      @options = options.freeze
    end

    def required?
      !options[:required].nil?
    end

    def chain(query, params, chain)
      inputs = keys.map { |key| params[key] }

      if inputs.include?(nil)
        keys.each do |key|
          query.errors.add(key, 'is required')
        end if required?

        chain
      else
        chain.send(name, *inputs)
      end
    end
  end
end
