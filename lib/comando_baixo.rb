class ComandoBaixo
  attr_accessor :instrucao, :fonte, :destino

  def initialize(instrucao, fonte = nil, destino = nil)
    @instrucao = instrucao
    @fonte = fonte
    @destino = destino
  end
end
