require 'spec_helper'

module Paraphrase
  describe ScopeKey do
    let(:key) do
      ScopeKey.new :name => :name_like, :foo => :bar, :preprocess => lambda { |name| name.upcase }
    end
    let(:compound_key) { ScopeKey.new([:first_name, :last_name] => :name_like, :required => true) }

    it "extracts first hash option as key => scope pair" do
      key.param_keys.should eq [:name]
      key.scope.should eq :name_like
      key.options.should have_key :foo
      key.options.should have_value :bar
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

    describe "#values" do
      it "returns relevant values from supplied hash" do
        values = compound_key.values(:first_name => 'Jon', :last_name => 'Snow', :title => 'Wall Watcher')
        values.should eq ['Jon', 'Snow']
      end

      it "runs any supplied pre-processors on values" do
        value = key.values(:name => 'Jon Snow', :title => 'Wall Watcher')
        value.should eq ['JON SNOW']
      end
    end
  end
end
