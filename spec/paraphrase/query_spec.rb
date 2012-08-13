require 'spec_helper'

module Paraphrase
  describe Query do
    subject { AccountQuery }
    let(:query) { Account.paraphrase(:name => 'Tyrion Lannister', :nickname => 'Half Man') }

    describe ".map" do
      it "adds information to Query.mappings" do
        subject.map :name_like, :to => :name

        subject.mappings.should_not be_empty
      end

      it "raises an error if a scope is added twice" do
        expect { subject.map :name_like, :to => :name }.to raise_error Paraphrase::DuplicateScopeError
      end
    end

    describe "on initialization" do
      it "filters out params not specified in mappings" do
        query.params.should_not have_key :nickname
        query.params.should have_key :name
      end

      it "sets up params with indifferent access" do
        query.params.should have_key 'name'
      end
    end

    describe "#results" do
      before :all do
        subject.map :title_like, :to => :title, :require => true
      end

      it "loops through scope methods and applies them to source" do
        Account.should_receive(:title_like).and_return(Account.scoped)
        Account.should_receive(:name_like).and_return(Account.scoped)

        query = Account.paraphrase(:name => 'Jon Snow', :title => 'Wall Watcher')
        query.results
      end

      it "returns empty array if errors were added" do
        query = Account.paraphrase({})
        query.results.should eq []
        query.errors.should_not be_empty
      end
    end
  end
end
