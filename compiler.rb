require 'pry'
require 'terminal-table'
require 'ostruct'
require './token'
require './scanner'

arquivo = File.read('input.txt')

# Inicio da Compilacao
begin
  tabela_lexica = Scanner.new(arquivo).scan
rescue StandardError => e
  e.set_backtrace([])
  puts "ERRO #{e.message}"
  exit
end
# Fim da Compilacao

# Exibição da Tabela Lexica
cabecalhos = ['Texto', 'Tipo', 'Token', 'Lexema', 'Valor', 'Linha', 'Coluna']
tabela_lexica_as_h = tabela_lexica.map { |row| row.instance_variables.map { |var, _| row.instance_variable_get(var) } }
table = Terminal::Table.new(headings: cabecalhos, rows: tabela_lexica_as_h)
puts table
# Fim da Exibição
