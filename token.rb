# frozen_string_literal: true

class Token
  attr_accessor :type
  attr_accessor :value

  def initialize(type, value)
    @type = type
    @value = value
  end
end
