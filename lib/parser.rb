class Parser
  attr_reader :declarations

  def initialize(tokens)
    @tokens = tokens.dup
    @declarations = []
  end

  def parse
    # Parsing starts here

    # ignora_comentarios # TODO: metodo para ignorar comentarios
    programa

    self
  end

  def root
    programa
  end

  private

  def peek(*expected_types)
    upcoming = @tokens[0, expected_types.size]

    if upcoming.map(&:type) == expected_types
      return upcoming
    end
  end

  def expect(*expected_types)
    if (tokens = peek(expected_types))
      @tokens = @tokens.drop(tokens.size)
    end
  end

  def consume(expected_type)
    token = @tokens.shift

    if token.present? && token.type == expected_type
      return token
    elsif token.nil?
      # TODO: pegar linha e coluna para esse erro. Possivel solucao: ler EOF como um token
      raise_syntax_error("", expected_type)
    else
      raise_syntax_error(token.match, expected_type, token.linha, token.coluna)
    end
  end

  def raise_if_required(value, options, expected_types)
    if value.present?
      return value
    elsif options[:required]
      token = @tokens.shift
      raise_syntax_error(token.match, expected_types, token.linha, token.coluna)
    end
  end

  def programa
    @programa ||= bloco_principal
  end

  def bloco_principal
    consume(:PROGRAM)
    prog_name = consume(:ID).match
    consume(:PONTO_VIRGULA)

    declarations = declaracoes
    @declarations += declarations

    consume(:BEGIN)
    body = bloco
    consume(:END)
    consume(:PONTO)

    nodes = declarations + [body]
    return Nodes::Program.new(prog_name, nodes)
  end

  def bloco
    consume(:BEGIN)
    nodes = comandos
    consume(:END)
    consume(:PONTO_VIRGULA)

    return Nodes::Block.new(nodes)
  end

  def comandos
    repeat(:comando)
  end

  def comando(options = {})
    value = comando_basico || condicional

    raise_if_required(value, options, [:ID, :WHILE, :REPEAT, :IF])
  end

  def comando!
    comando(required: true)
  end

  def condicional
    return unless peek(:IF)

    consume(:IF)
    consume(:ABRE_PAREN)
    nodes = [expr_relacional]
    consume(:FECHA_PAREN)
    consume(:THEN)

    comando!

    if peek(:ELSE)
      consume(:ELSE)
      comando!
    end

    return Nodes::Conditional.new(nodes)
  end

  def expr_relacional
    # TODO: segunda parte da gramatica
    nodes = []
    nodes << val!
    operador = consume(:OP_RELACIONAL).match
    nodes << val!

    return Nodes::Expression.new(operador, nodes)
  end

  def val!
    val(required: true)
  end

  def val(options = {})
    value = id || integer || real

    raise_if_required(value, options, [:ID, :INTEGER, :REAL])
  end

  def id
    return unless peek(:ID)

    value = consume(:ID).match

    return Nodes::Id.new(value)
  end

  def integer
    return unless peek(:INTEGER)

    value = consume(:INTEGER).match

    return Nodes::Integer.new(value)
  end

  def real
    return unless peek(:REAL)

    value = consume(:REAL).match

    return Nodes::Real.new(value)
  end

  def comando_basico
    atribuicao # || bloco || All ( <id>  [, <id>]* );
  end

  def atribuicao
    return unless peek(:ID, :DPI)

    atribuicao!
  end

  def atribuicao!
    consume(:ID)
    consume(:DPI)
    nodes = expr_arit!
    consume(:PONTO_VIRGULA)

    return Nodes::Assignment.new(nodes)
  end

  def expr_arit!
    expr_arit(required: true)
  end

  def expr_arit(options = {})
    value = multi_arit || op_arit || val

    raise_if_required(value, options, [:ID, :INTEGER, :REAL, :ABRE_PAREN])
  end

  def op_arit
    if peek(:ID, :OP_ARITMETICO) || peek(:INTEGER, :OP_ARITMETICO) || peek(:REAL, :OP_ARITMETICO)
      nodes = []
      nodes << val
      operator = consume(:OP_ARITMETICO).match
      nodes << val

      return Nodes::Operation.new(operator, nodes)
    end
  end

  def multi_arit
    return unless peek(:ABRE_PAREN)

    consume(:ABRE_PAREN)
    expr_arit
    consume(:FECHA_PAREN)

    consume(:OP_ARITMETICO)

    consume(:ABRE_PAREN)
    expr_arit
    consume(:FECHA_PAREN)
  end

  def iteracao
    # TODO
  end

  def repeat(method)
    results = []

    while (result = send(method)) do
      results << result
    end

    return results
  end

  def declaracoes
    repeat(:declaracao)
  end

  def declaracao
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

  def raise_syntax_error(current_token, expected_types, line = 'XX', column = 'YY')
    expected_types = expected_types.join(' ou ') if expected_types.is_a?(Array)
    raise SyntaxError,
          "Símbolo #{current_token.inspect} inesperado. "\
          "Esperando #{expected_types} - Linha #{line}, Coluna #{column}."
  end
end
