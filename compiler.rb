require 'pry'
require 'terminal-table'
require './token'
require './scanner'

arquivo = File.read('input.txt')
tabela_lexica_completa = Scanner.scan(arquivo)
tabela_lexica_formatada = tabela_lexica_completa.map do |token|
  [token.token, token.lexema, token.valor].compact
end

table = Terminal::Table.new(
  headings: ['Token', 'Lexema', 'Valor', 'Linha', 'Coluna'],
  rows: tabela_lexica_completa
)

puts table
# puts tabela_lexica_formatada.map(&:inspect).join("\n")
