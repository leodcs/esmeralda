RSpec.describe 'Analisador Sintático' do
  include_context 'Compilacao'

  let(:exception_class) { ParserError }
  let(:pasta_erros) { 'spec/algoritmos/invalidos/parser' }

  it 'não dá erro em algoritmo válido' do
    compila(algoritmo_valido)

    expect($parse.class).to eq(Parser)
    expect($parse.declarations.count).to eq(14)
    expect($parse.assignments.count).to eq(14)
    expect($parse.identifiers.count).to eq(28)
    expect($parse.calls.count).to eq(2)
  end


  it 'detecta erro na gramática <comentario>' do
    espera_excecao('erro2_comentario') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "}" inesperado. Esperando END - Linha 9, Coluna 9.')
    end
  end

  it 'detecta erro na gramática de <programa>' do
    espera_excecao('erro2_programa') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "PROGRAMA" inesperado. Esperando PROGRAM - Linha 1, Coluna 1.')
    end
  end

  it 'detecta erro na gramática de <bloco_principal>' do
    espera_excecao('erro2_bloco_principal') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "END" inesperado. Esperando BEGIN - Linha 3, Coluna 1.')
    end
  end

  it 'detecta erro na gramática de <decl_var>' do
    espera_excecao('erro2_decl_var') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo ";" inesperado. Esperando ID - Linha 2, Coluna 7.')
    end
  end

  it 'detecta erro na gramática de <tipo>' do
    espera_excecao('erro2_tipo') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "BOOLEAN" inesperado. Esperando BEGIN - Linha 2, Coluna 3.')
    end
  end

  it 'detecta erro na gramática de <bloco>' do
    espera_excecao('erro2_bloco') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "END" inesperado. Esperando ";" - Linha 5, Coluna 1.')
    end
  end

  it 'detecta erro na gramática de <condicional>(1)' do
    espera_excecao('erro2_condicional1') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "X" inesperado. Esperando "(" - Linha 4, Coluna 6.')
    end
  end

  it 'detecta erro na gramática de <condicional>(2)' do
    espera_excecao('erro2_condicional2') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "THEN" inesperado. Esperando ")" ou OP_BOOLEANO - Linha 4, Coluna 27.')
    end
  end

  it 'detecta erro na gramática de <condicional3>' do
    espera_excecao('erro2_condicional3') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "<" inesperado. Esperando ID ou BEGIN ou ALL ou WHILE ou REPEAT ou IF - Linha 5, Coluna 8.')
    end
  end

  it 'detecta erro na gramática de <comando_all>' do
    espera_excecao('erro2_comando_all') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "2" inesperado. Esperando ID - Linha 4, Coluna 7.')
    end
  end

  it 'detecta erro na gramática de <atribuicao>' do
    espera_excecao('erro2_atribuicao') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "=" inesperado. Esperando ":=" - Linha 4, Coluna 5.')
    end
  end

  it 'detecta erro na gramática de <itera_while>' do
    espera_excecao('erro2_itera_while') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "X" inesperado. Esperando "(" - Linha 4, Coluna 9.')
    end
  end

  it 'detecta erro na gramática de <itera_repeat>' do
    espera_excecao('erro2_itera_repeat') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "0" inesperado. Esperando "(" - Linha 4, Coluna 16.')
    end
  end

  it 'detecta erro na gramática de <multi_op_relacional>' do
    espera_excecao('erro2_multi_op_relacional') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "NOT" inesperado. Esperando ")" ou OP_BOOLEANO - Linha 4, Coluna 15.')
    end
  end

  it 'detecta erro na gramática de <op_relacional>' do
    espera_excecao('erro2_op_relacional') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "+" inesperado. Esperando OP_RELACIONAL - Linha 4, Coluna 9.')
    end
  end

  it 'detecta erro na gramática de <op_arit>' do
    espera_excecao('erro2_op_arit') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "-" inesperado. Esperando ID ou INTEGER ou REAL - Linha 4, Coluna 12.')
    end
  end

  it 'detecta erro na gramática de <multi_arit>' do
    espera_excecao('erro2_multi_arit') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "3" inesperado. Esperando "(" - Linha 4, Coluna 18.')
    end
  end

  it 'detecta erro na gramática de <reservada>(1)' do
    espera_excecao('erro2_reservada1') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "IF" inesperado. Esperando ID ou INTEGER ou REAL ou "(" - Linha 5, Coluna 10.')
    end
  end

  it 'detecta erro na gramática de <reservada>(2)' do
    espera_excecao('erro2_reservada2') do |erro|
      expect(erro).to eq('ERRO 02: Símbolo "STRING" inesperado. Esperando END - Linha 5, Coluna 3.')
    end
  end
end
