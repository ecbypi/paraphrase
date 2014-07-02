require 'rails'

module Paraphrase
  class Railtie < Rails::Railtie
    initializer 'paraphrase.extend_active_record' do
      ActiveSupport.on_load :active_record do
        require 'paraphrase/syntax'

        extend Paraphrase::Syntax
      end
    end
  end
end
