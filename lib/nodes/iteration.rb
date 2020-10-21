module Nodes
  class Iteration < Node
    attr_reader :clause

    def initialize(clause, nodes = [])
      @clause = clause

      super(nodes)
    end
  end
end
