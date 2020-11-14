require_relative 'quadrupla'

class GeradorIntermediario
  SAIDA = './intermediario.yaml'
  PREFIXO_VARIAVEL = '#temp' # nome usado p/ gerar as variaveis temporarias

  def initialize(parse)
    @temporarias = [] # Lista de variaveis temporarias
    @temp_count = 0 # Contador de variaveis temporarias
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

  def imprime_saida
    puts '--- Código Intermediário ---'.colorize(:green)
    quadruplas.each_with_index do |quadrupla, index|
      formata_saida(quadrupla, index)
    end
    puts '--- FIM Código Intermediário ---'.colorize(:green)
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
      gera_assignment(node)
    when :operation, :expression, :boolean_expression
      gera_expression(node)
    when :multi_expression
      gera_expression(node.nodes[0])
    when :conditional
      gera_condicional(node)
    when :while_iteration
      gera_iteracao_while(node)
    when :repeat_iteration
      gera_iteracao_repeat(node)
    when :call
      gera_call(node)
    end
  end

  def gera_assignment(node)
    registra_abandonadas do
      operador = ':='
      arg1 = nil
      arg2 = nil
      flag = false
      var = node.name.match
      if quadruplas.any? { |q| q.resultado == var && (q.arg1 == var || q.arg2 == var) }
        resultado = temporaria
        flag = true
      else
        resultado = var
      end

      nodes = node.nodes

      if (generation = gera_node(nodes[0])).is_a?(Array)
        operador, arg1, arg2 = serializa(generation, resultado)
      else
        arg1 = generation
      end

      resultado = var if flag
      salva_quadrupla(operador, arg1, arg2, resultado)
    end
  end

  def gera_expression(node)
    operador = node.operator.match
    arg1 = gera_node(node.nodes[0])
    arg2 = gera_node(node.nodes[1])

    return [operador, arg1, arg2]
  end

  def gera_condicional(node)
    registra_abandonadas do
      inicio = (@quadruplas.last&.id || 0) + 1
      condicao = gera_clausula(node.clause)

      salva_quadrupla('NOT', condicao, nil, condicao)
      salva_quadrupla('IF', condicao, nil, nil)
      salva_quadrupla('GOTO', nil, nil, nil)
      goto_else = @quadruplas.last

      if node.then_body
        gera_node(node.then_body)

        if node.else_body
          salva_quadrupla('GOTO', nil, nil, nil)
          goto_fim = @quadruplas.last
        end
      end

      backpatch(goto_else)

      if node.else_body
        gera_node(node.else_body)
        backpatch(goto_fim)
      end
    end
  end

  def gera_iteracao_while(node)
    registra_abandonadas do
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
  end

  def gera_iteracao_repeat(node)
    registra_abandonadas do
      inicio = (@quadruplas.last&.id || 0) + 1

      node.nodes.each { |node| gera_node(node) }

      condicao = gera_clausula(node.clause)
      salva_quadrupla('NOT', condicao, nil, condicao)
      salva_quadrupla('IF', condicao, nil, nil)

      salva_quadrupla('GOTO', inicio, nil, nil)
    end
  end

  def gera_call(node)
    name = node.method_name.match
    params = node.params

    params.each do |param|
      salva_quadrupla('PARAM', param.name.match)
    end

    salva_quadrupla('CALL', name, params.count)
  end

  def backpatch(record)
    arg1 = @quadruplas.last.id + 1
    goto = record.object
    goto.arg1 = arg1

    @quadruplas.update(record.id, goto)
  end

  def temporaria
    return @abandonadas.shift if @abandonadas.any?

    @temp_count += 1
    temporaria = "#{PREFIXO_VARIAVEL}#{@temp_count}"

    # Se tiver alguma variavel com o nome da próx. temporaria, tenta gerar outra
    while identifiers.include?(temporaria.upcase)
      @temp_count += 1
      temporaria = "#{PREFIXO_VARIAVEL}#{@temp_count}"
    end

    @temporarias << temporaria

    return temporaria
  end

  def identifiers
    @parse.assignments.map(&:name).map(&:match).map(&:upcase)
  end

  def serializa(generation, resultado = nil)
    return generation if generation.none? { |e| e.is_a?(Array) }

    operador, arg1, arg2 = generation

    if arg1.is_a?(Array)
      interna = serializa(arg1, resultado)
    elsif arg2.is_a?(Array)
      interna = serializa(arg2, resultado)
    end

    if temporaria?(interna[1]) && interna[1] != resultado
      var = interna[1]
    else
      var = (resultado || temporaria)
    end
    salva_quadrupla(*interna, var)
    generation.map! { |g| g == interna ? var : g }

    serializa(generation)
  end

  def gera_clausula(node)
    condicao = serializa(gera_node(node), temporaria)

    salva_quadrupla(*condicao, temporaria).resultado
  end


  def temporaria?(arg)
    arg.to_s.match?(/^#{PREFIXO_VARIAVEL}/)
  end

  # Marca as temps adicionadas como abandonadas
  def registra_abandonadas(&block)
    yield

    @abandonadas += @temporarias
    @abandonadas = @abandonadas.uniq.sort
  end

  def salva_quadrupla(operador, arg1, arg2 = nil, resultado = nil)
    linha = (@quadruplas.last&.id || 0) + 1
    quadrupla = Quadrupla.new(linha, operador, arg1, arg2, resultado)
    @quadruplas.push(quadrupla)

    return quadrupla
  end

  def formata_saida(quadrupla, index)
    linha = quadrupla.linha
    operador, arg1, arg2, resultado = quadrupla.values
    op_aritmetico = Token.types[:OP_ARITMETICO].match?(operador)
    op_relacional = Token.types[:OP_RELACIONAL].match?(operador)
    op_booleano = Token.types[:OP_BOOLEANO].match?(operador)
    mostra_num = true
    quebra_linha = true

    if operador == ':='
      texto = "#{resultado} #{operador} #{arg1}"
    elsif op_aritmetico || op_relacional
      texto = "#{resultado} := #{arg1} #{operador} #{arg2}"
    elsif op_booleano
      texto = "#{resultado} := #{arg1} #{operador} #{arg2}"
    elsif ['GOTO', 'IF', 'PARAM'].include?(operador)
      quebra_linha = (operador != 'IF')
      anterior = quadruplas[index - 1]
      mostra_num = (anterior.operador != 'IF')
      texto = "#{operador} #{arg1} "
    elsif operador == 'NOT'
      texto = "#{resultado} := NOT #{arg1}"
    elsif operador == 'CALL'
      texto = "#{operador} #{arg1},#{arg2}"
    else
      texto = "#{operador}"
    end

    texto = "#{texto}\n" if quebra_linha
    texto = texto.colorize(:yellow) if operador == 'GOTO'
    texto = "#{linha.to_s.rjust(2, '0')}: #{texto}" if mostra_num

    print texto
  end
end
