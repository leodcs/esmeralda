module Nodes
  class Declaration < Node
    attr_reader :name, :type

    def initialize(name, type, nodes = [])
      @name = name
      @type = type.match.downcase.to_sym

      super(nodes)
    end

    def aceita_tipo?(tipo)
      if (self.type == :real) && (tipo == :integer)
        return true
      else
        return (tipo == self.type)
      end
    end
  end
end
