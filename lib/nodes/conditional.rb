module Nodes
  class Conditional
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def debug
      expression
    end
  end
end
