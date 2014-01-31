require 'spec_helper'

module Paraphrase
  describe Query do
    class ::PostQuery < Paraphrase::Query
      map :title, :to => :titled
      map :is_published, :to => :published
      map :authors, :to => :by_users
      map :start_date, :end_date, :to => :published_between

      def start_date
        @start_date ||= Time.parse(params[:start_date]) rescue nil
      end

      def end_date
        @end_date ||= Time.parse(params[:end_date]) rescue nil
      end
    end

    describe ".map" do
      it "adds information to Query.scopes" do
        expect(PostQuery.scopes).not_to be_empty
      end

      it "raises an error if a scope is added twice" do
        expect { PostQuery.map :name, :to => :titled }.to raise_error Paraphrase::DuplicateScopeError
      end

      it 'defines readers for each key' do
        query = PostQuery.new

        expect(query).to respond_to :title
        expect(query).to respond_to :is_published
        expect(query).to respond_to :authors
      end
    end

    after do
      Post.delete_all
      User.delete_all
    end

    describe '#source' do
      it 'is determined via query class name' do
        expect(PostQuery.new.result).to eq Post
      end

      it 'can be manually specified in the class' do
        klass = Class.new(Query) do
          source :User
        end

        expect(klass.new.result).to eq User
      end
    end

    describe '#[]' do
      it 'retreives values from #params or uses custom reader if defined' do
        query = PostQuery.new(title: 'Morning Joe', start_date: '2010-10-30', end_date: 'foo')

        expect(query[:title]).to eq 'Morning Joe'
        expect(query[:start_date]).to eq Time.local(2010, 10, 30)
        expect(query[:end_date]).to be_nil
      end
    end

    describe "#params" do
      it "filters out params not specified in scopes" do
        query = PostQuery.new(nickname: 'bill', title: 'william')

        expect(query.params).not_to have_key :nickname
        expect(query.params).to have_key :title
      end

      it "sets up params with indifferent access" do
        query = PostQuery.new(title: 'D3 How-To')
        expect(query.params).to have_key 'title'
      end

      it 'recursively filters out blank values' do
        query = PostQuery.new(title: { key: ['', { key: [] }, []] }, authors: ['', 'kevin', ['', {}], { key: [' '] }])

        expect(query.params[:authors]).to eq ['kevin']
        expect(query.params).not_to have_key :title
      end
    end

    it 'skips scopes if query params are missing' do
      expect(Post).not_to receive(:published_between)
      expect(Post).not_to receive(:titled)
      expect(Post).not_to receive(:by_users)
      expect(Post).to receive(:published)

      PostQuery.new(
        start_date: Time.local(2010, 10, 30),
        end_date: 'foo',
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

      expect(query).to include red_post
      expect(query).not_to include blue_post
      expect(query).not_to include green_post
    end
  end
end
