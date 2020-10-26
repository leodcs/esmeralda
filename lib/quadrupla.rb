class Quadrupla
  attr_accessor :linha, :operador, :arg1, :arg2, :resultado

  def initialize(linha, operador, arg1, arg2, resultado)
    @linha = linha
    @operador = operador
    @arg1 = arg1
    @arg2 = arg2
    @resultado = resultado
  end

  def values
    [operador, arg1, arg2, resultado]
  end
end
