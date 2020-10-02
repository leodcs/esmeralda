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

# Configura pasta atual para ser a mesma do executável
if ENV['OCRA_EXECUTABLE']
  pasta = File.dirname(ENV['OCRA_EXECUTABLE'])
  Dir.chdir(pasta)
end

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

reader = TTY::Reader.new

reader.on(:keyescape) do
  puts 'Finalizando...'
  exit
end

loop do
  puts 'Tecle ESC para encerrar ou digite o nome do arquivo e tecle Enter'
  nome_arquivo = reader.read_line('Nome do arquivo (sem extensão): ').chomp
  next if nome_arquivo.blank?

  if File.file?(nome_arquivo)
    arquivo = File.read(nome_arquivo)
    begin
      puts 'Compilando...'.colorize(:blue)

      Compiler.new.compile(arquivo)

      puts 'Compilação efetuada com sucesso.'.colorize(:green)
    rescue StandardError => erro_esperado
      erro_esperado.set_backtrace([])
      puts erro_esperado.message.colorize(:red)
    ensure
      puts
    end
  else
    puts "Arquivo #{nome_arquivo.inspect} não encontrado na pasta #{Dir.pwd.inspect}".colorize(:red)
  end
end
