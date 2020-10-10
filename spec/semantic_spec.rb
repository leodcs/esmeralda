require '../lib/scanner'
require '../lib/parser'
require '../lib/semantic'

RSpec.describe Semantic do
  it 'Busca erros semânticos' do
    arquivo = File.read('spec/algoritmos/algoritmo1')
    $scan = Scanner.new(arquivo).scan
    $parse = Parser.new.parse
    semantic = Semantic.new($parse).analyze

    expect(semantic.class).to eq(Semantic)

    File.delete(Scanner::ARQUIVO_SAIDA)
  end

  it 'Não dá erro com REAL recebendo inteiro' do
    arquivo = File.read('spec/algoritmos/realcominteiro')
    $scan = Scanner.new(arquivo).scan
    $parse = Parser.new.parse
    semantic = Semantic.new($parse).analyze

    expect(semantic.class).to eq(Semantic)

    File.delete(Scanner::ARQUIVO_SAIDA)
  end

  it 'Detecta tipos incompatíveis' do
    files = [
      ['erro3_a', 'ERRO 03: Tipos Incompatíveis. STRING e INTEGER. Linha 5 Coluna 3'],
      ['erro3_b', 'ERRO 03: Tipos Incompatíveis. INTEGER e REAL. Linha 7 Coluna 3'],
      ['erro3_c', 'ERRO 03: Tipos Incompatíveis. INTEGER e REAL. Linha 7 Coluna 1'],
      ['erro3_d', 'ERRO 03: Tipos Incompatíveis. STRING e INTEGER. Linha 7 Coluna 8'],
    ]

    files.each do |file_name, message|
      arquivo = File.read("spec/algoritmos/erros/semantic/#{file_name}")
      begin
        $scan = Scanner.new(arquivo).scan
        $parse = Parser.new.parse
        Semantic.new($parse).analyze
      rescue StandardError => e
        expect(e.class).to eq(IncompatibleTypesError)
        expect(e.message).to eq(message)
      end
    end

    File.delete(Scanner::ARQUIVO_SAIDA)
  end


  it 'Detecta identificador não declarado' do
    files = [
      ['erro4_a', 'ERRO 04: Identificador "SOMA" não declarado. Linha 6 Coluna 3.'],
      ['erro4_b', 'ERRO 04: Identificador "SOMA" não declarado. Linha 6 Coluna 7.'],
      ['erro4_c', 'ERRO 04: Identificador "S" não declarado. Linha 4 Coluna 5.'],
      ['erro4_d', 'ERRO 04: Identificador "J" não declarado. Linha 6 Coluna 29.'],
    ]

    files.each do |file_name, message|
      arquivo = File.read("spec/algoritmos/erros/semantic/#{file_name}")
      begin
        $scan = Scanner.new(arquivo).scan
        $parse = Parser.new.parse
        Semantic.new($parse).analyze
      rescue StandardError => e
        expect(e.class).to eq(UndeclaredVarError)
        expect(e.message).to eq(message)
      end
    end

    File.delete(Scanner::ARQUIVO_SAIDA)
  end

  it 'Detecta variável declarada em duplicidade' do
    files = [
      ['erro6_a', 'ERRO 06: Variável "YY" declarada em duplicidade. Linha 3 Coluna 6.'],
      ['erro6_b', 'ERRO 06: Variável "ZERO" declarada em duplicidade. Linha 2 Coluna 38.'],
      ['erro6_c', 'ERRO 06: Variável "NUM" declarada em duplicidade. Linha 7 Coluna 8.'],
    ]

    files.each do |file_name, message|
      arquivo = File.read("spec/algoritmos/erros/semantic/#{file_name}")
      begin
        $scan = Scanner.new(arquivo).scan
        $parse = Parser.new.parse
        Semantic.new($parse).analyze
      rescue StandardError => e
        expect(e.class).to eq(DoubleDeclarationError)
        expect(e.message).to eq(message)
      end
    end

    File.delete(Scanner::ARQUIVO_SAIDA)
  end
end
