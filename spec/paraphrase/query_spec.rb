require 'spec_helper'
require 'action_view/test_case'

module Paraphrase
  describe Query do
    class ::PostQuery < Paraphrase::Query
      map :title, to: :titled
      map :is_published, to: :published
      map :authors, to: :by_users
      map :start_date, :end_date, to: :published_between

      class ParamsFilter
        def start_date
          Time.parse(params[:start_date]) rescue nil
        end
      end

      class Repository
        def published_between(start_date, end_date)
          where(published_at: start_date..end_date)
        end
      end

      param :end_date do
        Time.parse(params[:end_date]) rescue nil
      end

      scope :by_users do |authors|
        relation.joins(:user).where(users: { name: authors })
      end
    end

    describe ".map" do
      it "adds information to Query.scopes" do
        expect(PostQuery.mappings).not_to be_empty
      end

      it "raises an error if a scope is added twice" do
        expect { PostQuery.map :name, to: :titled }.to raise_error Paraphrase::DuplicateMappingError
      end

      it 'defines readers for each key' do
        query = PostQuery.new(Hash.new)

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
        expect(PostQuery.source).to eq 'Post'
      end

      it 'can be manually specified in the class' do
        klass = Class.new(Query) do
          self.source = :User
        end

        expect(klass.source).to eq :User
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

    it 'supports defining scopes in the query class' do
      robert = User.create!(name: 'Robert')
      frank = User.create!(name: 'Frank')
      susie = User.create!(name: 'Susie')

      # Combination of all three attributes ensures that the scope is preserved
      # before and after the call to the method on the query class
      Post.create!(title: 'Summer', published: false, user: robert)
      Post.create!(title: 'Summer', published: true, user: frank)
      susie_post = Post.create!(title: 'Summer', published: true, user: susie)

      params = { authors: ['Robert', 'Susie'], title: 'Summer', is_published: '1' }
      query = PostQuery.new(params)
      result = Post.paraphrase(params)

      expect(query.result).to eq [susie_post]
      expect(result).to eq [susie_post]
    end

    it 'preserves the original scope used to initialize the query' do
      user = User.create!
      blue_post = Post.create!(user: user, title: 'Blue', published: false)
      red_post = Post.create!(user: user, title: 'Red', published: true)
      green_post = Post.create!(title: 'Red', published: true)

      result = PostQuery.new({ title: 'Red' }, user.posts.published).result

      expect(result).to include red_post
      expect(result).not_to include blue_post
      expect(result).not_to include green_post
    end

    describe 'is action view compliant' do
      it 'by working with form builders' do
        router = ActionDispatch::Routing::RouteSet.new
        router.draw do
          resources :posts
        end

        controller = ActionView::TestCase::TestController.new
        controller.instance_variable_set(:@_routes, router)
        controller.class_eval { include router.url_helpers }
        controller.view_context.class_eval { include router.url_helpers }

        query = PostQuery.new(title: 'Red', start_date: '2012-10-01')

        markup = ""
        controller.view_context.form_for query, url: router.url_helpers.posts_path do |f|
          markup << f.text_field(:title)
          markup << f.date_select(:start_date)
        end

        expect(markup).to match(/<input.*type="text"/)
        expect(markup).to match(/type="text"/)
        expect(markup).to match(/name="q\[title\]"/)
        expect(markup).to match(/value="Red"/)

        expect(markup).to match(/<select.*name="q\[start_date\(1i\)/)
        expect(markup).to match(/<select.*name="q\[start_date\(2i\)/)
        expect(markup).to match(/<select.*name="q\[start_date\(3i\)/)

        expect(markup).to match(/<option.*selected="selected" value="2012"/)
        expect(markup).to match(/<option.*selected="selected" value="10"/)
        expect(markup).to match(/<option.*selected="selected" value="1"/)
      end
    end
  end
end
