class Parser
  attr_reader :declarations

  def initialize(tokens)
    @tokens = tokens.dup
    @declarations = []
  end

  def parse
    # ignora_comentarios
    programa

    self
  end

  def root
    programa
  end

  private

  def peek(*expected_tokens)
    upcoming = @tokens[0, expected_tokens.size]

    if upcoming.map(&:type) == expected_tokens
      return upcoming
    end
  end

  def consume(expected_type)
    token = @tokens.shift

    if !token.nil? && token.type == expected_type
      return token
    elsif token.nil?
      # TODO: pegar linha e coluna para esse erro
      raise "Símbolo \"\" inesperado. Esperando #{expected_type} - Linha XX, Coluna YY."
    else
      raise "Símbolo #{token.match.inspect} inesperado. Esperando #{expected_type} - Linha #{token.linha}, Coluna #{token.coluna}."
    end
  end

  def programa
    @programa ||= bloco_principal
  end

  def bloco_principal
    consume(:PROGRAM)
    prog_name = consume(:ID).match
    consume(:PONTO_VIRGULA)

    declarations = parse_declarations
    @declarations += declarations

    consume(:BEGIN)
    bloco
    consume(:END)
    consume(:PONTO)

    return Nodes::Program.new(prog_name, declarations)
  end

  def bloco
    # TODO
  end

  def repeat(method)
    results = []

    while (result = send(method)) do
      results << result
    end

    return results
  end

  def parse_declarations
    repeat(:parse_declaration)
  end

  def parse_declaration
    return unless peek(:TIPO_VAR)

    var_names = []
    type = consume(:TIPO_VAR).match
    var_names << consume(:ID).match

    while peek(:VIRGULA) do
      consume(:VIRGULA)
      var_names << consume(:ID).match
    end

    consume(:PONTO_VIRGULA)

    return Nodes::Declaration.new(var_names, type)
  end
end
