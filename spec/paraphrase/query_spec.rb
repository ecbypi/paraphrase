require 'spec_helper'
require 'support/models/post'
require 'support/models/user'

module Paraphrase
  describe Query do
    class ::PostQuery < Paraphrase::Query
      map :titled, :to => :title
      map :published, :to => :is_published
    end

    describe ".map" do
      it "adds information to Query.mappings" do
        PostQuery.mappings.should_not be_empty
      end

      it "raises an error if a scope is added twice" do
        expect { PostQuery.map :titled, :to => :name }.to raise_error Paraphrase::DuplicateScopeError
      end
    end

    describe '#source' do
      it 'is determined via query class name' do
        PostQuery.new({}).relation.klass.should eq Post
      end

      it 'can be manually specified in the class' do
        klass = Class.new(Query) do
          source :User
        end

        klass.new({}).relation.klass.should eq User
      end
    end

    describe "on initialization" do
      it "filters out params not specified in mappings" do
        query = PostQuery.new(nickname: 'bill', title: 'william')

        query.params.should_not have_key :nickname
        query.params.should have_key :title
      end

      it "sets up params with indifferent access" do
        query = PostQuery.new(title: 'D3 How-To')
        query.params.should have_key 'title'
      end

      it 'filters out blank values' do
        query = PostQuery.new(title: '')

        query.params.should_not have_key :title
      end
    end

    describe "#results" do
      it "loops through scope methods and applies them to source" do
        Post.should_receive(:titled).and_call_original
        Post.should_receive(:published)

        query = PostQuery.new(:title => 'Cooking Eggs', :is_published => true)
        query.results
      end

      it "skips scopes if the params for the scope are missing" do
        Post.should_not_receive(:titled)
        Post.should_not_receive(:published)

        query = PostQuery.new({})
        query.results
      end

      it "preserves the relation passed in during initialization" do
        user = User.create!
        post = Post.create!(user: user, title: 'Red')
        Post.create!(user: user, title: 'Blue')
        Post.create!(title: 'Red')

        query = PostQuery.new({ :title => 'Red' }, user.posts)
        results = query.results

        results.to_a.should eq [post]
      end
    end
  end
end
