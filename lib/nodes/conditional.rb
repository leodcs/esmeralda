module Nodes
  class Conditional < Node
    attr_reader :if_body, :else_body

    def initialize(if_body, else_body, nodes = [])
      @if_body = if_body
      @else_body = else_body
      super(nodes)
    end
  end
end
