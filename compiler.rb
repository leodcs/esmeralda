Dir['./lib/config/**/*.rb'].sort.each { |config| require config }
require 'colorize'
require 'tty-reader'
require './lib/scanner'
require './lib/parser'
require './lib/semantic'
Dir['./lib/exceptions/*.rb'].each { |exception| require exception }

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

# Configura pasta atual para ser a mesma do executável
Dir.chdir File.dirname(ENV['OCRA_EXECUTABLE']) if ENV['OCRA_EXECUTABLE']
reader = TTY::Reader.new(interrupt: :exit)

reader.on(:keyescape, :keyctrl_d) do
  puts 'Finalizando...'
  exit
end

loop do
  puts 'Tecle ESC para encerrar ou digite o nome do arquivo e tecle Enter'
  nome_arquivo = reader.read_line('Nome do arquivo: ').chomp
  next if nome_arquivo.vazio?

  if File.file?(nome_arquivo)
    arquivo = File.read(nome_arquivo)
    begin
      puts 'Compilando...'.colorize(:blue)
      if Compiler.new.compile(arquivo)
        puts 'Compilação efetuada com sucesso.'.colorize(:green)
      end
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
