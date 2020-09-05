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
    { 'program': /\bPROGRAM\b/,
      'begin': /\bBEGIN\b/,
      'end': /\bEND\b/,
      'if': /\bIF\b/,
      'then': /\bTHEN\b/,
      'else': /\bELSE\b/,
      'while': /\bWHILE\b/,
      'do': /\bDO\b/,
      'until': /\bUNTIL\b/,
      'repeat': /\bREPEAT\b/,
      'op_booleano': /\bOR|AND\b/,
      'id': Token.id,
      'real': /\b#{Token.integer}\.#{Token.integer}\b/,
      'integer': /\b#{Token.integer}\b/,
      'string': Token.id,
      'op_relacional': /<>|<=|>=|<|>|=/,
      'op_aritmetico': /\+|-|\*|\//,
      'especial': /,|:=/,
      'abre_chave': /{/,
      'fecha_chave': /}/,
      'abre_paren': /\(/,
      'fecha_paren': /\)/,
      'ponto': /\./,
      'ponto_virgula': /;/ }
  end
end
