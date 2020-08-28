# frozen_string_literal: true

class Scanner
  def self.scan(file)
    @file = file
    tokens = []

    @file.lines.each_with_index do |line, line_number|
      @full_line = line
      @line_text = @full_line.strip
      @line_number = line_number + 1

      until @line_text.empty? do
        tokens << scan_tokens_from_line
      end
    end

    tokens
  end

  def self.scan_tokens_from_line
    column = @full_line.index(@line_text)

    Token.types.each do |type, re|
      regexp = /\A(#{re})/i
      matches = @line_text.match(regexp)
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

      @line_text = @line_text[match.length..-1].strip

      return Token.new(token, lexema, valor, @line_number, column)
    end

    raise "Unexpected token #{@line_text.inspect} on line #{@line_number} column #{column}"
  end
end
