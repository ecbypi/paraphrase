require 'spec_helper'

module Paraphrase
  describe Query do

    describe ".paraphrases" do
      it "stores the class being queried" do
        AccountSearch.paraphrases :account
        AccountSearch.source.should eq Account
      end
    end

    describe ".scope" do
      it "adds information to Query.scopes" do
        AccountSearch.instance_eval do
          scope :name_like, :key => :name
        end

        AccountSearch.scopes.should_not be_empty
      end

      it "raises an error if a scope is added twice" do
        expect { AccountSearch.instance_eval { scope :name_like, :key => :name } }.to raise_error Paraphrase::DuplicateScopeError
      end
    end

    describe "#initialize" do
      let(:query) { AccountSearch.new(:name => 'Tyrion Lannister', :nickname => 'Half Man') }

      it "filters out params not specified in scopes" do
        query.params.should_not have_key :nickname
        query.params.should have_key :name
      end

      it "sets up params with indifferent access" do
        query.params.should have_key 'name'
      end
    end

    describe "#results" do
      before :all do
        AccountSearch.instance_eval do
          scope :title_like, :key => :title, :require => true
        end
      end

      it "loops through scope methods and applies them to source" do
        Account.should_receive(:title_like).and_return(Account.scoped)
        Account.should_receive(:name_like).and_return(Account.scoped)

        query = AccountSearch.new(:name => 'Jon Snow', :title => 'Wall Watcher')
        query.results
      end

      it "returns empty array if errors were added" do
        query = AccountSearch.new
        query.results.should eq []
        query.errors.should_not be_empty
      end
    end
  end
end
