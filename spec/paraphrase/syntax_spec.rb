require 'spec_helper'

module Paraphrase
  module Syntax
    describe Base do
      describe "#register_mapping" do
        it "creates new sublcass of Query" do
          Account.register_mapping {}
          Account._paraphraser.should_not be_nil
        end
      end
    end
  end
end
