require 'spec_helper'

module Paraphrase
  describe Syntax do
    describe ".register_mapping" do
      it "creates new sublcass of Query" do
        Account.register_mapping {}
        Account.paraphraser.should_not be_nil
      end
    end
  end
end
