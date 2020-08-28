require 'pry'
require './scanner'
require './token'

arquivo = File.read('test.src')
tabela_lexica = Scanner.scan(arquivo)
puts tabela_lexica.map(&:inspect).join("\n")
