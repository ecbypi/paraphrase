require 'spec_helper'

describe Paraphrase do

  before(:all) { Paraphrase.register(:user) {} }

  describe ".mapping_class=" do

    after :all do
      Paraphrase.mapping_class = Paraphrase::Query
    end

    it "can configure the mapping class" do
      class MyClass; end
      Paraphrase.mapping_class = MyClass
      Paraphrase.register(:my_class) {}

      Paraphrase.mappings[:my_class].superclass.should eq MyClass
    end
  end

  describe ".register" do
    it "adds a mapping of params to scopes to .mappings" do
      Paraphrase.mappings[:user].should_not be_nil
    end

    it "raises an error if mappings for a class are added twice" do
      expect { Paraphrase.register(:user) {} }.to raise_error Paraphrase::DuplicateMappingError
    end
  end

  describe ".[]" do
    it "is a shortcut to .mappings" do
      Paraphrase[:user].should eq Paraphrase.mappings[:user]
    end
  end

  describe ".query" do
    it "instantiates a new :mapping_class" do
      Paraphrase.query(:user, {}).should be_a Paraphrase::Query
    end
  end
end
