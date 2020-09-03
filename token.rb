# frozen_string_literal: true

# TODO: Adicionar coluna para salvar o match

Token = Struct.new(:match, :type, :token, :lexema, :valor, :linha, :coluna) do
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
      achave: /{/,
      fchave: /}/,
      aparen: /\(/,
      fparen: /\)/,
      op_booleano: /\bOR|AND\b/,
      id: id,
      real: /\b#{integer}\.#{integer}\b/,
      integer: /\b#{integer}\b/,
      string: id,
      op_relacional: /<>|<=|>=|<|>|=/,
      op_aritmetico: /\+|-|\*|\//,
      especial: /\.|,|;|:=/ }
  end
end
