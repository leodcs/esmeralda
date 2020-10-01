module Nodes
  class Identifier < Node
    attr_reader :name

    def initialize(name, nodes = [])
      @name = name

      super(nodes)
    end

    def type
      if assignment && assignment.name.match == name.match
        return assignment.type
      elsif declaration
        return declaration.type
      end
    end

    def declaration
      $parse.declarations.find do |declaration|
        self.name.match == declaration.name.match
      end
    end

    def assignment
      $parse.assignments.find do |assignment|
        self.name.match == assignment.name.match
      end
    end
  end
end
