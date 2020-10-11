# frozen_string_literal: true

class Object
  # Método personalizado para verificar se um objeto está vazio ou não
  # Qualquer tipo de objeto vai extender esse método através de herança
  # Exemplos
  # "".vazio? => true
  # "texto".vazio? => false
  # [].vazio? => true
  # [nil].vazio? => false
  # 0.vazio? => false
  # nil.vazio? => true
  def vazio?
    respond_to?(:empty?) ? !!empty? : !self
  end
end
