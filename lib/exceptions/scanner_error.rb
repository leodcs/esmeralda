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
    resto = @fita.rest.split(/[\s*|;|$]/).first
    return @fita.rest if resto.blank?

    if resto.match?(/\w+/)
      return resto
    else
      return resto[0]
    end
  end
end
