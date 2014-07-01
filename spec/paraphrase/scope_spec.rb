require 'spec_helper'

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

    describe "#chain" do
      let(:default_relation) do
        ActiveRecord::VERSION::MAJOR > 3 ? Account.all : Account.scoped
      end

      it "applies scope method to relation with values from params hash" do
        scope = build_account_scope

        expect(Account).to receive(:name_like).with('Jon Snow')
        scope.chain({ name: 'Jon Snow' }, default_relation)
      end

      it "does nothing if values are missing" do
        scope = build_account_scope

        expect(Account).not_to receive(:name_like)
        scope.chain({}, default_relation)
      end

      it "passes through blank values if scope has been whitelisted" do
        scope = build_account_scope(whitelist: true)

        expect(Account).to receive(:name_like).with(nil)
        scope.chain({}, default_relation)
      end

      it 'allows whitelisting a subset of keys' do
        scope = build_account_scope(
          keys: [:name, :status],
          to: :with_name_and_status,
          whitelist: true
        )

        expect(Account).to receive(:with_name_and_status).with('George', nil)

        scope.chain({ name: 'George' }, default_relation)
      end
    end
  end
end
