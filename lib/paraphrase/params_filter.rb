module Paraphrase
  class ParamsFilter
    attr_reader :params, :result

    def initialize(params, keys)
      @params = params.with_indifferent_access.slice(*keys)

      @result = @params.inject(HashWithIndifferentAccess.new) do |result, (key, value)|
        value = @params[key]

        if respond_to?(key)
          value = send(key)
        end

        value = scrub(value)

        if value.present?
          result[key] = value
        end

        result
      end
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
