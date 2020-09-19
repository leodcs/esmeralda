module Nodes
  class Declaration < Node
    attr_reader :name, :type

    def initialize(name, type, nodes = [])
      @name = name
      @type = type.match.downcase.to_sym

      super(nodes)
    end

    def aceita_tipo?(assignment_type)
      if self.type == :real && assignment_type == :integer
        return true
      else
        return assignment_type == type
      end
    end
  end
end
