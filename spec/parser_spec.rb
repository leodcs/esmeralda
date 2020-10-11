require '../lib/scanner'
require '../lib/parser'

RSpec.describe Parser do
  it 'Verifica ordem dos tokens' do
    arquivo = File.read('spec/algoritmos/algoritmo1')
    $scan = Scanner.new(arquivo).scan
    parse = Parser.new.parse

    expect(parse.class).to eq(Parser)
    expect(parse.declarations.count).to eq(14)
    expect(parse.assignments.count).to eq(14)
    expect(parse.identifiers.count).to eq(28)
    expect(parse.calls.count).to eq(2)

    File.delete(Scanner::ARQUIVO_SAIDA)
  end

  it 'Detecta símbolos inesperados' do
    files = [
      ['erro2_comentario', 'ERRO 02: Símbolo "}" inesperado. Esperando END - Linha 9, Coluna 9.'],
      ['erro2_programa', 'ERRO 02: Símbolo "PROGRAMA" inesperado. Esperando PROGRAM - Linha 1, Coluna 1.'],
      ['erro2_bloco_principal', 'ERRO 02: Símbolo "END" inesperado. Esperando BEGIN - Linha 3, Coluna 1.'],
      ['erro2_decl_var', 'ERRO 02: Símbolo ";" inesperado. Esperando ID - Linha 2, Coluna 7.'],
      ['erro2_tipo', 'ERRO 02: Símbolo "BOOLEAN" inesperado. Esperando BEGIN - Linha 2, Coluna 3.'],
      ['erro2_bloco', 'ERRO 02: Símbolo "END" inesperado. Esperando ";" - Linha 5, Coluna 1.'],
      ['erro2_condicional1', 'ERRO 02: Símbolo "X" inesperado. Esperando "(" - Linha 4, Coluna 6.'],
      ['erro2_condicional2', 'ERRO 02: Símbolo "THEN" inesperado. Esperando ")" ou OP_BOOLEANO - Linha 4, Coluna 27.'],
      ['erro2_condicional3', 'ERRO 02: Símbolo "<" inesperado. Esperando ID ou BEGIN ou ALL ou WHILE ou REPEAT ou IF - Linha 5, Coluna 8.'],
      ['erro2_comando_all', 'ERRO 02: Símbolo "2" inesperado. Esperando ID - Linha 4, Coluna 7.'],
      ['erro2_atribuicao', 'ERRO 02: Símbolo "=" inesperado. Esperando ":=" - Linha 4, Coluna 5.'],
      ['erro2_itera_while', 'ERRO 02: Símbolo "X" inesperado. Esperando "(" - Linha 4, Coluna 9.'],
      ['erro2_itera_repeat', 'ERRO 02: Símbolo "0" inesperado. Esperando "(" - Linha 4, Coluna 16.'],
      ['erro2_multi_op_relacional', 'ERRO 02: Símbolo "NOT" inesperado. Esperando ")" ou OP_BOOLEANO - Linha 4, Coluna 15.'],
      ['erro2_op_relacional', 'ERRO 02: Símbolo "+" inesperado. Esperando OP_RELACIONAL - Linha 4, Coluna 9.'],
      ['erro2_op_arit', 'ERRO 02: Símbolo "-" inesperado. Esperando ID ou INTEGER ou REAL - Linha 4, Coluna 12.'],
      ['erro2_multi_arit', 'ERRO 02: Símbolo "3" inesperado. Esperando "(" - Linha 4, Coluna 18.'],
      ['erro2_reservada1', 'ERRO 02: Símbolo "IF" inesperado. Esperando ID ou INTEGER ou REAL ou "(" - Linha 5, Coluna 10.'],
      ['erro2_reservada2', 'ERRO 02: Símbolo "STRING" inesperado. Esperando END - Linha 5, Coluna 3.']
    ]

    files.each do |file_name, message|
      arquivo = File.read("spec/algoritmos/erros/parser/#{file_name}")
      $scan = Scanner.new(arquivo).scan
      begin
        Parser.new.parse
      rescue StandardError => e
        expect(e.class).to eq(ParserError)
        expect(e.message).to eq(message)
      end
    end

    File.delete(Scanner::ARQUIVO_SAIDA)
  end
end
