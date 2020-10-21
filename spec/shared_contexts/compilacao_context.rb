shared_context 'Compilacao' do |example_description, file, error_message|
  let(:algoritmo_valido) { File.read('spec/algoritmos/validos/algoritmo1') }

  def compila(arquivo)
    $scan = Scanner.new(arquivo).scan
    $parse = Parser.new.parse
    $semantic = Semantic.new($parse).analyze
    $intermediario = GeradorIntermediario.new.generate($parse.root)
  end

  def espera_excecao(nome_arquivo, &block)
    arquivo = le_arquivo(pasta_erros, nome_arquivo)
    compila(arquivo)
  rescue StandardError => exception
    yield(exception.message)
  end

  def le_arquivo(pasta, nome_arquivo)
    caminho_arquivo = File.join(pasta, nome_arquivo)

    File.read(caminho_arquivo)
  end

  after(:all) { File.delete(Scanner::SAIDA) }
end
