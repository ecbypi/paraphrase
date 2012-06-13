require 'spec_helper'

module Paraphrase
  describe MappingSet do
    let(:mapping) { UserMapping.new(:name => 'Jon Snow', :nickname => 'pretty') }

    it "removes params that were not added via `key`" do
      mapping.params.should_not have_key 'nickname'
    end

    describe ".paraphrase" do
      it "caches the class being queried" do
        UserMapping.source.should eq User
      end

      it "raises an error if class does not exist" do
        expect { UserMapping.paraphrases :Users }.to raise_error Paraphrase::SourceMissingError
      end
    end

    describe ".key" do
      it "registers a new attribute for the sublcass" do
        mapping.name.should eq 'Jon Snow'
      end

      it "adds information to :scope_keys" do
        UserMapping.scope_keys.should_not be_empty
      end
    end

  end
end
