require 'spec_helper'

module Paraphrase
  describe Scope do

    # NOTE: This is unfortunately necessary until a cleaner API is determined
    # or `Model.scoped` is no more. The intended API is to initialize a `Query`
    # with an `ActiveRecord::Relation` so `Scope` instances should always
    # receive a relation in `#chain`.
    def accounts_relation
      ActiveRecord::VERSION::MAJOR > 3 ? Account.all : Account.scoped
    end

    describe "#chain" do
      let(:scope) { Scope.new([:name], :to => :name_like) }

      it "applies scope method to relation with values from params hash" do
        Account.should_receive(:name_like).with('Jon Snow')

        scope.chain({ :name => 'Jon Snow' }, accounts_relation)
      end

      it "does nothing if values are missing" do
        Account.should_not_receive(:name_like).with('Jon Snow')

        scope.chain({}, accounts_relation)
      end

      it "passes through nil values if scope has been whitelisted" do
        scope = Scope.new([:name], :to => :name_like, :whitelist => true)

        Account.should_receive(:name_like).with(nil)

        scope.chain({}, accounts_relation)
      end
    end

    describe "compound keys" do
      let(:compound_scope) do
        Scope.new([:first_name, :last_name], :to => :name_like, :require => :last_name)
      end

      it "can require a subset of a compound key" do
        Account.should_receive(:name_like).with(nil, 'Lannister')

        compound_scope.chain({ :last_name => 'Lannister' }, accounts_relation)
      end

      it "whitelists the the non-required keys of a compound key" do
        compound_scope.whitelist.include?(:first_name).should be_true
      end
    end
  end
end
