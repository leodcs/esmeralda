Dir['./lib/config/**/*.rb'].sort.each { |config| require config }

require 'colorize'
require 'tty-reader'
require 'yaml/store'
require './lib/token'
require './lib/scanner'
require './lib/parser'
require './lib/semantic'
require './lib/nodes/node'
require './lib/nodes/expression'
Dir['./lib/exceptions/*.rb'].each { |exception| require exception }
Dir['./lib/nodes/*.rb'].sort.each { |node| require node }

class Compiler
  def compile(file)
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
end

caminho_executavel = ENV.fetch('OCRA_EXECUTABLE', Dir.pwd)
reader = TTY::Reader.new

reader.on(:keyescape) do
  puts "Finalizando..."
  exit
end

loop do
  puts 'Tecle ESC para encerrar ou digite o nome do arquivo e tecle Enter'
  nome_arquivo = reader.read_line('Nome do arquivo (sem extensão): ').chomp
  next if nome_arquivo.blank?
  caminho_arquivo = File.join('.', nome_arquivo)

  if File.file?(caminho_arquivo)
    arquivo = File.read(caminho_arquivo)
    begin
      puts 'Compilando...'.colorize(:blue)
      Compiler.new.compile(arquivo)
      puts 'Compilação efetuada com sucesso.'.colorize(:green)
    rescue StandardError => exception
      exception.set_backtrace([])
      puts exception.message.colorize(:red)
    ensure
      puts
    end
  else
    puts "Arquivo não encontrado: \"#{nome_arquivo}\"".colorize(:red)
  end
end
