module Nodes
  class Expression
    attr_reader :nodes

    def initialize(nodes = [])
      @nodes = nodes
    end
  end
end
