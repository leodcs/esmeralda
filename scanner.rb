# frozen_string_literal: true

class Scanner
  def self.scan(file)
    @file = file
    tokens = []

    @file.lines.each_with_index do |line, line_number|
      @full_line = line.downcase
      @line_string = @full_line.strip
      @line_number = line_number + 1

      until @line_string.empty? do
        tokens << read_tokens_from_line
      end
    end

    tokens
  end

  def self.read_tokens_from_line
    column = @full_line.index(@line_string)

    Token.types.each do |type, re|
      regexp = /\A(#{re})/
      matches = @line_string.match(regexp)
      next if matches.nil?

      value = matches[0]
      @line_string = @line_string[value.length..-1].strip

      return Token.new(type, value, @line_number, column)
    end

    raise "Unexpected token #{@line_string.inspect} on line #{@line_number} column #{column}"
  end
end
