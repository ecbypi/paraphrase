require 'spec_helper'

module Paraphrase
  describe Query do
    let(:paraphrase) { UserParaphrase.new(:name => 'Jon Snow', :nickname => 'pretty') }

    it "removes params that were not added via `key`" do
      paraphrase.params.should_not have_key 'nickname'
    end

    describe ".paraphrase" do
      it "caches the class being queried" do
        UserParaphrase.source.should eq User
      end

      it "raises an error if class does not exist" do
        expect { UserParaphrase.paraphrases :Users }.to raise_error Paraphrase::SourceMissingError
      end
    end

    describe ".key" do
      it "registers a new attribute for the sublcass" do
        paraphrase.name.should eq 'Jon Snow'
      end

      it "adds information to :scope_keys" do
        UserParaphrase.scope_keys.should_not be_empty
      end
    end

  end
end
