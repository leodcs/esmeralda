module Nodes
  class Identifier < Node
    attr_reader :value

    def initialize(value, nodes = [])
      @value = value
    end
  end
end
