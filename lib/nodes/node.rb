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

    def leaf?
      nodes.empty?
    end

    def leafs
      return self if leaf?

      return nodes.map(&:leafs).flatten
    end

    def children
      children = nodes.dup
      children << children.map(&:children).flatten

      return children.flatten
    end

    def debug_name
      object_name = "#{self.class.name}:#{object_id} \n"

      node_debug = case self.class.name.split('::').last
                   when 'Declaration'
                     "#{name.match} (#{type})"
                   when 'Program', 'Identifier'
                     name.match
                   when 'Integer', 'Real'
                     value.match
                   when 'Operation', 'Expression'
                     operator.match
                   when 'Assignment'
                     "#{name.match} (#{type})"
                   when 'Call'
                     "#{method_name.match} (#{params.map(&:name).map(&:match).join(', ')})"
                   end

      return object_name + node_debug.to_s
    end
  end
end
