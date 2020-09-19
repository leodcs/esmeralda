class DoubleDeclarationError < StandardError
  def initialize(declaration)
    @name = declaration.name

    super(error_message)
  end

  private

  def error_message
    "ERRO 06: Variável #{@name.match.inspect} declarada em duplicidade. "\
    "Linha #{@name.linha} Coluna #{@name.coluna}."
  end
end
