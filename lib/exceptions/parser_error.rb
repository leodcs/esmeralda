class ParserError < StandardError
  SYMBOLS = {
    :TIPO_VAR => ['STRING', 'INTEGER', 'REAL'],
    :ATRIB => ':=',
    :VIRGULA => ',',
    :ABRE_CHAVE => '{',
    :FECHA_CHAVE => '}',
    :ABRE_PAREN => '(',
    :FECHA_PAREN => ')',
    :PONTO => '.',
    :PONTO_VIRGULA => ';'
  }

  def initialize(token, expected_types)
    @token = token
    if expected_types.class == Array
      @expected_types = expected_types
    else
      @expected_types = [expected_types]
    end

    super(error_message)
  end

  private

  def error_message
    "ERRO 02: Símbolo \"#{@token.match}\" inesperado. Esperando #{expected_types}#{position}."
  end

  # Se o tipo esperado for uma chave na constante SYMBOLS,
  # usa o valor da string na constante na hora de imprimir o erro.
  # Se não for, usa o valor que receber.
  # Por exemplo: imprime ";" ao invés de PONTO_VIRGULA,
  # mas, se o token esperado for OP_ARITMETICO, imprime OP_ARITMETICO,
  # pois ele nao esta na constante
  def expected_types
    types = @expected_types.map do |type|
      if SYMBOLS.keys.include?(type)
        SYMBOLS[type].inspect
      else
        type.to_s
      end
    end

    return types.flatten.join(' ou ')
  end

  # Verifica se o @token encontrado tem linha e coluna.
  # Se for um token de FIM de arquivo nao tera
  def position
    posicao = @token.posicao

    if !posicao.vazio?
      return " - Linha #{posicao.linha}, Coluna #{posicao.coluna}"
    end
  end
end
