require 'active_support/core_ext/object/blank'
require 'active_support/hash_with_indifferent_access'

module Paraphrase
  # {ParamsFilter} is responsible for processing the query params the {Query}
  # object was initialized with.
  #
  # In the following order, it:
  #
  # 1. Removes all keys not mapped to a model scope
  # 2. Pre-processes the query param if a pre-processor is defined
  # 3. Recursively removes blank values from the value
  # 4. Removes the param if the pre-processed, scrubbed value is `blank?`
  #
  # Each {Query} subclass has its own {ParamsFilter} subclass defined on
  # inheritance that can be customized to pre-process query params. The class
  # can be re-opened inside the {Query} class definition or by calling the
  # {Query.param param} class method.
  class ParamsFilter
    def initialize(params, keys)
      @keys = keys
      @params = params
    end

    def result
      @keys.inject(ActiveSupport::HashWithIndifferentAccess.new) do |result, key|
        value = scrub(public_send(key))

        if value.present?
          result[key] = value
        end

        result
      end
    end

    def [](key)
      @params[key.to_sym] || @params[key.to_s]
    end

    def params
      self
    end

    private

    def scrub(value)
      case value
      when Array
        value.delete_if { |v| scrub(v).blank? }
      when Hash
        value.delete_if { |k, v| scrub(v).blank? }
      when String
        value.strip
      else
        value
      end
    end
  end
end
