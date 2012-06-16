require 'spec_helper'

module Paraphrase
  describe MappingSet do
    let(:mapping) { UserMapping.new(:last_name => 'Snow', :first_name => 'Jon', :nickname => 'pretty') }

    describe ".paraphrase" do
      it "caches the class being queried" do
        UserMapping.source.should eq User
      end

      it "registers the mapping in Paraphrase.mappings" do
        Paraphrase.mappings[:User].should_not be_nil
      end

      it "raises an error if class does not exist" do
        expect { UserMapping.paraphrases :Users }.to raise_error Paraphrase::SourceMissingError
      end
    end

    describe ".key" do
      it "adds information to :scope_keys" do
        UserMapping.scope_keys.should_not be_empty
      end
    end

    describe "#results" do
      it "applies scopes to source preserving order of keys" do
        User.should_receive(:name_like).with('Jon', 'Snow')
        mapping.results
      end

      it "caches the result" do
        mapping.results
        User.should_not_receive(:name_like)
        mapping.results
      end

      it "does not apply scopes if value is not present" do
        User.should_not_receive(:title_like)
        mapping.results
      end

      it "fills in results attribute" do
        mapping.results.should_not be_nil
      end

      it "returns empty array if required attribute is nil" do
        UserMapping.new.results.should eq []
      end
    end
  end
end
