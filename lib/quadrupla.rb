class Quadrupla
  attr_reader :operador, :arg1, :arg2, :resultado

  def initialize(operador, arg1, arg2, resultado)
    @operador = operador
    @arg1 = arg1
    @arg2 = arg2
    @resultado = resultado
  end
end
