require 'spec_helper'

module Paraphrase
  describe Syntax do
    describe ".register_mapping" do
      it "forwards to Paraphrase.register" do
        Account.register_mapping {}
        Paraphrase[:Account].should_not be_nil
      end

      it "adds itself as the source for the new mapping class" do
        Paraphrase[:Account].source.should eq Account
      end
    end

    describe ".paraphrase" do
      it "forwards to Paraphrase.query" do
        Paraphrase.should_receive(:query).with(:Account, {})
        Account.paraphrase({})
      end
    end
  end
end
