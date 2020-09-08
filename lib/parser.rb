class Parser
  attr_reader :declarations

  def initialize(tokens)
    @tokens = tokens.dup
    @declarations = []
  end

  def parse
    # Parsing starts here

    # TODO: metodo para ignorar comentarios (antes de comecar o parsing)
    programa

    self
  end

  def root
    programa
  end

  private

  def programa
    @programa ||= bloco_principal
  end

  def bloco_principal
    consome(:PROGRAM)
    prog_name = consome(:ID).match
    consome(:PONTO_VIRGULA)

    declarations = declaracoes
    @declarations += declarations

    consome(:BEGIN)
    body = bloco
    consome(:END)
    consome(:PONTO)

    nodes = declarations + [body]
    return Nodes::Program.new(prog_name, nodes)
  end

  def bloco
    consome(:BEGIN)
    nodes = comandos
    consome(:END)
    consome(:PONTO_VIRGULA)

    return Nodes::Block.new(nodes)
  end

  def comandos
    repete(:comando)
  end

  def comando
    comando_basico || condicional
  end

  def comando!
    obrigatorio(:comando, [:ID, :WHILE, :REPEAT, :IF])
  end

  def condicional
    return unless proximo?(:IF)

    nodes = []
    consome(:IF)
    consome(:ABRE_PAREN)
    if_body = expr_relacional
    nodes << if_body
    consome(:FECHA_PAREN)
    consome(:THEN)

    nodes << comando!

    else_body = nil
    if proximo?(:ELSE)
      consome(:ELSE)
      else_body = comando!
      nodes << else_body
    end

    return Nodes::Conditional.new(if_body, else_body, nodes)
  end

  def expr_relacional
    # TODO: segunda parte da gramatica
    nodes = []
    nodes << val!
    operador = consome(:OP_RELACIONAL).match
    nodes << val!

    return Nodes::Expression.new(operador, nodes)
  end

  def val
    id || integer || real
  end

  def val!
    obrigatorio(:val, [:ID, :INTEGER, :REAL])
  end

  def id
    if proximo?(:ID)
      value = consome(:ID).match
      return Nodes::Id.new(value)
    end
  end

  def integer
    if proximo?(:INTEGER)
      value = consome(:INTEGER).match
      return Nodes::Integer.new(value)
    end
  end

  def real
    if proximo?(:REAL)
      value = consome(:REAL).match
      return Nodes::Real.new(value)
    end
  end

  def comando_basico
    atribuicao # || bloco || All ( <id>  [, <id>]* );
  end

  def atribuicao
    return unless proximo?(:ID, :DPI)

    identifier = consome(:ID).match
    consome(:DPI)
    nodes = expr_arit!
    consome(:PONTO_VIRGULA)

    return Nodes::Assignment.new(identifier, nodes)
  end

  def atribuicao!
    obrigatorio(:atribuicao, [:ID])
  end

  def expr_arit!
    obrigatorio(:expr_arit, [:ID, :INTEGER, :REAL, :ABRE_PAREN])
  end

  def expr_arit
    multi_arit || op_arit || val
  end

  def op_arit
    if proximo?(:ID, :OP_ARITMETICO) || proximo?(:INTEGER, :OP_ARITMETICO) || proximo?(:REAL, :OP_ARITMETICO)
      nodes = []
      nodes << val
      operator = consome(:OP_ARITMETICO).match
      nodes << val

      return Nodes::Operation.new(operator, nodes)
    end
  end

  def multi_arit
    return unless proximo?(:ABRE_PAREN)

    consome(:ABRE_PAREN)
    expr_arit
    consome(:FECHA_PAREN)

    consome(:OP_ARITMETICO)

    consome(:ABRE_PAREN)
    expr_arit
    consome(:FECHA_PAREN)
  end

  def iteracao
    # TODO
  end

  def declaracoes
    repete(:declaracao)
  end

  def declaracao
    return unless proximo?(:TIPO_VAR)

    var_names = []
    type = consome(:TIPO_VAR).match
    var_names << consome(:ID).match

    while proximo?(:VIRGULA) do
      consome(:VIRGULA)
      var_names << consome(:ID).match
    end

    consome(:PONTO_VIRGULA)

    return Nodes::Declaration.new(var_names, type)
  end

  ##### Helper methods

  def proximo?(*expected_types)
    upcoming = @tokens[0, expected_types.size]

    return upcoming.map(&:type) == expected_types
  end

  def consome(expected_type)
    token = @tokens.shift

    if token.present? && token.type == expected_type
      return token
    elsif token.nil?
      # TODO: pegar linha e coluna para esse erro. Possivel solucao: ler EOF como um token
      raise_syntax_error("", expected_type)
    else
      erro_sintatico(expected_type, token)
    end
  end

  def obrigatorio(method, expected_types)
    if (value = send(method))
      return value
    else
      erro_sintatico(expected_types)
    end
  end

  def repete(method)
    results = []

    while (result = send(method)) do
      results << result
    end

    return results
  end

  def erro_sintatico(expected_types, token = nil)
    token ||= @tokens.shift
    raise_syntax_error(token.match, expected_types, token.linha, token.coluna)
  end

  def raise_syntax_error(current_token, expected_types, line = 'XX', column = 'YY')
    expected_types = expected_types.join(' ou ') if expected_types.is_a?(Array)
    raise SyntaxError,
          "Símbolo #{current_token.inspect} inesperado. "\
          "Esperando #{expected_types} - Linha #{line}, Coluna #{column}."
  end
end
