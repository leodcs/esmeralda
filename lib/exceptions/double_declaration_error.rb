class DoubleDeclarationError < StandardError
  def initialize(declaration)
    @token = declaration.name
    @posicao = @token.posicao

    super(error_message)
  end

  private

  def error_message
    "ERRO 06: Variável \"#{@token.match}\" declarada em duplicidade. Linha #{@posicao.linha} Coluna #{@posicao.coluna}."
  end
end
