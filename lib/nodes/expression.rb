module Nodes
  class Expression
    attr_reader :operator, :nodes

    def initialize(operator, nodes = [])
      @operator = operator
      @nodes = nodes
    end
  end
end
