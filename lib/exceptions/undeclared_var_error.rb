class UndeclaredVarError < StandardError
  def initialize(token)
    @token = token
    @posicao = token.posicao

    super(error_message)
  end

  private

  def error_message
    "ERRO 04: Identificador \"#{@token.match}\" não declarado. Linha #{@posicao.linha} Coluna #{@posicao.coluna}."
  end
end
