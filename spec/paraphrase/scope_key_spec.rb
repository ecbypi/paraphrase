require 'spec_helper'

module Paraphrase
  describe ScopeKey do
    let(:key) { ScopeKey.new(:name => :name_like, :foo => :bar) }
    let(:compound_key) { ScopeKey.new([:first_name, :last_name] => :name_like, :required => true) }

    it "extracts first hash option as key => scope pair" do
      key.param_keys.should eq [:name]
      key.scope.should eq :name_like
      key.options.should eq :foo => :bar
    end

    it "handles compound keys" do
      compound_key.param_keys.should eq [:first_name, :last_name]
    end

    describe "#required?" do
      it "is true if options[:required] exists" do
        compound_key.required?.should be_true
      end

      it "is false otherwise" do
        key.required?.should be_false
      end
    end
  end
end
