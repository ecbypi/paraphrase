require 'rails'

module Paraphrase
  class Railtie < Rails::Railtie
    initializer 'paraphrase.extend_active_record' do
      ActiveSupport.on_load :active_record do
        extend Paraphrase::Syntax
        Relation.send(:include, Paraphrase::RelationMethods)
      end
    end
  end
end
