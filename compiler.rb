require './token'
require './scanner'
require './parser'
require './nodes/node'
Dir['./nodes/*.rb'].sort.each { |node| require node }

# Debugging
require 'pry'
require 'terminal-table'
require 'tty-tree'
# End Debugging

arquivo = File.read('input.txt')

# Inicio da Compilacao
# begin
  tabela_lexica = Scanner.new(arquivo).scan
  parsing = Parser.new(tabela_lexica).parse
# rescue StandardError => e
#   e.set_backtrace([])
#   puts "ERRO #{e.message}"
#   exit
# end
# Fim da Compilacao

# Exibição da Tabela Lexica
cabecalhos = ['Texto', 'Tipo', 'Token', 'Lexema', 'Valor', 'Linha', 'Coluna']
tabela_lexica_as_h = tabela_lexica.map { |row| row.instance_variables.map { |var, _| row.instance_variable_get(var) } }
table = Terminal::Table.new(headings: cabecalhos, rows: tabela_lexica_as_h)
puts table

data = {}
root_name = "#{parsing.root.class.name}(#{parsing.root.value.inspect})"
data["#{root_name}"] = []
parsing.root.nodes.each do |node|
  data["#{root_name}"] << "#{node.class.name}(#{node.debug})"
end
tree = TTY::Tree.new(data)
puts tree.render
# Fim da Exibição
