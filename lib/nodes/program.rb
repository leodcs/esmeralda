module Nodes
  class Program < Node
    attr_reader :name

    def initialize(name, nodes = [])
      @name = name

      super(nodes)
    end
  end
end
