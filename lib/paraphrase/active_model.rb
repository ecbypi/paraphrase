require 'active_support/concern'
require 'active_model/naming'

module Paraphrase
  module ActiveModel
    extend ActiveSupport::Concern

    def to_key
      [:q]
    end

    def to_model
      self
    end

    def to_param
      params.to_param
    end

    def persisted?
      true
    end

    module ClassMethods
      def model_name
        ::ActiveModel::Name.new(self, nil, 'Q')
      end
    end
  end
end
