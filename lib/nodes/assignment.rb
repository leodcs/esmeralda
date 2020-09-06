module Nodes
  class Assignment
    attr_reader :nodes

    def initialize(nodes = [])
      @nodes = nodes
    end
  end
end
