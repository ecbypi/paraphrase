require 'paraphrase/version'
require 'paraphrase/errors'
require 'paraphrase/mapping_set'

module Paraphrase

  class << self
    attr_reader :mappings
    attr_writer :mapping_class
  end

  self.mapping_class = MappingSet

  def self.register(name, &block)
    @mappings ||= {}

    raise Paraphrase::DuplicateMappingError if mappings[name]
    @mappings[name] = Class.new(@mapping_class, &block)
  end

  def self.[](name)
    mappings[name]
  end
end
