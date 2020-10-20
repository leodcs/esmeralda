RSpec.describe 'Analisador Léxico' do
  include_context 'Compilacao'

  let(:exception_class) { ScannerError }
  let(:pasta_erros) { 'spec/algoritmos/invalidos/scanner' }
  let(:pasta_comentarios) { 'spec/algoritmos/validos/comentarios' }

  it 'não dá erro em algoritmo válido' do
    expect { compila(algoritmo_valido) }.not_to raise_error

    ignorados = [:ESPACO, :ABRE_CHAVE, :FECHA_CHAVE, :FIM]
    expected_types = Token.types.keys.sort - ignorados
    types = $scan.todos_tokens.map(&:type).uniq.sort - ignorados

    expect(types).to match_array(expected_types)
  end

  it 'detecta token inválido: "["' do
    espera_excecao('erro1_a') do |erro|
      expect(erro).to eq('ERRO 01: Identificador ou símbolo inválido. "[" - Linha 5, Coluna 9.')
    end
  end

  it 'detecta token inválido: "\"' do
    espera_excecao('erro1_b') do |erro|
      expect(erro).to eq('ERRO 01: Identificador ou símbolo inválido. "\" - Linha 2, Coluna 12.')
    end
  end

  it 'detecta token inválido: "SOMATÓRIO"' do
    espera_excecao('erro1_c') do |erro|
      expect(erro).to eq('ERRO 01: Identificador ou símbolo inválido. "SOMATÓRIO" - Linha 2, Coluna 1.')
    end
  end

  it 'ignora comentários em uma linha' do
    arquivo = le_arquivo(pasta_comentarios, 'umalinha')
    expect { compila(arquivo) }.not_to raise_error
    expect($scan.todos_tokens.count).to eq(10)
  end

  it 'ignora comentários em múltiplas linhas' do
    arquivo = le_arquivo(pasta_comentarios, 'multiplaslinhas')
    expect { compila(arquivo) }.not_to raise_error
    expect($scan.todos_tokens.count).to eq(70)
  end

  it 'ignora comentários com multiplos "{"' do
    arquivo = le_arquivo(pasta_comentarios, 'muitaschaves')

    expect { compila(arquivo) }.not_to raise_error
    expect($scan.todos_tokens.count).to eq(43)
  end

  it 'lê tokens na mesma linha após fechar comentário' do
    espera_excecao('comentario') do |erro|
      expect(erro).to eq('ERRO 01: Identificador ou símbolo inválido. "APÓS" - Linha 8, Coluna 39.')
    end
  end
end
