module Nodes
  class Call < Node
    attr_reader :method_name, :params

    def initialize(method_name, params = [], nodes = [])
      @method_name = method_name
      @params = params

      super(nodes)
    end

    def param_type
      case method_name.match.upcase
      when 'ALL'
        return :string
      end
    end

    def invalid_params
      params.select { |param| self.param_type != param.type }
    end
  end
end
