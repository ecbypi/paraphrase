module Paraphrase
  module Syntax

    # Register a {Query} class mapped to `self`. If the mapping has already
    # been registered, calling again will clear existing scopes and evaluate
    # the block.
    #
    # @param [Proc] &block block to define scope mappings
    def register_mapping(&block)
      if mapping = Paraphrase.mapping(self.name.underscore)
        mapping.scopes.clear
        mapping.instance_eval(&block)
      else
        Paraphrase.register(self.name, &block)
      end
    end


    # Instantiate the {Query} class that is mapped to `self`.
    #
    # @param [Hash] params query parameters
    def paraphrase(params)
      Paraphrase.query(self.name.underscore, params)
    end
  end
end
