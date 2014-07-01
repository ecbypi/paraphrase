module Paraphrase
  module Syntax
    # Attempts to find paraphrase class based on class name.  Override if
    # using a different naming convention.
    def paraphraser
      name = "#{self.name}Query"
      name.constantize
    rescue NameError => e
      if e.message =~ /uninitialized constant/
        raise Paraphrase::NoQueryDefined.new(name)
      end
    end

    # Instantiate the {Query} class that is mapped to `self`.
    #
    # @param [Hash] params query parameters
    def paraphrase(params = {})
      paraphraser.new(params, default_paraphrase_relation).result
    end

    def default_paraphrase_relation
      if is_a? ActiveRecord::Relation
        self
      elsif ActiveRecord::VERSION::MAJOR > 3
        all
      else
        scoped
      end
    end
  end

  class NoQueryDefined < StandardError; end
end
