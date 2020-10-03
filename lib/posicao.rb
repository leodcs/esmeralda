class Posicao
  attr_reader :linha
  attr_accessor :coluna

  def initialize(args = {})
    @linha = args[:linha] + 1
    @coluna = args[:coluna] + 1
  end
end
