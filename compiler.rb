Dir['./lib/config/**/*.rb'].sort.each { |config| require config }
require 'colorize'
require 'tty-reader'
require './lib/scanner'
require './lib/parser'
require './lib/semantic'
require './lib/gerador_intermediario'
Dir['./lib/exceptions/*.rb'].each { |exception| require exception }

class Compiler
  def compile(file)
    scan(file)
    parse
    analyze_semantic
    generate_intermediate_code
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

  def generate_intermediate_code
    quadruplas = GeradorIntermediario.call($parse).quadruplas

    require 'terminal-table'
    header = ['', 'operador', 'arg1', 'arg2', 'resultado']
    table = Terminal::Table.new(title: 'Código Intermediário', headings: header, style: { width: 80 }) do |t|
      quadruplas.each do |q|
        t << :separator
        t << [q.linha, q.operador, q.arg1, q.arg2, q.resultado]
      end
    end

    puts table
  end
end

# Configura pasta atual para ser a mesma do executável
Dir.chdir File.dirname(ENV['OCRA_EXECUTABLE']) if ENV['OCRA_EXECUTABLE']

reader = TTY::Reader.new(interrupt: :exit)

#-------------------- Para facilitar o desenvolvimento
require 'pry'
reader.on(:keyctrl_r) do
  puts 'Reloading...'.colorize(:blue)
  # Main project directory.
  root_dir = File.expand_path('..', __dir__)
  # Directories within the project that should be reloaded.
  reload_dirs = ['lib', 'lib/config', 'lib/nodes']
  # Loop through and reload every file in all relevant project directories.
  reload_dirs.each do |dir|
    Dir["./#{dir}/*.rb"].each { |f| load(f) }
  end

  puts 'Code reloaded!'.colorize(:green)
  # Return true when complete.
  true
end
#--------------------

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
    # rescue StandardError => erro_esperado
    #   erro_esperado.set_backtrace([])
    #   puts erro_esperado.message.colorize(:red)
    ensure
      puts
    end
  else
    puts "Arquivo #{nome_arquivo.inspect} não encontrado na pasta #{Dir.pwd.inspect}".colorize(:red)
  end
end
