module Paraphrase
  module Syntax

    def register_mapping(&block)
      Paraphrase.register(self.name, &block)
    end

    def paraphrase(params)
      Paraphrase.query(self.name.underscore, params)
    end
  end
end
