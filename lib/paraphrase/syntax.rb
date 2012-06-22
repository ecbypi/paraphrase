module Paraphrase
  module Syntax

    # Register a {Query} class mapped to `self`.
    #
    # @param [Proc] &block block to define scope mappings
    def register_mapping(&block)
      Paraphrase.register(self.name, &block)
    end


    # Instantiate the {Query} class that is mapped to `self`.
    #
    # @param [Hash] params query parameters
    def paraphrase(params)
      Paraphrase.query(self.name.underscore, params)
    end
  end
end
