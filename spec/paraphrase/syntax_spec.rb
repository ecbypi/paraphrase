require 'spec_helper'

module Paraphrase
  describe Syntax do
    describe ".register_mapping" do
      it "forwards to Paraphrase.register" do
        ::Account.register_mapping {}
        Paraphrase.mapping(:account).should_not be_nil
      end

      it "updates scopes if already registered" do
        ::Account.register_mapping do
          scope :name_like, :key => :name
        end

        mapping = Paraphrase.mapping(:account)
        mapping.scopes.should_not be_empty
      end
    end

    describe ".paraphrase" do
      it "forwards to Paraphrase.query" do
        Paraphrase.should_receive(:query).with('account', {})
        ::Account.paraphrase({})
      end
    end
  end
end
