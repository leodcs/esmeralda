class ScannerError < StandardError
  def initialize(unexpected_text, line, column)
    @unexpected_text = unexpected_text
    @line = line
    @column = column

    super(error_message)
  end

  private

  def error_message
    "ERRO 01: Identificador ou símbolo inválido. #{@unexpected_text.inspect} - Linha #{@line}, Coluna #{@column}."
  end
end
