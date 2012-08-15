require 'spec_helper'

module Paraphrase
  describe ScopeMapping do
    let(:mapping) { ScopeMapping.new(:name_like, :to => :name) }
    let(:compound_mapping) { ScopeMapping.new(:name_like, :to => [:first_name, :last_name], :require => :last_name) }
    let(:query) { Account.scoped }

    describe "#chain" do
      it "applies scope method to query object with values from params hash" do
        Account.should_receive(:name_like).with('Jon Snow')
        mapping.chain({ :name => 'Jon Snow' }, query)
      end

      it "does nothing if values are missing" do
        Account.should_not_receive(:name_like).with('Jon Snow')
        mapping.chain({}, query)
      end

      it "passes through nil values if scope has been whitelisted" do
        mapping = ScopeMapping.new(:name_like, :to => :name, :whitelist => true)

        Account.should_receive(:name_like).with(nil)
        mapping.chain({}, query)
      end
    end

    it "can require a subset of a compound key" do
      Account.should_receive(:name_like).with(nil, 'Lannister')
      compound_mapping.chain({ :last_name => 'Lannister' }, query)
    end

    it "whitelists the the non-required keys of a compound key" do
      compound_mapping.whitelist.include?(:first_name).should be_true
    end
  end
end
