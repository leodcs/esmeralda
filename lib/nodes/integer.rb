module Nodes
  class Integer < Node
    attr_reader :value

    def initialize(value, nodes = [])
      @value = value

      super(nodes)
    end
  end
end
