require_relative 'nodes/node'
require_relative 'nodes/expression'
Dir['./lib/nodes/*.rb'].sort.each { |node| require node }

class Parser
  attr_reader :declarations, :assignments, :identifiers, :calls

  def initialize
    @ponteiro = 0 # Indica o index na tabela léxica
    @calls = [] # Vetor de chamadas para métodos. Ex.: all
    @assignments = [] # Vetor para guardar atribuicoes
    @identifiers = [] # Vetor para guardar chamada de variáveis
  end

  def parse
    programa

    return self
  end

  def root
    return programa
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
    verifica_proximos(esperando: :bloco)
    body = bloco
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

  def comandos
    varios(:comando)
  end

  def comando
    comando_basico || iteracao || condicional
  end

  def condicional
    return unless proximo?(:IF)

    nodes = []
    consome(:IF)
    consome(:ABRE_PAREN)

    verifica_proximos(esperando: :expr_relacional)
    then_body = expr_relacional
    nodes << then_body

    verifica_proximos(esperando: :fim_expr_relacional)
    consome(:FECHA_PAREN)
    consome(:THEN)

    verifica_proximos(esperando: :comando)
    nodes << comando

    else_body = nil
    if proximo?(:ELSE)
      consome(:ELSE)
      verifica_proximos(esperando: :comando)
      nodes << else_body = comando
    end

    return ::Nodes::Conditional.new(then_body, else_body, nodes)
  end

  def expr_relacional
    op_relacional || multi_op_relacional
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
    return unless proximo?(:ID) || proximo?(:INTEGER) || proximo?(:REAL)

    nodes = []
    verifica_proximos(esperando: :val)
    nodes << val
    operador = consome(:OP_RELACIONAL)
    verifica_proximos(esperando: :val)
    nodes << val

    return ::Nodes::Expression.new(operador, nodes)
  end

  def val
    id || integer || real
  end

  def id
    return unless proximo?(:ID)

    name = consome(:ID)
    @identifiers << (node = ::Nodes::Identifier.new(name))

    return node
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
    atribuicao || bloco || chamada
  end

  def chamada
    node = comando_all

    unless node.vazio?
      @calls << node
      return node
    end
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

    @identifiers += params

    consome(:FECHA_PAREN)
    consome(:PONTO_VIRGULA)

    return ::Nodes::Call.new(method_name, params)
  end

  def atribuicao
    return unless proximo?(:ID)

    name = consome(:ID)
    consome(:ATRIB)
    verifica_proximos(esperando: :expr_arit)
    nodes = expr_arit
    consome(:PONTO_VIRGULA)
    @assignments << ::Nodes::Assignment.new(name, nodes)

    return @assignments.last
  end

  def expr_arit
    multi_arit || op_arit || val
  end

  def op_arit
    return unless proximo?(:ID, :OP_ARITMETICO) || proximo?(:INTEGER, :OP_ARITMETICO) || proximo?(:REAL, :OP_ARITMETICO)

    nodes = []
    verifica_proximos(esperando: :val)
    nodes << val
    operator = consome(:OP_ARITMETICO)
    verifica_proximos(esperando: :val)
    nodes << val

    return ::Nodes::Operation.new(operator, nodes)
  end

  def multi_arit
    return unless proximo?(:ABRE_PAREN)

    nodes = []
    consome(:ABRE_PAREN)
    verifica_proximos(esperando: :expr_arit)
    nodes << expr_arit
    consome(:FECHA_PAREN)

    operador = consome(:OP_ARITMETICO)

    consome(:ABRE_PAREN)
    verifica_proximos(esperando: :expr_arit)
    nodes << expr_arit
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
    verifica_proximos(esperando: :expr_relacional)
    expression = expr_relacional
    consome(:FECHA_PAREN)
    consome(:DO)
    nodes = comando

    return ::Nodes::WhileIteration.new(expression, nodes)
  end

  def itera_repeat
    return unless proximo?(:REPEAT)

    consome(:REPEAT)
    nodes = comando
    consome(:UNTIL)
    consome(:ABRE_PAREN)
    verifica_proximos(esperando: :expr_relacional)
    expression = expr_relacional
    consome(:FECHA_PAREN)
    consome(:PONTO_VIRGULA)

    return ::Nodes::RepeatIteration.new(expression, nodes)
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

  ##### Métodos auxiliares

  # Esse é o método auxiliar mais importante.
  # Ele verifica se o tipo do "proximo_token" é igual ao "tipo_esperado" recebido
  # por parâmetro. Se for igual, incrementa o ponteiro e retorna o token.
  # Se não for, levanta um erro sintático.
  def consome(tipo_esperado)
    token = proximo_token

    if token && token.type == tipo_esperado
      @ponteiro = @ponteiro + 1
      return token
    else
      erro_sintatico(tipo_esperado)
    end
  end

  # Retorna true se os próximos tokens forem iguais aos
  # "tipos_esperados" recebidos por parâmetro
  def proximo?(*tipos_esperados)
    proximos = proximos(tipos_esperados.size)

    return proximos.map(&:type) == tipos_esperados
  end

  # Lê os "n" próximos tokens na tabela léxica gerada pelo Scanner
  def proximos(n)
    $scan.le_tokens(@ponteiro, n)
  end

  # Lê o próximo token (na posicao do "ponteiro") na tabela léxica
  def proximo_token
    tokens = $scan.le_tokens(@ponteiro)
    tokens.pop
  end

  # Verifica se o tipo do "proximo_token" é um dos "tipos_esperados".
  # Se não for, levanta um "erro_sintatico".
  def verifica_proximos(options = {})
    gramatica = options.fetch(:esperando)
    tipos_esperados = follow.fetch(gramatica)

    unless tipos_esperados.include?(proximo_token.type)
      erro_sintatico(tipos_esperados)
    end
  end

  # Usado definir os "tipos_esperados" que serão buscados no método "verifica_proximos"
  def follow
    { bloco: [:BEGIN],
      val: [:ID, :INTEGER, :REAL],
      comando: [:ID, :BEGIN, :ALL, :WHILE, :REPEAT, :IF],
      expr_relacional: [:ABRE_PAREN, :ID, :INTEGER, :REAL],
      fim_expr_relacional: [:FECHA_PAREN, :OP_BOOLEANO],
      expr_arit: [:ID, :INTEGER, :REAL, :ABRE_PAREN] }
  end

  # Usado para definir gramaticas que tem * (repeticao).
  # Por exemplo: Para definir uma gramática [declaracao]*, podemos usar:
  # varios(:declaracao)
  def varios(metodo)
    resultados = []

    while (resultado = send(metodo)) do
      resultados << resultado
    end

    return resultados
  end

  def erro_sintatico(expected_types)
    raise ParserError.new(proximo_token, expected_types)
  end
end
