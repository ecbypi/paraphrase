require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'

module Paraphrase

  @@mappings = {}.with_indifferent_access

  def self.mapping(name)
    @@mappings[name]
  end

  def self.register(name, &block)
    klass = Class.new(Query, &block)
    klass.paraphrases(name.to_s.classify)
  end

  def self.add(name, klass)
    name = name.to_s.underscore

    if @@mappings[name]
      raise DuplicateMappingError, "#{name.classify} has already been added"
    end

    @@mappings[name] = klass
  end

  def self.query(name, params)
    @@mappings[name].new(params)
  end
end

require 'paraphrase/errors'
require 'paraphrase/query'
require 'paraphrase/syntax'
require 'paraphrase/rails' if defined?(Rails)
