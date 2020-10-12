RSpec.describe 'Analisador Semântico' do
  include_context 'Compilacao'

  let(:pasta_erros) { 'spec/algoritmos/invalidos/semantic' }

  it 'não dá erro em algoritmo válido' do
    compila(algoritmo_valido)

    expect($semantic.class).to eq(Semantic)
  end

  it 'não dá erro com REAL recebendo inteiro' do
    arquivo = File.read('spec/algoritmos/validos/realcominteiro')
    compila(arquivo)

    expect($semantic.class).to eq(Semantic)
  end

  it 'detecta variável STRING recebendo INTEGER' do
    espera_excecao('erro3_a') do |erro|
      expect(erro).to eq('ERRO 03: Tipos Incompatíveis. STRING e INTEGER. Linha 5 Coluna 3')
    end
  end

  it 'detecta método ALL recebendo INTEGER como parâmetro' do
    espera_excecao('erro3_d') do |erro|
      expect(erro).to eq('ERRO 03: Tipos Incompatíveis. STRING e INTEGER. Linha 7 Coluna 8')
    end
  end

  it 'detecta variável INTEGER usando uma tipo REAL' do
    espera_excecao('erro3_c') do |erro|
      expect(erro).to eq('ERRO 03: Tipos Incompatíveis. INTEGER e REAL. Linha 7 Coluna 1')
    end
  end

  it 'detecta variável INTEGER usando outra que recebe divisão' do
    espera_excecao('erro3_b') do |erro|
      expect(erro).to eq('ERRO 03: Tipos Incompatíveis. INTEGER e REAL. Linha 7 Coluna 3')
    end
  end

  it 'detecta identificador não declarado usado em atribuicao' do
    espera_excecao('erro4_a') do |erro|
      expect(erro).to eq('ERRO 04: Identificador "SOMA" não declarado. Linha 6 Coluna 3.')
    end
  end

  it 'detecta identificador não declarado usado em condicional' do
    espera_excecao('erro4_b') do |erro|
      expect(erro).to eq('ERRO 04: Identificador "SOMA" não declarado. Linha 6 Coluna 7.')
    end
  end

  it 'detecta identificador não declarado usado no método ALL' do
    espera_excecao('erro4_c') do |erro|
      expect(erro).to eq('ERRO 04: Identificador "S" não declarado. Linha 4 Coluna 5.')
    end
  end

  it 'detecta identificador não declarado usado em outra variável' do
    espera_excecao('erro4_d') do |erro|
      expect(erro).to eq('ERRO 04: Identificador "J" não declarado. Linha 6 Coluna 29.')
    end
  end

  it 'detecta variável sendo declarada duas vezes na mesma linha' do
    espera_excecao('erro6_b') do |erro|
      expect(erro).to eq('ERRO 06: Variável "ZERO" declarada em duplicidade. Linha 2 Coluna 38.')
    end
  end

  it 'detecta variável sendo declarada em duas linhas' do
    espera_excecao('erro6_a') do |erro|
      expect(erro).to eq('ERRO 06: Variável "YY" declarada em duplicidade. Linha 3 Coluna 6.')
    end
  end

  it 'detecta variável sendo declarada em duas linhas com vírgula' do
    espera_excecao('erro6_c') do |erro|
      expect(erro).to eq('ERRO 06: Variável "NUM" declarada em duplicidade. Linha 6 Coluna 16.')
    end
  end
end
