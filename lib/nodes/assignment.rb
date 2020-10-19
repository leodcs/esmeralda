module Nodes
  class Assignment < Node
    attr_reader :name

    def initialize(name, nodes = [])
      @name = name

      super(nodes)
    end

    def type
      if declaration.type == :real && nodes.first.type == :integer
        return :real
      else
        nodes.first.type
      end
    end

    def declaration
      $parse.declarations.find do |declaration|
        declaration.name.match == name.match
      end
    end
  end
end
