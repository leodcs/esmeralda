class ParserError < StandardError
  def initialize(token, expected_types)
    @token = token
    @expected_types = expected_types

    super(error_message)
  end

  private

  def error_message
    "ERRO 02: Símbolo #{@token.match.inspect} inesperado. Esperando #{expected_types} #{position}."
  end

  def expected_types
    if @expected_types.class == Array
      return @expected_types.join(' ou ')
    else
      return @expected_types
    end
  end

  def position
    if @token.linha && @token.coluna
      return " - Linha #{@token.linha}, Coluna #{@token.coluna}"
    end
  end
end
