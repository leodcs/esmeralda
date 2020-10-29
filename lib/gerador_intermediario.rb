require_relative 'quadrupla'

class GeradorIntermediario
  SAIDA = './intermediario.yaml'
  PREFIXO_VARIAVEL = '#temp' # nome usado p/ gerar as variaveis temporarias

  def initialize(parse)
    @variaveis = {} # Lista de variaveis temporarias
    @quadruplas = ArquivoSaida.new(SAIDA)
    @parse = parse
  end

  def quadruplas
    @quadruplas.read(0..)
  end

  def generate
    gera_node(@parse.root)
    salva_quadrupla('END.', nil, nil, nil)

    self
  end

  private

  def gera_node(node)
    case node.class_type
    when :program, :block
      node.nodes.each { |node| gera_node(node) }
    when :integer, :real
      node.value.valor
    when :identifier
      node.name.match
    when :assignment
      salva_quadrupla *gera_assignment(node)
    when :operation
      gera_operation(node)
    when :expression, :multi_expression
      quadrupla = salva_quadrupla *gera_expression(node)
      quadrupla.resultado
    when :conditional
      gera_condicao(node)
    when :while_iteration
      gera_iteracao_while(node)
    when :repeat_iteration
      gera_iteracao_repeat(node)
    when :call
      # TODO
    end
  end

  def gera_assignment(node)
    operador = ':='
    arg1 = nil
    arg2 = nil
    resultado = node.name.match
    nodes = node.nodes

    if nodes.count == 1
      generation = gera_node(nodes[0])
      if generation.class == Quadrupla
        arg1 = generation.resultado
      elsif generation.class == Array
        operador, arg1, arg2 = generation
      else
        arg1 = generation
      end
    end

    return [operador, arg1, arg2, resultado]
  end

  def gera_operation(node)
    operador = node.operator.match
    arg1 = gera_node(node.nodes[0])
    arg2 = gera_node(node.nodes[1])

    return [operador, arg1, arg2]
  end

  def gera_expression(node)
    operador = node.operator.match
    quadruplas_internas = node.nodes.map { |child| push_expression_node(child) }
    temp1, temp2 = quadruplas_internas.map(&:resultado)
    resultado = proxima_variavel

    return [operador, temp1, temp2, resultado]
  end

  def gera_condicao(node)
    inicio = (@quadruplas.last&.id || 0) + 1
    condicao = gera_node(node.clause)
    salva_quadrupla('NOT', condicao, nil, condicao)
    salva_quadrupla('IF', condicao, nil, nil)
    salva_quadrupla('GOTO', nil, nil, nil)
    goto = @quadruplas.last

    gera_node(node.then_body) if node.then_body

    backpatch(goto)

    gera_node(node.else_body) if node.else_body
  end

  def gera_iteracao_while(node)
    inicio = (@quadruplas.last&.id || 0) + 1
    condicao = gera_node(node.clause)
    salva_quadrupla('NOT', condicao, nil, condicao)
    salva_quadrupla('IF', condicao, nil, nil)
    salva_quadrupla('GOTO', nil, nil, nil)
    goto_final = @quadruplas.last

    node.nodes.each { |node| gera_node(node) }

    salva_quadrupla('GOTO', inicio, nil, nil)

    backpatch(goto_final)
  end

  def gera_iteracao_repeat(node)
    inicio = (@quadruplas.last&.id || 0) + 1

    node.nodes.each { |node| gera_node(node) }

    condicao = gera_node(node.clause)
    salva_quadrupla('NOT', condicao, nil, condicao)
    salva_quadrupla('IF', condicao, nil, nil)

    salva_quadrupla('GOTO', inicio, nil, nil)
  end

  def backpatch(goto)
    arg1 = @quadruplas.last.id + 1
    goto.object.arg1 = arg1

    @quadruplas.update(goto.id, goto.object)
  end

  def salva_quadrupla(operador, arg1, arg2 = nil, resultado = nil)
    linha = (@quadruplas.last&.id || 0) + 1
    quadrupla = Quadrupla.new(linha, operador, arg1, arg2, resultado)
    @quadruplas.push(quadrupla)

    return quadrupla
  end

  def proxima_variavel
    numero_proxima = @variaveis.keys.last.to_i + 1
    temporaria = "#{PREFIXO_VARIAVEL}#{numero_proxima}"

    # Se tiver alguma variavel com o nome da próx. temporaria, tenta gerar outra
    while identifiers.include?(temporaria.upcase)
      numero_proxima += 1
      temporaria = "#{PREFIXO_VARIAVEL}#{numero_proxima}"
    end

    @variaveis[numero_proxima] = temporaria

    return temporaria
  end

  def push_expression_node(node)
    arg1 = arg2 = nil
    generation = gera_node(node)

    case generation
    when Array
      operador, arg1, arg2 = generation
    else
      operador = ':='
      arg1 = generation
    end

    salva_quadrupla(operador, arg1, arg2, proxima_variavel)
  end

  def identifiers
    @parse.assignments.map(&:name).map(&:match).map(&:upcase)
  end
end
