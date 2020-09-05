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
    { 'Program': /\bPROGRAM\b/,
      'Begin': /\bBEGIN\b/,
      'End': /\bEND\b/,
      'If': /\bIF\b/,
      'Then': /\bTHEN\b/,
      'Else': /\bELSE\b/,
      'While': /\bWHILE\b/,
      'Do': /\bDO\b/,
      'Until': /\bUNTIL\b/,
      'Repeat': /\bREPEAT\b/,
      'OpBooleano': /\bOR|AND\b/,
      'Id': Token.id,
      'Real': /\b#{Token.integer}\.#{Token.integer}\b/,
      'Integer': /\b#{Token.integer}\b/,
      'String': Token.id,
      'OpRelacional': /<>|<=|>=|<|>|=/,
      'OpAritmetico': /\+|-|\*|\//,
      'Especial': /,|:=/,
      'AbreChave': /{/,
      'FechaChave': /}/,
      'AbreParen': /\(/,
      'FechaParen': /\)/,
      'Ponto': /\./,
      'PontoVirgula': /;/ }
  end
end
