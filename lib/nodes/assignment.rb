module Nodes
  class Assignment < Node
    attr_reader :name

    def initialize(name, nodes = [])
      @name = name

      super(nodes)
    end

    def type
      nodes.first.type
    end

    def declaration
      $parse.declarations.find do |declaration|
        declaration.name.match == name.match
      end
    end

    def identifiers
      children.select { |child| child.class == ::Nodes::Identifier }
    end
  end
end
