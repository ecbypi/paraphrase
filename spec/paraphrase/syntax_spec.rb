require 'spec_helper'

module Paraphrase
  describe Syntax do
    class ::AccountQuery < Paraphrase::Query
      map :name, to: :named
    end

    describe '.paraphrase' do
      it "passes through results from an initialized query" do
        expect_any_instance_of(AccountQuery).to receive(:result).and_call_original

        result = Account.paraphrase
        expect(result).to eq Account.all
      end

      it 'raises if query class is not defined' do
        expect { User.paraphrase }.to raise_error Paraphrase::NoQueryDefined
      end

      it "works on instances of `ActiveRecord::Relation`, preserving existing filters" do
        user = User.create!
        Account.create!(user: user)
        Account.create!(name: 'Sophie')
        account = Account.create!(name: 'Sophie', user: user)

        result = user.accounts.paraphrase(name: 'Sophie')

        expect(result).to eq [account]
      end
    end
  end
end
