require 'paraphrase/version'
require 'paraphrase/errors'

module Paraphrase

  class << self
    attr_reader :mappings
  end

  def self.register(name, &block)
    @mappings ||= {}

    raise Paraphrase::DuplicateMappingError if mappings[name]
    mappings[name] = Class.new(&block)
  end

  def self.[](name)
    mappings[name]
  end
end

require 'paraphrase/query'
