module Nodes
  class Call < Node
    attr_reader :method_name, :params

    def initialize(method_name, params = [], nodes = [])
      @method_name = method_name
      @params = params

      super(nodes)
    end
  end
end
