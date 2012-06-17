require 'spec_helper'

module Paraphrase
  describe Query do
    let(:query) { UserSearch.new(:last_name => 'Snow', :first_name => 'Jon', :nickname => 'pretty') }

    describe ".paraphrase" do
      it "caches the class being queried" do
        UserSearch.source.should eq User
      end

      it "registers the query in Paraphrase.querys" do
        Paraphrase.mappings[:User].should_not be_nil
      end

      it "can specify alias for Paraphrase.querys" do
        UserSearch.paraphrases :User, :as => :accounts

        Paraphrase.mappings[:accounts].should_not be_nil
      end

      it "raises an error if class does not exist" do
        expect { UserSearch.paraphrases :Users }.to raise_error Paraphrase::SourceMissingError
      end
    end

    describe ".key" do
      it "adds information to :scope_keys" do
        UserSearch.scopes.should_not be_empty
      end
    end

    describe "#results" do
      it "applies scopes to source preserving order of keys" do
        User.should_receive(:name_like).with('Jon Snow')
        query.results
      end

      it "caches the result" do
        query.results
        User.should_not_receive(:name_like)
        query.results
      end

      it "does not apply scopes if value is not present" do
        User.should_not_receive(:title_like)
        query.results
      end

      it "fills in results attribute" do
        query.results.should_not be_nil
      end

      it "returns empty array if required attribute is nil" do
        UserSearch.new.results.should eq []
      end
    end
  end
end
