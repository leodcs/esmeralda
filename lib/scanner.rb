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
        tokens << scan_tokens_from_line
      end
    end

    return tokens
  end

  def scan_tokens_from_line
    column = @full_line.index(@text_to_scan) + 1

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

      return Token.new(match, type, token, lexema, valor, @line_number, column)
    end

    raise "01: Identificador ou símbolo inválido. #{@text_to_scan.inspect} - Linha #{@line_number}, Coluna #{column}."
  end
end