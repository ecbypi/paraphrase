require 'spec_helper'

module Paraphrase
  describe Scope do

    describe "#chain" do
      let(:scope) { Scope.new(:name_like, :to => :name) }

      it "applies scope method to relation with values from params hash" do
        Account.should_receive(:name_like).with('Jon Snow')

        scope.chain({ :name => 'Jon Snow' }, Account)
      end

      it "does nothing if values are missing" do
        Account.should_not_receive(:name_like).with('Jon Snow')

        scope.chain({}, Account)
      end

      it "passes through nil values if scope has been whitelisted" do
        scope = Scope.new(:name_like, :to => :name, :whitelist => true)

        Account.should_receive(:name_like).with(nil)

        scope.chain({}, Account)
      end
    end

    describe "compound keys" do
      let(:compound_scope) do
        Scope.new(:name_like, :to => [:first_name, :last_name], :require => :last_name)
      end

      it "can require a subset of a compound key" do
        Account.should_receive(:name_like).with(nil, 'Lannister')

        compound_scope.chain({ :last_name => 'Lannister' }, Account)
      end

      it "whitelists the the non-required keys of a compound key" do
        compound_scope.whitelist.include?(:first_name).should be_true
      end
    end
  end
end
