# frozen_string_literal: true

class Scanner
  def self.scan(file)
    tokens = []
    @file = file

    @file.lines.each_with_index do |line, line_number|
      @full_line = line
      @text_to_scan = @full_line.strip
      @line_number = line_number + 1

      until @text_to_scan.empty? do
        tokens.push(scan_tokens_from_line)
      end
    end

    return tokens
  end

  def self.scan_tokens_from_line
    column = @full_line.index(@text_to_scan)

    Token.types.each do |type, re|
      regexp = /\A(#{re})/i
      matches = @text_to_scan.match(regexp)
      next if matches.nil?

      token = type.to_s
      lexema = valor = nil
      match = matches[0]

      case type
      when :palavra_reservada, :operador, :especial
        token = match
      when :integer, :real
        token = 'Numerico'
        valor = match.to_i
      when :id, :string
        token = 'ID'
        lexema = match
      end

      @text_to_scan = @text_to_scan[match.length..-1].strip # FIXME

      return Token.new(token, lexema, valor, @line_number, column)
    end

    raise "Token inesperado: #{@text_to_scan.inspect} na linha #{@line_number} coluna #{column}!"
  end
end
