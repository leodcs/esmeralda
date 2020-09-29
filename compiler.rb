Dir['./lib/config/**/*.rb'].sort.each { |config| require config }

require 'yaml/store'
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
require 'rgl/adjacency'
require 'rgl/dot'
# End Debugging

class Compiler
  def compile(file)
    if ARGV[0] == '--verbose' || ARGV[0] == '-v'
      run(file)
    else
      begin
        run(file)
      rescue StandardError => exception
        exception.set_backtrace([])
        puts exception.message
        exit
      end
    end

    debug if ARGV.include?('--open')
  end

  def run(file)
    scan(file)
    parse
    analyze_semantic
  end

  def scan(file)
    $scan = Scanner.new(file).scan
  end

  def parse
    $parse = Parser.new.parse
  end

  def analyze_semantic
    Semantic.new($parse).analyze
  end

  def debug
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
      `open parse.png`
    rescue StandardError => e
      p e
    end
  end
end

file = File.read('input.txt')
Compiler.new.compile(file)
