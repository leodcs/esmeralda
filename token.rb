# frozen_string_literal: true

class Token
  attr_reader :match, :type, :token, :lexema, :valor, :linha, :coluna

  def initialize(match, type, token, lexema, valor, linha, coluna)
    @match = match
    @type = type
    @token = token
    @lexema = lexema
    @valor = valor
    @linha = linha
    @coluna = coluna
  end

  def self.letra
    /[a-zA-Z]/
  end

  def self.digito
    /[0-9]/
  end

  def self.id
    /\b#{letra}(#{letra}|#{digito})*\b/
  end

  def self.integer
    /#{digito}+/
  end

  def self.types
    { palavra_reservada: /BEGIN|END|IF|THEN|ELSE|WHILE|DO|UNTIL|REPEAT|INTEGER|REAL|ALL|STRING|PROGRAM/,
      abre_chave: /{/,
      fecha_chave: /}/,
      abre_paren: /\(/,
      fecha_paren: /\)/,
      ponto_virgula: /;/,
      op_booleano: /\bOR|AND\b/,
      id: id,
      real: /\b#{integer}\.#{integer}\b/,
      integer: /\b#{integer}\b/,
      string: id,
      op_relacional: /<>|<=|>=|<|>|=/,
      op_aritmetico: /\+|-|\*|\//,
      especial: /\.|,|:=/ }
  end
end
