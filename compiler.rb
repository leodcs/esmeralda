require 'pry'
require './lexer'
require './token'

arquivo = File.read('test.src')
tabela_lexica = Lexer.new(arquivo).tokenize
puts tabela_lexica.map(&:inspect).join("\n")
