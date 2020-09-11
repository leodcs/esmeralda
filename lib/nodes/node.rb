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
      object_name = "#{self.class.name}:#{object_id} \n"

      node_debug = case self.class.name.split('::').last
                   when 'Declaration'
                     "#{value} - #{type}"
                   when 'Program', 'Integer', 'Real', 'Identifier'
                     "#{value}"
                   when 'Operation'
                     "#{operator}"
                   when 'Assignment'
                     "#{assignment}"
                   when 'Call'
                     "#{method_name} (#{params.map(&:value).join(', ')})"
                   end

      return object_name + node_debug.to_s
    end
  end
end
