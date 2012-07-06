require 'spec_helper'

describe Paraphrase do

  describe ".configure" do
    it "is a convenience method for configuring multiple query classes" do
      Paraphrase.configure do |mapping|
        mapping.register(:person) {}
      end

      Paraphrase.mapping(:person).should_not be_nil
    end
  end

  describe ".register" do
    it "a sublcass of Paraphrase::Query to @@mappings" do
      Paraphrase.register(:foobar) {}
      Paraphrase.mapping(:foobar).should_not be_nil
    end

    it "adds the source to the new subclass" do
      Paraphrase.mapping(:foobar).source.should eq Foobar
    end

    it "raises an error if mappings for a class are added twice" do
      expect { Paraphrase.register(:foobar) {} }.to raise_error Paraphrase::DuplicateMappingError
    end
  end

  describe ".query" do
    it "instantiates a new Query class" do
      Paraphrase.query(:foobar, {}).should be_a Paraphrase::Query
    end
  end

  describe ".add" do
    it "adds class to mapping with specified name" do
      klass = Class.new(Paraphrase::Query)
      Paraphrase.add(:baz, klass)
      Paraphrase.mapping(:baz).should eq klass
    end
  end
end
