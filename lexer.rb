# frozen_string_literal: true

class Lexer
  TOKEN_TYPES = {
    def: /\bdef\b/,
    end: /\bend\b/,
    identifier: /\b[a-zA-Z]+\b/,
    integer: /\b[0-9]+\b/,
    oparen: /\(/,
    cparen: /\)/
  }

  def initialize(file)
    @file = file
  end

  def tokenize
    tokens = []

    @file.lines.each do |line|
      @current_line = line.strip

      until @current_line.empty? do
        tokens << read_tokens_from_line
      end
    end

    tokens
  end

  private

  def read_tokens_from_line
    TOKEN_TYPES.each do |type, re|
      regexp = /\A(#{re})/
      matches = @current_line.match(regexp)
      next if matches.nil?

      value = matches[0]
      @current_line = @current_line[value.length..-1].strip

      return Token.new(type, value)
    end

    raise RuntimeError.new("Couldn't match token on #{@current_line.inspect}")
  end
end
