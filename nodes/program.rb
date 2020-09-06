module Nodes
  class Program < Node
    attr_reader :value

    def initialize(value, nodes = [])
      @value = value
      @nodes = nodes
    end
  end
end
