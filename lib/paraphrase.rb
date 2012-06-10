require 'paraphrase/version'
require 'paraphrase/errors'

module Paraphrase

  class << self
    attr_accessor :mappings
  end

  def self.register(name, &block)
    self.mappings ||= {}

    raise Paraphrase::DuplicateMappingError if self.mappings[name]
    self.mappings[name] = Class.new(&block)
  end

  def self.[](name)
    self.mappings[name]
  end
end
