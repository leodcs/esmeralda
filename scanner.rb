# frozen_string_literal: true

class Scanner
  def initialize(file)
    @file = file
  end

  def scan
    tokens = []

    @file.lines.each_with_index do |line, line_number|
      @full_line = line.upcase
      @text_to_scan = @full_line.strip
      @line_number = line_number + 1

      until @text_to_scan.empty? do
        tokens.push(scan_tokens_from_line)
      end
    end

    return tokens
  end

  def scan_tokens_from_line
    column = @full_line.index(@text_to_scan)

    Token.types.each do |type, re|
      regexp = /\A(#{re})/i
      matches = @text_to_scan.match(regexp)
      next if matches.nil?

      token = type.to_s
      lexema = valor = nil
      match = matches[0]

      case type
      when :PalavraReservada
        token = match
      when :Integer, :Real
        token = 'Numerico'
        valor = match.to_i
      when :Id, :String
        token = 'ID'
        lexema = match
      else
        token = match
      end

      @text_to_scan = @text_to_scan[match.length..-1].strip # FIXME

      return Token.new(match, type, token, lexema, valor, @line_number, column)
    end

    raise "Token inesperado: #{@text_to_scan.inspect} na linha #{@line_number} coluna #{column}"
  end
end
