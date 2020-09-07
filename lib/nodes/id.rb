module Nodes
  class Id < Node
    attr_reader :value

    def initialize(value, nodes = [])
      @value = value
    end
  end
end
