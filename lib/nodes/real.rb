module Nodes
  class Real
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def nodes
      []
    end
  end
end
