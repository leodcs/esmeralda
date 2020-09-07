module Nodes
  class Assignment < Node
    attr_reader :assignment

    def initialize(assignment, nodes = [])
      @assignment = assignment

      super(nodes)
    end
  end
end
