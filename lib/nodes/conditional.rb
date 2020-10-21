module Nodes
  class Conditional < Node
    attr_reader :clause, :then_body, :else_body

    def initialize(clause, then_body, else_body, nodes = [])
      @clause = clause
      @then_body = then_body
      @else_body = else_body

      super(nodes)
    end
  end
end
