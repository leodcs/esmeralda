class HighCode
  SAIDA = './intermediario.yaml'
  PREFIXO_VARIAVEL = 'tmp' # nome usado p/ gerar as variaveis temporarias

  def initialize
    @variaveis = [] # Vetor para guardar as variaveis #tmp
    @quadruplas = ArquivoSaida.new(SAIDA)
  end

  def generate(node)
    node_class = node.class.name.split('::').last

    case node_class
    when 'Program'
      node.nodes.each { |node| generate(node) }
    when 'Block'
      node.nodes.each { |node| generate(node) }
    when 'Assignment'
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

      push_quadruple(operador, arg1, arg2, resultado)
    when 'Integer', 'Real'
      node.value.valor
    when 'Identifier'
      node.name.match
    when 'Operation'
      operador = node.operator.match
      arg1 = generate(node.nodes[0])
      arg2 = generate(node.nodes[1])
      [operador, arg1, arg2]
    when 'Expression'
      operador = node.operator.match
      tmp1, tmp2 = node.nodes.map { |child| push_expression_node(child) }
      resultado = proxima_variavel

      push_quadruple(operador, tmp1, tmp2, resultado).resultado
    when 'Conditional'
    when 'Call'
    when 'Declaration' # Ignora declaracoes
    end
  end

  private

  def push_quadruple(operador, arg1, arg2, resultado)
    quadrupla = Quadrupla.new(operador, arg1, arg2, resultado)
    @quadruplas.push(quadrupla)

    return quadrupla
  end

  def proxima_variavel
    numero_proxima = @variaveis.count + 1
    @variaveis << "#{PREFIXO_VARIAVEL}#{numero_proxima}"

    return @variaveis.last
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

    push_quadruple(operador, arg1, arg2, proxima_variavel).resultado
  end
end
