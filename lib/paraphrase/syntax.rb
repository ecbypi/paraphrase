module Paraphrase
  module Syntax

    def self.extended(klass)
      klass.instance_eval do
        class_attribute :paraphraser, :instance_writer => false, :instance_reader => false
      end
    end

    # Register a {Query} class mapped to `self`. If the mapping has already
    # been registered, calling again will clear existing scopes and evaluate
    # the block.
    #
    # @param [Proc] &block block to define scope mappings
    def register_mapping(&block)
      klass = Class.new(Query, &block)
      klass.source = self
      self.paraphraser = klass
    end


    # Instantiate the {Query} class that is mapped to `self`.
    #
    # @param [Hash] params query parameters
    def paraphrase(params)
      self.paraphraser.new(params)
    end
  end
end
