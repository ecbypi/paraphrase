require 'spec_helper'

module Paraphrase
  describe ScopeMapping do
    let(:scope_mapping) do
      ScopeMapping.new :name_like, :key => :name
    end
    let(:query) { double('query') }

    it "removes keys from options" do
      scope_mapping.options.should_not have_key :key
    end

    describe "#chain" do
      it "applies scope method to query object with values from params hash" do
        Account.should_receive(:name_like).with('Jon Snow')
        scope_mapping.chain(query, { :name => 'Jon Snow' }, Account)
      end

      it "does nothing if values are missing" do
        Account.should_not_receive(:name_like).with('Jon Snow')
        scope_mapping.chain(query, {}, Account)
      end

      it "adds errors to query object if missing and required" do
        errors = double('errors')
        query.stub(:errors).and_return(errors)
        required_mapping = ScopeMapping.new :name_like, :key => :name, :require => true

        errors.should_receive(:add)
        required_mapping.chain(query, {}, Account)
      end

      it "passes through nil values if scope has been whitelisted" do
        whitelisted_mapping = ScopeMapping.new :name_like, :key => :name, :allow_nil => true

        Account.should_receive(:name_like).with(nil)
        whitelisted_mapping.chain(query, {}, Account)
      end
    end

    it "can require a subset of a compound key" do
      mapping = ScopeMapping.new :name_like, :key => [:first_name, :last_name], :require => :last_name

      Account.should_receive(:name_like).with(nil, 'Lannister')
      mapping.chain(query, { :last_name => 'Lannister' }, Account)
    end
  end
end
