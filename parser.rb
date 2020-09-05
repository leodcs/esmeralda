class Parser
  def initialize(tokens)
    @tokens = tokens.dup
    @nodes = []
  end

  def parse
    parse_prog

    return @nodes
  end

  private

  def parse_prog
    consume(:program)
    prog_name = consume(:id).match
    consume(:ponto_virgula)
    # parse_prog_body
    # consume(:end)
    # consume(:ponto)
    @nodes << RootNode.new(prog_name)
  end

  def consume(expected_type)
    token = @tokens.shift

    if token.type.downcase == expected_type.downcase
      return token
    else
      raise "Símbolo #{token.match} inesperado. Esperando #{expected_type} - Linha #{token.linha}, Coluna #{token.coluna}."
    end
  end
end
