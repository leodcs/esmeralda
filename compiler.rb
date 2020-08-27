require 'pry'
require './lexer'
require './token'

file = File.read('test.src')
tokens = Lexer.new(file).tokenize
puts tokens.map(&:inspect).join("\n")
