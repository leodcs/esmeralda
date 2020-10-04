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

  # Se o texto invalido comecar com uma string, mostra a string restante
  # Se nao, mostra o primeiro caractere invalido.
  def texto_invalido
    resto = @fita.rest.split(/[\s*|;|$]/).first
    return @fita.rest if resto.blank?

    if resto.match?(/^[a-zA-Z]+/)
      return resto
    else
      return resto[0]
    end
  end
end
