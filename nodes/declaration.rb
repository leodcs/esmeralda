module Nodes
  class Declaration < Node
    attr_reader :value, :type

    def initialize(value, type)
      @value = value
      @type = type
    end

    def debug
      [type.to_sym, value]
    end
  end
end
