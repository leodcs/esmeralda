Dir['./lib/config/**/*.rb'].sort.each { |config| require config }

require './lib/token'
require './lib/scanner'
require './lib/parser'
require './lib/nodes/node'
Dir['./lib/exceptions/*.rb'].each { |exception| require exception }
Dir['./lib/nodes/*.rb'].sort.each { |node| require node }

# Debugging
require 'pry'
require 'terminal-table'
require 'awesome_print'
require 'rgl/adjacency'
require 'rgl/dot'
# End Debugging

arquivo = File.read('input.txt')

# Inicio da Compilacao
begin
  tabela_lexica = Scanner.new(arquivo).scan
  parse = Parser.new(tabela_lexica).parse
rescue StandardError => e
  e.set_backtrace([])
  puts e.message
  exit
end
# Fim da Compilacao

# Debugging das etapas
cabecalhos = ['Texto', 'Tipo', 'Token', 'Lexema', 'Valor', 'Linha', 'Coluna']
tabela_lexica_as_h = tabela_lexica.map { |row| row.instance_variables.map { |var, _| row.instance_variable_get(var) } }
table = Terminal::Table.new(headings: cabecalhos, rows: tabela_lexica_as_h)
puts table

begin
  root = parse.root
  def nodify(graph, parent, nodes)
    nodes.each do |node|
      graph.add_edge(parent.debug_name, node.debug_name)

      nodify(graph, node, node.nodes) if node.nodes.present?
    end
  end

  graph = RGL::DirectedAdjacencyGraph.new
  root.nodes.each do |node|
    graph.add_edge(root.debug_name, node.debug_name)
    nodify(graph, node, node.nodes)
  end

  graph.write_to_graphic_file('png', 'parse', { 'vertex' => { 'fontsize' => 15 }})
rescue StandardError => e
  p e
  binding.pry
end
# Fim do Debugging
