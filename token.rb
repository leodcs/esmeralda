# frozen_string_literal: true

Token = Struct.new(:token, :lexema, :valor, :linha, :coluna) do
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
    { palavra_reservada: /begin|end|if|then|else|while|do|until|repeat|integer|real|all|string|program/,
      id: id,
      real: /\b#{integer}\.#{integer}\b/,
      integer: /\b#{integer}\b/,
      string: id,
      operador: /\bor|and\b|<>|<=|>=|<|>|=|\+|-|\*|\/|{|}/,
      especial: /\.|,|;|\(|\)|:=/ }
  end
end
