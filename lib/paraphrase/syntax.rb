module Paraphrase
  module Syntax
    module Base
      # Attempts to find paraphrase class based on class name.  Override if
      # using a different naming convention.
      def paraphraser
        "#{self.name}Query".safe_constantize
      end

      # Instantiate the {Query} class that is mapped to `self`.
      #
      # @param [Hash] params query parameters
      def paraphrase(params)
        self.paraphraser.new(params, self)
      end
    end

    module Relation
      # Creates a paraphrase {Query query}, supplying `self` as the base for the
      # query. Intended for scoping a query from an association:
      #
      # Given the following models:
      #
      # ```ruby
      # class User < ActiveRecord::Base
      #   has_many :posts
      # end
      #
      # class Post < ActiveRecord::Base
      #   belongs_to :user
      #
      #   register_mapping
      #     map :title_like, :to => :title
      #   end
      # end
      # ```
      #
      # It is possible to do the following:
      #
      # ```ruby
      # user.posts.paraphrase({ :title => 'Game of Thrones Finale' }).to_sql
      # # => SELECT `posts`.* FROM `posts` INNER JOIN `users` ON `users`.`post_id` = `posts`.`id` WHERE `posts`.`title LIKE "%Game of Thrones Finale%";
      # ```
      #
      # @param [Hash] params query params
      # @return [Paraphrase::Query]
      def paraphrase(params)
        klass.paraphraser.new(params, self)
      end
    end
  end
end
