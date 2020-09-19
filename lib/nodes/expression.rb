module Nodes
  class Expression < Node
    attr_reader :operator

    def initialize(operator, nodes = [])
      @operator = operator

      super(nodes)
    end

    def type
      return :real if operator.match == '/'

      children_types = children.map(&:type).compact.uniq

      if children_types.any?(:real)
        return :real
      elsif children_types.all?(:integer)
        return :integer
      end
    end
  end
end
