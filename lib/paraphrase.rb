require 'paraphrase/version'
require 'paraphrase/errors'
require 'paraphrase/query'
require 'paraphrase/syntax'

module Paraphrase

  class << self
    attr_writer :mapping_class
  end

  self.mapping_class = Query

  def self.mappings
    @mappings ||= {}
  end

  def self.register(name, &block)
    raise DuplicateMappingError if mappings[name]
    mappings[name] = Class.new(@mapping_class, &block)
  end

  def self.[](name)
    mappings[name]
  end

  def self.[]=(name, klass)
    raise DuplicateMappingError if mappings[name]
    mappings[name] = klass
  end

  def self.query(name, params)
    mappings[name].new(params)
  end
end

require 'paraphrase/rails' if defined?(Rails)
