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
        @comandos << ComandoBaixo.new(:LOAD, quadrupla.arg1, quadrupla.resultado)
      when 'IF'
        @comandos << ComandoBaixo.new(:CMP, quadrupla.arg1)
      when 'OR', 'AND', '<', '>', '<=', '>=', '=', '<>'
        operador = traduz_operador(quadrupla.operador)
        push_comando(operador, quadrupla)
      when 'GOTO'
        if (jump = @jumps.find { |a,_| a == quadrupla.arg1 })
          @comandos << ComandoBaixo.new(:JNZ, jump[1])
        else
          @jumps << [quadrupla.arg1, '?']
          @comandos << ComandoBaixo.new(:GOTO, quadrupla.arg1)
        end
      when 'NOT'
        @comandos << ComandoBaixo.new(:NOT, quadrupla.arg1)
      when 'END.'
        @comandos << ComandoBaixo.new('END.')
      else
        puts "Unexpected operator #{quadrupla.operador.inspect}"
      end

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

    @comandos << reg1 = ComandoBaixo.new(:LOAD, fonte, 'R0')
    @comandos << ComandoBaixo.new(instrucao, destino, reg1.destino)
    @comandos << ComandoBaixo.new(:STORE, reg1.destino, resultado)
  end
end
