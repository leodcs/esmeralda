class Semantic
  def initialize(parse)
    @parse = parse
  end

  def analyze
    check_declarations
    check_identifiers
    check_assignments
    check_call_params

    self
  end

  private

  def check_declarations
    declarations = @parse.declarations.map(&:name).map(&:match)

    primeira_duplicada = @parse.declarations.find.with_index do |declaration, index|
      declaracoes_passadas = declarations[0..(index - 1)]

      (index > 0) && declaracoes_passadas.include?(declaration.name.match)
    end

    unless primeira_duplicada.vazio?
      erro_dupla_declaracao(primeira_duplicada)
    end
  end

  def check_assignments
    @parse.assignments.each do |assignment|
      verifica_declaracao(assignment)
      verifica_compatibilidade(assignment)
    end
  end

  def check_identifiers
    identifiers = @parse.identifiers.flatten

    identifiers.each do |identifier|
      verifica_declaracao(identifier)
    end
  end

  def check_call_params
    @parse.calls.each do |call|
      invalid_param = call.invalid_params.first

      unless invalid_param.vazio?
        erro_tipos_incompativeis(call.param_type, invalid_param)
      end
    end
  end

  def verifica_declaracao(assignment)
    declaration = assignment.declaration

    if declaration.nil?
      erro_identificador_nao_declarado(assignment.name)
    end
  end

  def verifica_compatibilidade(assignment)
    declaration = assignment.declaration

    unless declaration.aceita_tipo?(assignment.type)
      erro_tipos_incompativeis(declaration.type, assignment)
    end
  end

  def erro_identificador_nao_declarado(name)
    raise UndeclaredVarError.new(name)
  end

  def erro_tipos_incompativeis(expected_type, token_found)
    raise IncompatibleTypesError.new(expected_type, token_found)
  end

  def erro_dupla_declaracao(declaration)
    raise DoubleDeclarationError.new(declaration)
  end
end
