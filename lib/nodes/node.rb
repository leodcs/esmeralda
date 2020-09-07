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
      object_name = "#{self.class.name}:#{object_id}"

      if respond_to?(:value) && respond_to?(:type)
        "#{object_name} \n (#{value} - #{type})"
      elsif respond_to?(:value)
        "#{object_name} \n (#{value})"
      elsif respond_to?(:operator)
        "#{object_name} \n (#{operator})"
      else
        object_name
      end
    end
  end
end
