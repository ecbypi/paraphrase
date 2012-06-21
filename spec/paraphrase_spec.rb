require 'spec_helper'

describe Paraphrase do

  describe ".register" do
    it "a sublcass of Paraphrase::Query to @@mappings" do
      Paraphrase.register(:foobar) {}
      Paraphrase.mapping(:foobar).should_not be_nil
    end

    it "adds the source to the new subclass" do
      Paraphrase.mapping(:foobar).source.should eq Foobar.scoped
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
