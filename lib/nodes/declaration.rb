module Nodes
  class Declaration
    attr_reader :value, :type

    def initialize(value, type)
      @value = value
      @type = type
    end
  end
end
