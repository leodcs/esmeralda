module Nodes
  class Node
    attr_reader :nodes

    def initialize(nodes = [])
      @nodes = nodes
    end

    def debug
      value
    end
  end
end
