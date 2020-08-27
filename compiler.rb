require 'pry'
require './scanner'
require './token'

arquivo = File.read('test.src')
tabela_lexica = Scanner.new(arquivo).tokenize
puts tabela_lexica.map(&:inspect).join("\n")
