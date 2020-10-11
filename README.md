# Esmeralda
<p align="center">
  <img width="150" height="150" src="https://i.imgur.com/38xxS4c.png">
</p>

<p align="center">
  Um compilador para a matéria de Compiladores (8ᵒ período, 2020.2) <br/>
  no curso de Ciência da Computação, FACAPE.
</p>

# Fases da compilação
![esmeralda.png](https://i.imgur.com/7wbXPu0.png)

# Como usar

1. [Clique aqui](https://github.com/leodcs/esmeralda/releases/latest/download/esmeralda.exe) para baixar o executável da versão mais atualizada do compilador. <br>
2. Abra o executável no Windows siga a instruções exibidas na tela. <br>

Para ver as gramáticas válidas na linguagem veja o arquivo: [gramaticas.txt](https://github.com/leodcs/esmeralda/blob/master/gramaticas.txt)

## Observação importante :warning:
A depender do tamanho do algoritmo sendo compilado, é possível que a compilação demore proporcionalmente. </br>
Isso é devido a usarmos um arquivo (ao invés da memória RAM) para salvar a tabela léxica. <br/>
Para visualizá-la, veja o arquivo `tabela-lexica.yaml` que será gerado na mesma pasta onde está o executável.

# Estrutura do projeto
- `lib/`: Pasta principal do projeto.
  - `config/`: Configurações globais do Ruby
  - `exceptions/`: Classes de erro
  - `nodes/`: Classes usadas pelo Parser (`lib/parser.rb`)
- `spec/`: Pasta usada para escrever testes automatizados de código com a biblioteca [Rspec](https://rspec.info/). Essa pasta não interfere no código do compilador.
