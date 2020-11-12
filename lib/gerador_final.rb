require_relative 'comando_baixo'

class GeradorFinal
  def initialize(quadruplas)
    @quadruplas = quadruplas
    @comandos = []
    @jumps = []
  end

  def generate
    @quadruplas.each_with_index do |quadrupla, index|
      @linha = @comandos.count + 1

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
        load = push_load(quadrupla.arg1)
        @comandos << ComandoBaixo.new(:CMP, load.destino)
      when 'OR', 'AND', '<', '>', '<=', '>=', '=', '<>'
        operador = traduz_operador(quadrupla.operador)
        push_comando(operador, quadrupla)
      when 'GOTO'
        if (jump = @jumps.find { |a,_| a == quadrupla.arg1 })
          load = push_load(jump[1])
          @comandos << ComandoBaixo.new(:JNZ, load.destino)
        else
          @jumps << [quadrupla.arg1, '?']
          @comandos << ComandoBaixo.new(:GOTO, quadrupla.arg1)
        end
      when 'NOT'
        load = push_load(quadrupla.arg1)
        @comandos << ComandoBaixo.new(:NOT, load.destino)
      when 'END.'
        @comandos << ComandoBaixo.new('END.')
      else
        puts "Unexpected operator #{quadrupla.operador.inspect}"
      end

      binding.pry if quadrupla.operador == 'END.'
      backpatch(quadrupla.linha) if @jumps.any? { |g| g[0] == quadrupla.linha }
    end

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
      texto += "\n\n" if comando.instrucao == :STORE

      puts "#{linha}: #{texto}"
    end
    puts '--- FIM Código Final ---'.colorize(:green)
  end

  private

  def backpatch(linha)
    @jumps = @jumps.map do |antiga, nova|
      if antiga == linha
        nova = @linha
        @comandos.select { |c| c.instrucao == :GOTO && c.fonte == antiga }.each do |comando|
          comando.instrucao = :JNZ
          comando.fonte = nova
        end
      end

      [antiga, nova]
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

    push_load(fonte, 'R0')
    push_load(destino, 'R1')

    @comandos << ComandoBaixo.new(instrucao, 'R1', 'R0')

    @comandos << ComandoBaixo.new(:STORE, 'R0', resultado)
  end

  def push_load(valor, registrador = 'R0')
    @comandos << ComandoBaixo.new(:LOAD, valor, registrador)

    return @comandos.last
  end
end
