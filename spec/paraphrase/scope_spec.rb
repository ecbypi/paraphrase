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
      it "applies scope method to relation with values from params hash" do
        scope = build_account_scope

        expect(Account).to receive(:name_like).with('Jon Snow')
        scope.chain({ :name => 'Jon Snow' }, Account)
      end

      it "does nothing if values are missing" do
        scope = build_account_scope

        expect(Account).not_to receive(:name_like)
        scope.chain({}, Account)
      end

      it "passes through blank values if scope has been whitelisted" do
        scope = build_account_scope(whitelist: true)

        expect(Account).to receive(:name_like).with(nil)
        scope.chain({}, Account)
      end

      it 'allows whitelisting a subset of keys' do
        scope = build_account_scope(
          keys: [:name, :status],
          to: :with_name_and_status,
          whitelist: true
        )

        expect(Account).to receive(:with_name_and_status).with('George', nil)

        scope.chain({ name: 'George' }, Account)
      end
    end
  end
end
