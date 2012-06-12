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

      it "defaults back to name passed in if not defined" do
        UserParaphrase.paraphrases :Users
        UserParaphrase.source.should eq :Users
      end

      after :all do
        UserParaphrase.paraphrases :User
      end
    end

    describe ".key" do
      it "registers a new attribute for the sublcass" do
        paraphrase.name.should eq 'Jon Snow'
      end
    end

    describe ".keys" do
      it "returns the registered param keys" do
        UserParaphrase.keys.should eq [:name]
      end
    end
  end
end
