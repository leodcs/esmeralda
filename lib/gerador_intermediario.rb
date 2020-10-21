require_relative 'quadrupla'

class GeradorIntermediario
  SAIDA = './intermediario.yaml'
  PREFIXO_VARIAVEL = '#temp' # nome usado p/ gerar as variaveis temporarias

  def initialize
    @variaveis = {} # Lista de variaveis temporarias
    @quadruplas = ArquivoSaida.new(SAIDA)
  end

  def generate(node)
    case node.class.name.split('::').last
    when 'Program', 'Block'
      node.nodes.each { |node| generate(node) }
    when 'Integer', 'Real'
      node.value.valor
    when 'Identifier'
      node.name.match
    when 'Assignment'
      salva_quadrupla *gera_assignment(node)
    when 'Operation'
      gera_operation(node)
    when 'Expression', 'MultiExpression'
      quadrupla = salva_quadrupla *gera_expression(node)
      quadrupla.resultado
    when 'Conditional'
      clause = salva_quadrupla(*gera_operation(node.clause), proxima_variavel)
      condicao = clause.resultado
      salva_quadrupla('NOT', condicao, nil, condicao)
      salva_quadrupla('IF', condicao, nil, nil)
      # salva_quadrupla('GOTO', proximo_label, nil, nil) # TODO
      generate(node.then_body) if node.then_body
      generate(node.else_body) if node.else_body
    when 'WhileIteration'
    # TODO
    when 'RepeatIteration'
    # TODO
    when 'Call'
      # TODO
    end
  end

  private

  def gera_assignment(node)
    operador = ':='
    arg1 = nil
    arg2 = nil
    resultado = node.name.match
    nodes = node.nodes

    if nodes.count == 1
      generation = generate(nodes[0])
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
    arg1 = generate(node.nodes[0])
    arg2 = generate(node.nodes[1])

    return [operador, arg1, arg2]
  end

  def gera_expression(node)
    operador = node.operator.match
    quadruplas_internas = node.nodes.map { |child| push_expression_node(child) }
    temp1, temp2 = quadruplas_internas.map(&:resultado)
    resultado = proxima_variavel

    return [operador, temp1, temp2, resultado]
  end

  def salva_quadrupla(operador, arg1, arg2 = nil, resultado = nil)
    quadrupla = Quadrupla.new(operador, arg1, arg2, resultado)
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
    generation = generate(node)

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
    $parse.assignments.map(&:name).map(&:match).map(&:upcase)
  end
end
