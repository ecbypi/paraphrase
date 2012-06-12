require 'spec_helper'

module Paraphrase
  describe Query do
    let(:paraphrase) { UserParaphrase.new(:name => 'Jon Snow', :nickname => 'pretty') }

    it "removes params that were not added via `key`" do
      paraphrase.params.should_not have_key 'nickname'
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
