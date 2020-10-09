require '../lib/scanner'
require '../lib/token'

RSpec.describe Scanner do
  it 'Lê os tokens em um arquivo de entrada' do
    arquivo = File.read('spec/algoritmos/algoritmo1')
    scan = Scanner.new(arquivo).scan
    ignorados = [:ABRE_CHAVE, :FECHA_CHAVE, :FIM]
    expected_types = Token.types.keys.sort - ignorados
    types = scan.todos_tokens.map(&:type).uniq.sort - ignorados
    File.delete(Scanner::ARQUIVO_SAIDA)

    expect(types).to eq(expected_types)
  end

  it 'Detecta um token inválido' do
    arquivo = File.read('spec/algoritmos/erros/scanner/erro1')
    begin
      Scanner.new(arquivo).scan
    rescue StandardError => e
      expect(e.class).to eq(ScannerError)
      expect(e.message).to eq('ERRO 01: Identificador ou símbolo inválido. "[" - Linha 5, Coluna 9.')
    end
  end

  it 'Ignora comentários' do
    tipos_validos = ['tipo1', 'tipo2', 'tipo3']
    tipos_validos.each do |file_name|
      arquivo = File.read("spec/algoritmos/comentarios/#{file_name}")
      scan = Scanner.new(arquivo).scan

      expect(scan.todos_tokens.count).to eq(10)
    end

    arquivo = File.read('spec/algoritmos/erros/scanner/comentario')
    begin
      Scanner.new(arquivo).scan
    rescue StandardError => e
      expect(e.class).to eq(ScannerError)
      expect(e.message).to eq('ERRO 01: Identificador ou símbolo inválido. "APÓS" - Linha 8, Coluna 39.')
    end

    File.delete(Scanner::ARQUIVO_SAIDA)
  end
end
