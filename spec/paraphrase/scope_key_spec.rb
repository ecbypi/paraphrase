require 'spec_helper'

module Paraphrase
  describe ScopeKey do

    it "extracts first hash option as key => scope pair" do
      key = ScopeKey.new(:name => :name_like, :foo => :bar)

      key.param_keys.should eq [:name]
      key.scope.should eq :name_like
      key.options.should eq :foo => :bar
    end

    it "handles compound keys" do
      key = ScopeKey.new([:first_name, :last_name] => :name_like)
      key.param_keys.should eq [:first_name, :last_name]
    end

    describe "#required?" do
      it "is true if options[:required] exists" do
        key = ScopeKey.new(:name => :name_like, :required => true)
        key.required?.should be_true
      end

      it "is false otherwise" do
        key = ScopeKey.new(:name => :name_like)
        key.required?.should be_false
      end
    end
  end
end
