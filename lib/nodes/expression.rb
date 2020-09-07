module Nodes
  class Expression < Node
    attr_reader :operator

    def initialize(operator, nodes = [])
      @operator = operator

      super(nodes)
    end
  end
end
