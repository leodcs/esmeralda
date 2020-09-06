module Nodes
  class Program
    attr_reader :value, :nodes

    def initialize(value, nodes = [])
      @value = value
      @nodes = nodes
    end
  end
end
