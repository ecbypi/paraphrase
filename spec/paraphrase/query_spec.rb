require 'spec_helper'

module Paraphrase
  describe Query do

    describe ".paraphrases" do
      it "stores the class being queried" do
        UserSearch.paraphrases :user
        UserSearch.source.should eq User.scoped
      end

      it "registers the query in Paraphrase.querys" do
        Paraphrase.mapping(:user).should eq UserSearch
      end
    end

    describe ".scope" do
      it "adds information to Query.scopes" do
        UserSearch.instance_eval do
          scope :name_like, :key => :name
        end

        UserSearch.scopes.should_not be_empty
      end

      it "raises an error if a scope is added twice" do
        expect { UserSearch.instance_eval { scope :name_like, :key => :name } }.to raise_error Paraphrase::DuplicateScopeError
      end
    end

    describe "#initialize" do
      it "filters out params not specified in scopes" do
        query = UserSearch.new(:name => 'Tyrion Lannister', :nickname => 'Half Man')

        query.params.should_not have_key :nickname
        query.params.should have_key :name
      end
    end

    describe "#results" do
      before :all do
        UserSearch.instance_eval do
          scope :title_like, :key => :title, :require => true
        end
      end

      it "loops through scope methods and applies them to source" do
        User.should_receive(:title_like).and_return(User.scoped)
        User.should_receive(:name_like).and_return(User.scoped)

        query = UserSearch.new(:name => 'Jon Snow', :title => 'Wall Watcher')
        query.results
      end

      it "returns empty array if errors were added" do
        query = UserSearch.new
        query.results.should eq []
        query.errors.should_not be_empty
      end
    end
  end
end
