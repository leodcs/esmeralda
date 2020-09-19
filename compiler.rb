Dir['./lib/config/**/*.rb'].sort.each { |config| require config }

require './lib/token'
require './lib/scanner'
require './lib/parser'
require './lib/semantic'
require './lib/nodes/node'
require './lib/nodes/expression'
Dir['./lib/exceptions/*.rb'].each { |exception| require exception }
Dir['./lib/nodes/*.rb'].sort.each { |node| require node }

# Debugging
require 'pry'
require 'terminal-table'
require 'awesome_print'
require 'rgl/adjacency'
require 'rgl/dot'
# End Debugging

class Compiler
  def compile(file)
    begin
      scan(file)
      parse
      analyze_semantic
    rescue StandardError => exception
      exception.set_backtrace([])
      puts exception.message
      exit
    end

    debug if ARGV[0] == '--debug'
  end

  def scan(file)
    $tabela_lexica = Scanner.new(file).scan
  end

  def parse
    $parse = Parser.new($tabela_lexica).parse
  end

  def analyze_semantic
    Semantic.new($parse).analyze
  end

  def debug
    cabecalhos = ['Texto', 'Tipo', 'Token', 'Lexema', 'Valor', 'Linha', 'Coluna']
    tabela_lexica_as_h = $tabela_lexica.map { |row| row.instance_variables.map { |var, _| row.instance_variable_get(var) } }
    table = Terminal::Table.new(headings: cabecalhos, rows: tabela_lexica_as_h)
    puts table

    begin
      root = $parse.root
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
    end
  end
end

file = File.read('input.txt')
Compiler.new.compile(file)
