class UndeclaredVarError < StandardError
  def initialize(token)
    @token = token

    super(error_message)
  end

  private

  def error_message
    "ERRO 04: Identificador \"#{@token.match}\" não declarado. Linha #{@token.linha} Coluna #{@token.coluna}."
  end
end
