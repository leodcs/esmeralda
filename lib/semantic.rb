class Semantic
  attr_reader :parse

  def initialize(parse)
    @parse = parse
  end

  def analyze
    check_assignments_types
  end

  private

  def check_assignments_types
    parse.assignments.each do |assignment|
      verifica_declaracao(assignment)
      verifica_compatibilidade(assignment)

      # TODO: Verificar se esse caso configura o erro 4:
      assignment.identifiers.each { |id| verifica_declaracao(id) }
      #### END Todo
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
end
