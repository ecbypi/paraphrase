require 'spec_helper'

module Paraphrase
  describe Query do

    class AccountSearch < Query
    end

    describe ".paraphrases" do
      it "stores the class being queried" do
        AccountSearch.paraphrases :account
        AccountSearch.source.should eq Account
      end
    end

    describe ".scope" do
      it "adds information to Query.mappings" do
        AccountSearch.instance_eval do
          map :name_like, :to => :name
        end

        AccountSearch.mappings.should_not be_empty
      end

      it "raises an error if a scope is added twice" do
        expect { AccountSearch.instance_eval { map :name_like, :to => :name } }.to raise_error Paraphrase::DuplicateScopeError
      end
    end

    describe "#initialize" do
      let(:query) { AccountSearch.new(:name => 'Tyrion Lannister', :nickname => 'Half Man') }

      it "filters out params not specified in mappings" do
        query.params.should_not have_key :nickname
        query.params.should have_key :name
      end

      it "sets up params with indifferent access" do
        query.params.should have_key 'name'
      end

      it "accepts an ActiveRecord::Relation to use as the base scope" do
        user = User.create!
        associated_account = Account.create!(:user => user)
        lonely_account = Account.create!

        results = AccountSearch.new({ :name => 'Tyrion Lannister'}, user.accounts).results

        results.should include associated_account
        results.should_not include lonely_account
      end
    end

    describe "#results" do
      before :all do
        AccountSearch.instance_eval do
          map :title_like, :to => :title, :require => true
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
