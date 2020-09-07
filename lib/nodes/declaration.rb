module Nodes
  class Declaration < Node
    attr_reader :value, :type

    def initialize(value, type, nodes = [])
      @value = value
      @type = type

      super(nodes)
    end
  end
end
