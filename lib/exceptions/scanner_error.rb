class ScannerError < StandardError
  def initialize(fita, posicao)
    @fita = fita
    @linha = posicao.linha
    @coluna = posicao.coluna

    super(error_message)
  end

  private

  def error_message
    "ERRO 01: Identificador ou símbolo inválido. \"#{texto_invalido}\" - Linha #{@linha}, Coluna #{@coluna}."
  end

  def texto_invalido
    @fita.rest.split(/[\s*|;|$]/).first
  end
end
