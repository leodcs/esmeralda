module Nodes
  class Conditional
    attr_reader :nodes

    def initialize(nodes = [])
      @nodes = nodes
    end
  end
end
