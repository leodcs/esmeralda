RSpec.describe 'Gerador de Código Intermediário' do
  include_context 'Compilacao'

  let(:pasta) { 'spec/algoritmos/validos/intermediario' }

  it 'gera o número correto de quadruplas' do
    expect { compila(algoritmo_valido) }.not_to raise_error

    quadruplas = $intermediario.quadruplas

    expect(quadruplas.first.values).to match_array([':=', 10, nil, 'I4'])
    expect(quadruplas[-2].values).to match_array(['+', 'R3', 1, 'R2'])
    expect(quadruplas.count).to eq(69)
  end

  xit 'gera as quádruplas esperadas' do
    expect { compila(algoritmo_valido) }.not_to raise_error

    saida_esperada = "#{pasta}/saidas/algoritmo_valido.yaml"
    esperadas = ArquivoSaida.new(saida_esperada, false).read(0..).map(&:values)
    quadruplas = $intermediario.quadruplas.map(&:values)

    expect(quadruplas).to include(*esperadas)
  end

  xit 'gera quádrupla para assignment' do
    arquivo = File.read("#{pasta}/assignment")

    expect { compila(arquivo) }.not_to raise_error
    expect($intermediario.quadruplas.map(&:values)).to match_array([[':=', 0.152e2, nil, 'X']])
  end


  xit 'gera quádrupla para operation' do
    arquivo = File.read("#{pasta}/operation")

    expect { compila(arquivo) }.not_to raise_error
    expect($intermediario.quadruplas.map(&:values)).to match_array([["+", 2, 8, "X"]])
  end

  xit 'gera quádrupla para expression' do
    arquivo = File.read("#{pasta}/expression")

    expect { compila(arquivo) }.not_to raise_error
    expect($intermediario.quadruplas.map(&:values))
      .to match_array([["*", "#temp1", "#temp2", "#temp3"],
                       ["+", 2, 8, "#temp1"],
                       ["/", 9, 70, "#temp2"],
                       [":=", "#temp3", nil, "X"]])
  end

  it 'gera quádrupla para while_iteration' do
    arquivo = File.read("#{pasta}/while_iteration")
    expect { compila(arquivo) }.not_to raise_error
    saida_esperada = "#{pasta}/saidas/while_iteration.yaml"
    esperadas = ArquivoSaida.new(saida_esperada, false).read(0..).map(&:values)

    expect($intermediario.quadruplas.map(&:values)).to match_array(esperadas)
  end


  xit 'gera quádrupla para repeat_iteration' do
    arquivo = File.read("#{pasta}/repeat_iteration")
    expect { compila(arquivo) }.not_to raise_error
    saida_esperada = "#{pasta}/saidas/repeat_iteration.yaml"
    esperadas = ArquivoSaida.new(saida_esperada, false).read(0..).map(&:values)

    expect($intermediario.quadruplas.map(&:values)).to match_array(esperadas)
  end

  it 'gera quádrupla para conditional' do
    arquivo = File.read("#{pasta}/conditional")
    expect { compila(arquivo) }.not_to raise_error
    saida_esperada = "#{pasta}/saidas/conditional.yaml"
    esperadas = ArquivoSaida.new(saida_esperada, false).read(0..).map(&:values)

    expect($intermediario.quadruplas.map(&:values)).to match_array(esperadas)
  end
end
