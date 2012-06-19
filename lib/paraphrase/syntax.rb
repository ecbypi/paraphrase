module Paraphrase
  module Syntax

    def self.extended(base)
      base.class_eval do
        @@mapping_name = self.to_s.to_sym
      end
    end

    def register_mapping(name = @@mapping_name, &block)
      Paraphrase.register(name, &block)
      Paraphrase[@@mapping_name].paraphrases(self)
    end

    def paraphrase(params)
      Paraphrase.query(@@mapping_name, params)
    end
  end
end
