module Paraphrase
  class Repository
    attr_reader :relation, :mapping, :params

    def self.chain(relation, mapping, params)
      new(relation, mapping, params).chain
    end

    def initialize(relation, mapping, params)
      @relation, @mapping, @params = relation, mapping, params
    end

    def chain
      if mapping.satisfied?(params)

        if scope.arity.zero?
          relation.scoping { scope.call }
        else
          values = mapping.values(params)
          relation.scoping { scope.call(*values) }
        end
      else
        relation
      end
    end

    def scope
      @scope ||=
        if respond_to?(mapping.name)
          method(mapping.name)
        else
          relation.klass.method(mapping.name)
        end
    end
  end
end
