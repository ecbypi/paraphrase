require 'spec_helper'
require 'paraphrase'

describe Paraphrase do

  before(:all) { Paraphrase.register(:user) {} }

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
end
