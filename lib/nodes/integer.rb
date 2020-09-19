module Nodes
  class Integer < Node
    attr_reader :type, :value

    def initialize(value, nodes = [])
      @type = :integer
      @value = value

      super(nodes)
    end
  end
end
