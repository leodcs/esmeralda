require 'yaml/store'

class ArquivoSaida
  def initialize(caminho)
    @caminho = caminho
    File.open(@caminho, 'w') # inicializa o arquivo em branco, ou o sobrescreve
    @saida = YAML::Store.new(@caminho) # Usa a biblioteca YAML
  end

  def last
    transaction do
      table = @saida.instance_variable_get('@table').map do |id, object|
        Struct.new(:id, :object).new(id, object)
      end

      return table.last
    end
  end

  # Escreve um valor no arquivo de saida
  def push(valor, id = nil)
    transaction do
      id ||= @saida.roots.last.to_i + 1

      @saida[id] = valor
    end
  end

  # read(0) => retorna o valor na posicao zero, ou seja, o primeiro valor
  # read(15, 3) => retorna 3 valores a partir da posicao 15
  # read(30..) => retorna todos os valores a partir da posicao 30 até o final do arquivo
  def read(index, length = 1)
    transaction do
      roots = @saida.roots

      if index.class == Range
        ids = roots.slice(index)
      else
        ids = roots.slice(index, length)
      end

      return ids.map { |id| @saida[id] }
    end
  end

  def update(id, value)
    push(value, id)
  end

  private

  def transaction(&block)
    @saida.transaction(&block)
  end
end
