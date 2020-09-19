class Parser
  attr_reader :declarations, :assignments

  def initialize(tokens)
    @tokens = tokens.dup
    @assignments = []
  end

  def parse
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
    prog_name = consome(:ID)
    consome(:PONTO_VIRGULA)

    @declarations = declaracoes.flatten

    consome(:BEGIN)
    body = bloco!
    consome(:END)
    consome(:PONTO)

    nodes = @declarations + [body]

    return ::Nodes::Program.new(prog_name, nodes)
  end

  def bloco
    return unless proximo?(:BEGIN)

    consome(:BEGIN)
    nodes = comandos
    consome(:END)
    consome(:PONTO_VIRGULA)

    return ::Nodes::Block.new(nodes)
  end

  def bloco!
    obriga_presenca_de(:bloco, :BEGIN)
  end

  def comandos
    varios(:comando)
  end

  def comando
    comando_basico || iteracao || condicional
  end

  def comando!
    obriga_presenca_de(:comando, [:ID, :WHILE, :REPEAT, :IF])
  end

  def condicional
    return unless proximo?(:IF)

    nodes = []
    consome(:IF)
    consome(:ABRE_PAREN)

    then_body = expr_relacional!
    nodes << then_body

    consome(:FECHA_PAREN)
    consome(:THEN)

    nodes << comando!

    else_body = nil
    if proximo?(:ELSE)
      consome(:ELSE)
      nodes << else_body = comando!
    end

    return ::Nodes::Conditional.new(then_body, else_body, nodes)
  end

  def expr_relacional
    op_relacional || multi_op_relacional
  end

  def expr_relacional!
    obriga_presenca_de(:expr_relacional, [:ID, :INTEGER, :REAL, :ABRE_PAREN])
  end

  def multi_op_relacional
    return unless proximo?(:ABRE_PAREN)

    expressions = []
    consome(:ABRE_PAREN)
    expressions << expr_relacional
    consome(:FECHA_PAREN)

    while proximo?(:OP_BOOLEANO) do
      operator = consome(:OP_BOOLEANO)
      consome(:ABRE_PAREN)
      expressions << expr_relacional
      consome(:FECHA_PAREN)
    end

    return ::Nodes::MultiExpression.new(operator, expressions)
  end

  def op_relacional
    return unless proximo?(:ID, :OP_RELACIONAL) || proximo?(:INTEGER, :OP_RELACIONAL) || proximo?(:REAL, :OP_RELACIONAL)

    nodes = []
    nodes << val!
    operador = consome(:OP_RELACIONAL)
    nodes << val!

    return ::Nodes::Expression.new(operador, nodes)
  end

  def val
    id || integer || real
  end

  def val!
    obriga_presenca_de(:val, [:ID, :INTEGER, :REAL, :STRING])
  end

  def id
    return unless proximo?(:ID)

    name = consome(:ID)
    return ::Nodes::Identifier.new(name)
  end

  def integer
    return unless proximo?(:INTEGER)

    value = consome(:INTEGER)
    return ::Nodes::Integer.new(value)
  end

  def real
    return unless proximo?(:REAL)

    value = consome(:REAL)
    return ::Nodes::Real.new(value)
  end

  def comando_basico
    atribuicao || bloco || comando_all
  end

  def comando_all
    return unless proximo?(:ALL)

    params = []
    method_name = consome(:ALL)
    consome(:ABRE_PAREN)
    params << ::Nodes::Identifier.new(consome(:ID))

    while proximo?(:VIRGULA) do
      consome(:VIRGULA)
      params << ::Nodes::Identifier.new(consome(:ID))
    end

    consome(:FECHA_PAREN)
    consome(:PONTO_VIRGULA)

    return ::Nodes::Call.new(method_name, params)
  end

  def atribuicao
    return unless proximo?(:ID, :DPI)

    name = consome(:ID)
    consome(:DPI)
    nodes = expr_arit!
    consome(:PONTO_VIRGULA)
    @assignments << ::Nodes::Assignment.new(name, nodes)

    return @assignments.last
  end

  def atribuicao!
    obriga_presenca_de(:atribuicao, :ID)
  end

  def expr_arit
    multi_arit || op_arit || val
  end

  def expr_arit!
    obriga_presenca_de(:expr_arit, [:ID, :INTEGER, :REAL, :ABRE_PAREN])
  end

  def op_arit
    return unless proximo?(:ID, :OP_ARITMETICO) || proximo?(:INTEGER, :OP_ARITMETICO) || proximo?(:REAL, :OP_ARITMETICO)

    nodes = []
    nodes << val!
    operator = consome(:OP_ARITMETICO)
    nodes << val!

    return ::Nodes::Operation.new(operator, nodes)
  end

  def multi_arit
    return unless proximo?(:ABRE_PAREN)

    nodes = []
    consome(:ABRE_PAREN)
    nodes << expr_arit!
    consome(:FECHA_PAREN)

    operador = consome(:OP_ARITMETICO)

    consome(:ABRE_PAREN)
    nodes << expr_arit!
    consome(:FECHA_PAREN)

    return ::Nodes::Expression.new(operador, nodes)
  end

  def iteracao
    itera_while || itera_repeat
  end

  def itera_while
    return unless proximo?(:WHILE)

    consome(:WHILE)
    consome(:ABRE_PAREN)
    expression = expr_relacional!
    consome(:FECHA_PAREN)
    consome(:DO)
    nodes = comando

    return ::Nodes::Iteration.new(expression, nodes)
  end

  def itera_repeat
    return unless proximo?(:REPEAT)

    consome(:REPEAT)
    nodes = comando
    consome(:UNTIL)
    consome(:ABRE_PAREN)
    expression = expr_relacional!
    consome(:FECHA_PAREN)
    consome(:PONTO_VIRGULA)

    return ::Nodes::Iteration.new(expression, nodes)
  end

  def declaracoes
    varios(:declaracao)
  end

  def declaracao
    return unless proximo?(:TIPO_VAR)

    names = []
    type = consome(:TIPO_VAR)
    names << consome(:ID)

    while proximo?(:VIRGULA) do
      consome(:VIRGULA)
      names << consome(:ID)
    end

    consome(:PONTO_VIRGULA)

    declarations = names.map { |name| ::Nodes::Declaration.new(name, type) }

    return declarations
  end

  ##### Helper methods

  def proximo?(*tipos_esperados)
    proximos = proximos(tipos_esperados.size)

    return proximos.map(&:type) == tipos_esperados
  end

  def proximos(n)
    @tokens[0, n]
  end

  def consome(tipo_esperado)
    token = @tokens.shift

    if token.present? && token.type == tipo_esperado
      return token
    else
      erro_sintatico(tipo_esperado, token)
    end
  end

  def obriga_presenca_de(method, expected_types)
    if (value = send(method))
      return value
    else
      erro_sintatico(expected_types)
    end
  end

  def varios(metodo)
    resultados = []

    while (resultado = send(metodo)) do
      resultados << resultado
    end

    return resultados
  end

  def erro_sintatico(expected_types, token = nil)
    token ||= @tokens.first

    raise ParserError.new(token, expected_types)
  end
end
