class Semantic
  def initialize(parse)
    @parse = parse
  end

  def analyze
    check_double_declarations
    check_assignments_types
    # TODO: Verificar se esse caso configura o erro 4:
    check_identifiers_types
  end

  private

  def check_double_declarations
    declarations = @parse.declarations.map(&:name).map(&:match)

    primeira_duplicada = @parse.declarations.find.with_index do |declaration, index|
      declaracoes_passadas = declarations[0..(index - 1)]

      (index > 0) && declaracoes_passadas.include?(declaration.name.match)
    end

    if primeira_duplicada.present?
      erro_dupla_declaracao(primeira_duplicada)
    end
  end

  def check_assignments_types
    @parse.assignments.each do |assignment|
      verifica_declaracao(assignment)
      verifica_compatibilidade(assignment)
      # TODO: Verificar tipos corretos nos parametros dos Call Nodes
    end
  end

  def check_identifiers_types
    identifiers = @parse.assignments.map(&:identifiers).flatten

    identifiers.each do |identifier|
      verifica_declaracao(identifier)
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

    if !declaration.aceita_tipo?(assignment.type)
      erro_tipos_incompativeis(declaration, assignment)
    end
  end

  def erro_identificador_nao_declarado(name)
    raise UndeclaredVarError.new(name)
  end

  def erro_tipos_incompativeis(declaration, assignment)
    raise IncompatibleTypesError.new(declaration, assignment)
  end

  def erro_dupla_declaracao(declaration)
    raise DoubleDeclarationError.new(declaration)
  end
end
