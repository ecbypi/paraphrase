require 'spec_helper'
require 'support/models/post'
require 'support/models/user'

module Paraphrase
  describe Query do
    class ::PostQuery < Paraphrase::Query
      map :titled, :to => :title
      map :published, :to => :is_published
      map :by_users, :to => :authors
    end

    describe ".map" do
      it "adds information to Query.mappings" do
        PostQuery.mappings.should_not be_empty
      end

      it "raises an error if a scope is added twice" do
        expect { PostQuery.map :titled, :to => :name }.to raise_error Paraphrase::DuplicateScopeError
      end
    end

    after do
      Post.delete_all
      User.delete_all
    end

    describe '#source' do
      it 'is determined via query class name' do
        PostQuery.new.relation.klass.should eq Post
      end

      it 'can be manually specified in the class' do
        klass = Class.new(Query) do
          source :User
        end

        klass.new.relation.klass.should eq User
      end
    end

    describe "#params" do
      it "filters out params not specified in mappings" do
        query = PostQuery.new(nickname: 'bill', title: 'william')

        query.params.should_not have_key :nickname
        query.params.should have_key :title
      end

      it "sets up params with indifferent access" do
        query = PostQuery.new(title: 'D3 How-To')
        query.params.should have_key 'title'
      end

      it 'recursively filters out blank values' do
        query = PostQuery.new(title: { key: ['', { key: [] }, []] }, authors: ['', 'kevin', ['', {}], { key: [' '] }])

        query.params[:authors].should eq ['kevin']
        query.params.should_not have_key :title
      end
    end

    it 'skips scopes if query params are missing' do
      Post.should_not_receive(:titled)
      Post.should_not_receive(:by_users)
      Post.should_receive(:published)

      PostQuery.new(
        is_published: '1',
        authors: [],
        title: ['', {}]
      )
    end

    it 'preserves the original scope used to initialize the query' do
      user = User.create!
      blue_post = Post.create!(user: user, title: 'Blue', published: false)
      red_post = Post.create!(user: user, title: 'Red', published: true)
      green_post = Post.create!(title: 'Red', published: true)

      query = PostQuery.new({ title: 'Red' }, user.posts.published)

      query.should include red_post
      query.should_not include blue_post
      query.should_not include green_post
    end

    it 'can have additional scopes chained' do
      post = Post.create!(published: true, title: 'Red')
      Post.create!(published: false, title: 'Red')

      query = PostQuery.new(title: 'Red').published

      query.to_a.should eq [post]
    end
  end
end
