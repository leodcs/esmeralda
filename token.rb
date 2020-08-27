# frozen_string_literal: true

Token = Struct.new(:type, :value, :line, :column) do
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
    { obrace: /{/,
      cbrace: /}/,
      palavra_reservada: /begin|end|if|then|else|while|do|until|repeat|integer|real|all|string|program/,
      op_booleano: /\bor|and\b/,
      id: id,
      real: /\b#{integer}\.#{integer}\b/,
      integer: /\b#{integer}\b/,
      string: id,
      op_relacional: /<>|<=|>=|<|>|=/,
      op_aritmetico: /\+|-|\*|\//,
      especial: /\.|,|;|\(|\)|:=/ }
  end
end
