# frozen_string_literal: true

module Nodes
  class Real < Node
    attr_reader :type, :value

    def initialize(value, nodes = [])
      @type = :real
      @value = value

      super(nodes)
    end
  end
end
