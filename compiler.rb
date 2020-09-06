Dir['./config/**/*.rb'].sort.each { |config| require config }

require './lib/token'
require './lib/scanner'
require './lib/parser'
Dir['./lib/nodes/*.rb'].sort.each { |node| require node }

# Debugging
require 'pry'
require 'terminal-table'
require 'rgl/adjacency'
require 'rgl/dot'
# End Debugging

arquivo = File.read('input.txt')

# Inicio da Compilacao
# begin
  tabela_lexica = Scanner.new(arquivo).scan
  parse = Parser.new(tabela_lexica).parse
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

root = parse.root
root_name = "#{root.class.name}(#{root.value.inspect})"

def nodify(graph, parent, nodes)
  nodes.each do |node|
    graph.add_edge(parent.inspect, node.inspect)

    nodify(graph, node, node.nodes) if node.nodes.present?
  end
end

graph = RGL::DirectedAdjacencyGraph.new
root.nodes.each do |node|
  graph.add_edge(root_name, node.inspect)
  nodify(graph, node, node.nodes)
end

graph.write_to_graphic_file('jpg', 'parse')
`open parse.jpg`
# Fim da Exibição
