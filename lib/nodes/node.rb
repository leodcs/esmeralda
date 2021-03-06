module Nodes
  class Node
    attr_reader :type, :nodes

    def initialize(nodes = [])
      if nodes.class == Array
        @nodes = nodes
      else
        @nodes = [nodes]
      end
    end

    def children
      children = nodes.dup
      children << children.map(&:children).flatten

      return children.flatten
    end

    def class_type
      self.class.name.split('::').last.underscore.to_sym
    end
  end
end
