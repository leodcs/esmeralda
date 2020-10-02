module Nodes
  class Assignment < Node
    attr_reader :name

    def initialize(name, nodes = [])
      @name = name

      super(nodes)
    end

    def type
      if declaration.type == :real && first_node.type == :integer
        return :real
      else
        first_node.type
      end
    end

    def declaration
      $parse.declarations.find do |declaration|
        declaration.name.match == name.match
      end
    end

    private

    def first_node
      nodes.first
    end
  end
end
