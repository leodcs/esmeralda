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

  def Token.letra
    /[a-zA-Z]/
  end

  def Token.digito
    /[0-9]/
  end

  def Token.id
    /\b#{Token.letra}(#{Token.letra}|#{Token.digito})*\b/
  end

  def Token.integer
    /#{Token.digito}+/
  end

  def Token.types
    {
      'PalavraReservada': /PROGRAM|BEGIN|END|IF|THEN|ELSE|WHILE|DO|UNTIL|REPEAT|INTEGER|REAL|ALL|STRING/,
      'OpBooleano': /\bOR|AND\b/,
      'Id': Token.id,
      'Real': /\b#{Token.integer}\.#{Token.integer}\b/,
      'Integer': /\b#{Token.integer}\b/,
      'String': Token.id,
      'OpRelacional': /<>|<=|>=|<|>|=/,
      'OpAritmetico': /\+|-|\*|\//,
      'Especial': /\.|,|:=/,
      'AbreChave': /{/,
      'FechaChave': /}/,
      'AbreParen': /\(/,
      'FechaParen': /\)/,
      'PontoVirgula': /;/
    }
  end
end
