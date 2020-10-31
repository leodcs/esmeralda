require_relative 'quadrupla'

class GeradorIntermediario
  SAIDA = './intermediario.yaml'
  PREFIXO_VARIAVEL = '#temp' # nome usado p/ gerar as variaveis temporarias

  def initialize(parse)
    @temporarias = {} # Lista de variaveis temporarias
    @quadruplas = ArquivoSaida.new(SAIDA)
    @parse = parse
    @abandonadas = []
  end

  def quadruplas
    @quadruplas.read(0..)
  end

  def generate
    gera_node(@parse.root)
    salva_quadrupla('END.', nil, nil, nil)

    return self
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
    when :operation, :expression, :multi_expression
      gera_operation(node)
    when :conditional
      gera_condicao(node)
    when :while_iteration
      gera_iteracao_while(node)
    when :repeat_iteration
      gera_iteracao_repeat(node)
    when :call
      raise RuntimeError, 'TODO CALL'
    end
  end

  def gera_assignment(node)
    operador = ':='
    arg1 = nil
    arg2 = nil
    resultado = node.name.match
    nodes = node.nodes

    if (generation = gera_node(nodes[0])).is_a?(Array)
      operador, arg1, arg2 = gera_temps(generation, resultado)
    else
      arg1 = generation
    end

    return [operador, arg1, arg2, resultado]
  end

  def gera_operation(node)
    operador = node.operator.match
    arg1 = gera_node(node.nodes[0])
    arg2 = gera_node(node.nodes[1])

    return [operador, arg1, arg2]
  end

  def gera_condicao(node)
    inicio = (@quadruplas.last&.id || 0) + 1
    condicao = gera_clausula(node.clause)

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
    condicao = gera_clausula(node.clause)
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

    condicao = gera_clausula(node.clause)
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

  def temporaria
    return @abandonadas.shift if @abandonadas.any?

    numero_proxima = @temporarias.keys.last.to_i + 1
    temporaria = "#{PREFIXO_VARIAVEL}#{numero_proxima}"

    # Se tiver alguma variavel com o nome da próx. temporaria, tenta gerar outra
    while identifiers.include?(temporaria.upcase)
      numero_proxima += 1
      temporaria = "#{PREFIXO_VARIAVEL}#{numero_proxima}"
    end

    @temporarias[numero_proxima] = temporaria

    return temporaria
  end

  def identifiers
    @parse.assignments.map(&:name).map(&:match).map(&:upcase)
  end

  def gera_temps(generation, resultado = nil)
    return generation if generation.none? { |e| e.is_a?(Array) }

    operador, arg1, arg2 = generation

    if arg1.is_a?(Array)
      interna = gera_temps(arg1, resultado)
    elsif arg2.is_a?(Array)
      interna = gera_temps(arg2, resultado)
    end

    registra_abandonadas do
      if temporaria?(interna[1]) && interna[1] != resultado
        var = interna[1]
      else
        var = (resultado || temporaria)
      end
      salva_quadrupla(*interna, var)
      generation.map! { |g| g == interna ? var : g }
    end

    gera_temps(generation)
  end

  def gera_clausula(clause)
    condicao = gera_temps(gera_node(clause), temporaria)

    salva_quadrupla(*condicao, condicao[1]).resultado
  end


  def temporaria?(arg)
    arg.to_s.match?(/^#{PREFIXO_VARIAVEL}/)
  end

  def registra_abandonadas(&block)
    antes = @temporarias.values

    yield

    depois = @temporarias.values
    adicionadas = depois - antes
    # Marca uma temp adicionada como abandonada se ela não estiver "segurando" um valor
    @abandonadas += adicionadas.delete_if do |temp|
      quadruplas.any? { |q| q.resultado == temp }
    end
  end
end
