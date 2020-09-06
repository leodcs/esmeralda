module Nodes
  class Block
    attr_reader :nodes

    def initialize(nodes = [])
      @nodes = nodes
    end
  end
end
