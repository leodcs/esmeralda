module Nodes
  class Node
    attr_reader :nodes

    def initialize(nodes = [])
      if nodes.class == Array
        @nodes = nodes
      else
        @nodes = [nodes]
      end
    end

    def debug_name
      class_name = self.class.name

      if respond_to?(:value) && respond_to?(:type)
        "#{class_name} (#{value} - #{type})"
      elsif respond_to?(:value)
        "#{class_name} (#{value})"
      elsif respond_to?(:operator)
        "#{class_name} (#{operator})"
      else
        class_name
      end
    end
  end
end
