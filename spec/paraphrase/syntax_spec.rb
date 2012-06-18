require 'spec_helper'

module Paraphrase
  describe Syntax do
    describe ".register_mapping" do
      it "forwards to Paraphrase.register" do
        Paraphrase.should_receive(:register).with(:account)
        Account.register_mapping {}
      end
    end

    describe ".paraphrase" do
      it "forwards to Paraphrase.query" do
        Paraphrase.should_receive(:query).with(:account, {})
        Account.paraphrase({})
      end
    end
  end
end
