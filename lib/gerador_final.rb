require_relative 'comando_baixo'

class GeradorFinal
  def initialize(quadruplas)
    @quadruplas = quadruplas
    @gotos = @quadruplas.select { |quadrupla| quadrupla.operador == 'GOTO' }.map(&:arg1).uniq
    @comandos = []
    @jumps = []
  end

  def generate
    @quadruplas.each do |quadrupla|
      @linha = @comandos.count + 1

      if quadrupla.operador != 'GOTO' && (goto = @gotos.find { |goto| goto == quadrupla.linha })
        @jumps << [goto, @linha]
      end

      case quadrupla.operador
      when '+'
        push_comando(:ADD, quadrupla)
      when '-'
        push_comando(:SUB, quadrupla)
      when '*'
        push_comando(:MUL, quadrupla)
      when '/'
        push_comando(:DIV, quadrupla)
      when ':='
        load = push_load(quadrupla.arg1)
        @comandos << ComandoBaixo.new(:STORE, load.destino, quadrupla.resultado)
      when 'IF'
        @comandos << ComandoBaixo.new(:CMP, '#R0')
      when 'OR', 'AND', '<', '>', '<=', '>=', '=', '<>'
        operador = traduz_operador(quadrupla.operador)
        push_comando(operador, quadrupla)
      when 'GOTO'
        @comandos << ComandoBaixo.new(:GOTO, quadrupla.arg1)
      when 'NOT'
        load = push_load(quadrupla.arg1)
        @comandos << ComandoBaixo.new(:NOT, load.destino)
      when 'PARAM'
        load = push_load(quadrupla.arg1)
        @comandos << ComandoBaixo.new(:PARAM, load.destino)
      when 'CALL'
        @comandos << ComandoBaixo.new(:CALL, quadrupla.arg1, quadrupla.arg2)
      when 'END.'
        @comandos << ComandoBaixo.new('END.')
      else
        puts "Unexpected operator #{quadrupla.operador.inspect}"
      end
    end

    backpatch_gotos

    return self
  end

  def imprime_saida
    puts "\n--- Código Final ---".colorize(:green)
    @comandos.each_with_index do |comando, index|
      linha = (index + 1).to_s.rjust(2, '0')
      texto = "#{comando.instrucao} "

      if comando.fonte && comando.destino
        texto += "#{comando.fonte}, #{comando.destino}"
      elsif comando.fonte
        texto += "#{comando.fonte}"
      end

      texto = texto.colorize(:yellow) if comando.instrucao == :JNZ

      puts "#{linha}: #{texto}"
    end
    puts '--- FIM Código Final ---'.colorize(:green)
  end

  private

  def backpatch_gotos
    comandos = @comandos.select { |comando| comando.instrucao == :GOTO }
    comandos.each do |comando|
      nova_linha = @jumps.find { |j| j[0] == comando.fonte }[1]
      comando.instrucao = :JNZ
      comando.fonte = nova_linha
    end
  end

  def traduz_operador(operador)
    { 'OR' => :OR,
      'AND' => :AND,
      '<' => :MENOR,
      '>' => :MAIOR,
      '<=' => :MENORIGUAL,
      '>=' => :MAIORIGUAL,
      '=' => :IGUAL,
      '<>' => :DIFERENTE }.fetch(operador)
  end

  def push_comando(instrucao, quadrupla)
    _, fonte, destino, resultado = quadrupla.values

    push_load(fonte, '#R0')
    push_load(destino, '#R1')

    @comandos << ComandoBaixo.new(instrucao, '#R1', '#R0')

    @comandos << ComandoBaixo.new(:STORE, '#R0', resultado)
  end

  def push_load(valor, registrador = '#R0')
    @comandos << ComandoBaixo.new(:LOAD, valor, registrador)

    return @comandos.last
  end
end
