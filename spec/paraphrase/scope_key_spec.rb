require 'spec_helper'

module Paraphrase
  describe Scope do
    let(:key) do
      Scope.new :name_like, { :key => :name, :foo => :bar, :preprocess => lambda { |name| name.upcase } }, :name => 'Jon Snow'
    end

    let(:compound_key) do
      Scope.new :name_like, { :key => [:first_name, :last_name], :required => true }, { :first_name => 'Jon', :last_name => 'Snow' }
    end

    it "extracts first hash option as key => scope pair" do
      key.keys.should eq [:name]
      key.name.should eq :name_like
      key.options.should have_key :foo
      key.options.should have_value :bar
    end

    it "handles compound keys" do
      compound_key.keys.should eq [:first_name, :last_name]
    end

    describe "#required?" do
      it "is true if options[:required] exists" do
        compound_key.required?.should be_true
      end

      it "is false otherwise" do
        key.required?.should be_false
      end
    end

    describe "#chain" do
      it "applies it's scope to the source" do
        User.should_receive(:name_like).with('Jon', 'Snow')
        compound_key.chain(User)
      end

      it "runs any pre-processors on values" do
        User.should_receive(:name_like).with('JON SNOW')
        key.chain(User)
      end
    end
  end
end
