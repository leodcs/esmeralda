require 'pry'
require 'terminal-table'
require './token'
require './scanner'

arquivo = File.read('input.txt')

# Inicio da Compilacao
begin
  tabela_lexica = Scanner.scan(arquivo)
rescue StandardError => e
  e.set_backtrace([])
  puts "ERRO #{e.message}"
  exit
end
# Fim da Compilacao

cabecalhos = ['Texto', 'Tipo', 'Token', 'Lexema', 'Valor', 'Linha', 'Coluna']
table = Terminal::Table.new(headings: cabecalhos, rows: tabela_lexica)
puts table
