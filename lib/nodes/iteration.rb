module Nodes
  class Iteration < Node
    attr_reader :expression

    def initialize(expression, nodes = [])
      @expression = expression

      super(nodes)
    end
  end
end
