module Paraphrase
  module Syntax
    # Attempts to find paraphrase class based on class name.  Override if
    # using a different naming convention.
    def paraphraser
      name = "#{self.name}Query"
      name.constantize
    rescue NameError => e
      if e.message =~ /uninitialized constant/
        raise Paraphrase::NoQueryDefined.new("No query class found. #{name} must be defined as a subclass of Paraphrase::Query")
      end
    end

    # Instantiate the {Query} class that is mapped to `self`.
    #
    # @param [Hash] params query parameters
    def paraphrase(params = {})
      paraphraser.new(params, self).result
    end
  end

  class NoQueryDefined < StandardError; end
end
