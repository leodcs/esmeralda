class IncompatibleTypesError < StandardError
  def initialize(expected_type, token_found)
    @expected_type = expected_type.to_s.upcase
    @type_found = token_found.type.to_s.upcase
    @token = token_found&.name

    super(error_message)
  end

  private

  def error_message
    "ERRO 03: Tipos Incompatíveis. #{@expected_type} e #{@type_found}. "\
    "Linha #{@token&.linha} Coluna #{@token&.coluna}"
  end
end
