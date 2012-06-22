require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'

module Paraphrase

  @@mappings = {}.with_indifferent_access

  # Retreive a registered Query subclass.
  #
  # @param [String, Symbol] name of the class underscored
  # @return [Query]
  def self.mapping(name)
    @@mappings[name]
  end

  # Add a new subclass of Paraprhase::Query. The provided block is evaluated in
  # the context of a Query subclass to define scope mappings.
  #
  # @param [String, Symbol] name name of the model in any inflector form
  # @param [Proc] block defining mappings of scopes to keys for Query subclass
  def self.register(name, &block)
    klass = Class.new(Query, &block)
    klass.paraphrases(name.to_s.classify)
  end

  # Register a subclass of Paraphrase::Query. Useful for manually subclassing
  # Paraphrase::Query to add custom functionality.
  #
  # @param [String, Symbol] name name of the class in any ActiveSupport inflector form
  # @param [Query] klass subclass of Paraphrase::Query
  def self.add(name, klass)
    name = name.to_s.underscore

    if @@mappings[name]
      raise DuplicateMappingError, "#{name.classify} has already been added"
    end

    @@mappings[name] = klass
  end

  # Instantiate a new Query subclass using supplied params
  #
  # @param [String, Symbol] name name of the model in underscored form
  # @param [Hash] params hash of query params
  # @return [Query]
  def self.query(name, params)
    @@mappings[name].new(params)
  end
end

require 'paraphrase/errors'
require 'paraphrase/query'
require 'paraphrase/syntax'
require 'paraphrase/rails' if defined?(Rails)
