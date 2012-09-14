require 'spec_helper'

module Paraphrase
  describe Query do
    describe ".map" do
      subject { Class.new(Query) }

      it "adds information to Query.mappings" do
        subject.map :name_like, :to => :name

        subject.mappings.should_not be_empty
      end

      it "raises an error if a scope is added twice" do
        subject.map :name_like, :to => :name

        expect { subject.map :name_like, :to => :name }.to raise_error Paraphrase::DuplicateScopeError
      end
    end

    describe "on initialization" do
      let(:query) do
        klass = Class.new(Query) do
          map :name_like, :to => :name
        end

        klass.new({ :name => '', :nickname => '' }, Account)
      end

      it "filters out params not specified in mappings" do
        query.params.should_not have_key :nickname
        query.params.should have_key :name
      end

      it "sets up params with indifferent access" do
        query.params.should have_key 'name'
      end
    end

    describe "#results" do
      let(:klass) do
        Class.new(Query) do
          map :name_like, :to => :name
          map :title_like, :to => :title, :require => true
        end
      end

      it "loops through scope methods and applies them to source" do
        Account.should_receive(:title_like).and_return(Account.scoped)
        Account.should_receive(:name_like).and_return(Account.scoped)

        query = klass.new({ :name => 'Jon Snow', :title => 'Wall Watcher'}, Account)
        query.results
      end

      it "returns empty array if inputs were missing and required" do
        query = klass.new({}, Account)
        query.results.should eq []
      end
    end

    describe "preserves" do
      let(:accounts) do
        user = User.create!
        user.accounts << Account.create!
      end

      let(:results) do
        klass = Class.new(Query) do
          map :name_like, :to => :name
        end

        klass.new({ :name => 'name' }, accounts).results.to_a
      end

      it "the relation passed in during initialization" do
        # Create an extra account that shouldn't be in the results
        Account.create!

        results.should eq accounts.to_a
      end
    end
  end
end
