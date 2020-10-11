# frozen_string_literal: true

class Token
  attr_reader :match, :type, :token, :lexema, :valor, :posicao

  def initialize(match, type, token = nil, lexema = nil, valor = nil, posicao = nil)
    @match = match
    @type = type
    @token = token
    @lexema = lexema
    @valor = valor
    @posicao = posicao
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
    { :ALL => /\bALL\b/,
      :PROGRAM => /\bPROGRAM\b/,
      :BEGIN => /\bBEGIN\b/,
      :END => /\bEND\b/,
      :IF => /\bIF\b/,
      :THEN => /\bTHEN\b/,
      :ELSE => /\bELSE\b/,
      :WHILE => /\bWHILE\b/,
      :DO => /\bDO\b/,
      :UNTIL => /\bUNTIL\b/,
      :REPEAT => /\bREPEAT\b/,
      :OP_BOOLEANO => /\bOR|AND\b/,
      :TIPO_VAR => /\bSTRING|INTEGER|REAL\b/,
      :ID => Token.id,
      :REAL => /\b#{Token.integer}\.#{Token.integer}\b/,
      :INTEGER => /\b#{Token.integer}\b/,
      :OP_RELACIONAL => /<>|<=|>=|<|>|=/,
      :OP_ARITMETICO => /\+|-|\*|\//,
      :ATRIB => /:=/,
      :VIRGULA => /,/,
      :ABRE_CHAVE => /{/,
      :FECHA_CHAVE => /}/,
      :ABRE_PAREN => /\(/,
      :FECHA_PAREN => /\)/,
      :PONTO => /\./,
      :PONTO_VIRGULA => /;/ }
  end
end
