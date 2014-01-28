require 'spec_helper'
require 'support/models/account'

module Paraphrase
  describe Scope do
    def build_account_scope(options = {})
      options.reverse_merge!(
        keys: [:name],
        to: :name_like
      )

      keys = options.delete(:keys)

      Scope.new(keys, options)
    end

    # NOTE: This is unfortunately necessary until a cleaner API is determined
    # or `Model.scoped` is no more. The intended API is to initialize a `Query`
    # with an `ActiveRecord::Relation` so `Scope` instances should always
    # receive a relation in `#chain`.
    def account_relation
      ActiveRecord::VERSION::MAJOR > 3 ? Account.all : Account.scoped
    end

    describe "#chain" do
      it "applies scope method to relation with values from params hash" do
        scope = build_account_scope

        Account.should_receive(:name_like).with('Jon Snow')
        scope.chain({ :name => 'Jon Snow' }, account_relation)
      end

      it "does nothing if values are missing" do
        scope = build_account_scope

        Account.should_not_receive(:name_like)
        scope.chain({}, account_relation)
      end

      it "passes through blank values if scope has been whitelisted" do
        scope = build_account_scope(whitelist: true)

        Account.should_receive(:name_like).with(nil)
        scope.chain({}, account_relation)
      end

      it 'allows whitelisting a subset of keys' do
        scope = build_account_scope(
          keys: [:name, :status],
          to: :with_name_and_status,
          whitelist: true
        )

        Account.should_receive(:with_name_and_status).with('George', nil)

        scope.chain({ name: 'George' }, account_relation)
      end
    end
  end
end
