require '../lib/scanner'
require '../lib/token'

RSpec.describe Scanner do
  it 'Lê os tokens em um arquivo de entrada' do
    arquivo = File.read('spec/data/algoritmo1')
    scan = Scanner.new(arquivo).scan
    ignorados = [:ABRE_CHAVE, :FECHA_CHAVE, :FIM]
    expected_types = Token.types.keys.sort - ignorados
    types = scan.todos_tokens.map(&:type).uniq.sort - ignorados

    expect(types).to eq(expected_types)
  end
end
