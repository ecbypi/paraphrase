require 'spec_helper'

module Paraphrase
  describe Query do

    describe ".paraphrases" do
      it "stores the class being queried" do
        UserSearch.paraphrases :user
        UserSearch.source.should eq User.scoped
      end

      it "registers the query in Paraphrase.querys" do
        Paraphrase.mapping(:user).should eq UserSearch
      end
    end

    describe ".scope" do
      it "adds information to Query.scopes" do
        UserSearch.instance_eval do
          scope :name_like, :key => :name
        end

        UserSearch.scopes.should_not be_empty
      end
    end
  end
end
