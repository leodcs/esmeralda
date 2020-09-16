module Nodes
  class Conditional < Node
    attr_reader :then_body, :else_body

    def initialize(then_body, else_body, nodes = [])
      @then_body = then_body
      @else_body = else_body

      super(nodes)
    end
  end
end
