# frozen_string_literal: true

class Scanner
  def initialize(file)
    @file = file
    @current_state = :default
  end

  def scan
    tokens = []

    @file.lines.each_with_index do |line, index|
      @full_line = line.upcase
      @text_to_scan = @full_line.strip
      @line_number = index + 1

      until @text_to_scan.empty? do
        if @current_state == :comment || @text_to_scan.start_with?('{')
          ignora_comentarios
        elsif @current_state == :default && (token = get_next_token)
          tokens << token
        else
          erro_lexico
        end
      end
    end

    tokens << Token.new('FIM_DO_ARQUIVO', :FIM)

    return tokens
  end

  private

  def ignora_comentarios
    if @text_to_scan.start_with?('{') && !@text_to_scan.end_with?('}')
      @current_state = :comment
    elsif @current_state == :comment && @text_to_scan.end_with?('}')
      @current_state = :default
    end

    @text_to_scan = ''
  end

  def current_column
    @full_line.index(@text_to_scan) + 1
  end

  def get_next_token
    token_achado = nil

    Token.types.each do |type, re|
      regexp = /\A(#{re.source})/i
      matches = @text_to_scan.match(regexp)
      next if matches.nil?

      token = type.to_s
      lexema = valor = nil
      match = matches[0]

      case type
      when :INTEGER, :REAL
        token = 'Numerico'
        valor = match.to_i
      when :ID, :STRING
        token = 'ID'
        lexema = match
      else
        token = match
      end

      @text_to_scan = @text_to_scan[match.length..-1].strip # FIXME

      token_achado = Token.new(match, type, token, lexema, valor, @line_number, current_column)

      break(token_achado)
    end

    return token_achado
  end

  def erro_lexico
    raise "01: Identificador ou símbolo inválido. #{@text_to_scan.inspect} - "\
          "Linha #{@line_number}, Coluna #{current_column}."
  end
end
