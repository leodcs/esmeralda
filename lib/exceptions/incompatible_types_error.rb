class IncompatibleTypesError < StandardError
  def initialize(declaration, assignment)
    @type = declaration.type.upcase
    @expected_type = assignment.type.upcase
    @name = assignment.name

    super(error_message)
  end

  private

  def error_message
    "ERRO 03: Tipos Incompatíveis. #{@type} e #{@expected_type}. Linha #{@name.linha} Coluna #{@name.coluna}"
  end
end
