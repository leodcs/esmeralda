# frozen_string_literal: true

class Scanner
  TOKENS_OUT = './tmp/tabela-lexica.yaml'

  def initialize(file)
    @file = file
    @current_state = :default
    File.open(TOKENS_OUT, 'w')
  end

  def scan
    @file.lines.each_with_index do |line, index|
      @full_line = line.upcase
      @text_to_scan = @full_line.strip
      @line_number = index + 1

      until @text_to_scan.empty? do
        if @current_state == :comment || @text_to_scan.start_with?('{')
          ignora_comentarios
        elsif @current_state == :default && (token = get_next_token)
          push_token(token)
        else
          erro_lexico
        end
      end
    end

    fim_arquivo = Token.new('FIM_DO_ARQUIVO', :FIM)
    push_token(fim_arquivo)

    return self
  end

  def le_tokens(index, length = 1)
    store = YAML::Store.new(TOKENS_OUT)
    store.transaction do
      ids = store.roots.slice(index, length)
      return ids.map { |id| store[id] }
    end
  end

  private

  def push_token(token)
    store = YAML::Store.new(TOKENS_OUT)
    store.transaction do
      ultimo_id = store.roots.last || 0
      proximo_id = ultimo_id + 1

      store[proximo_id] = token
    end
  end

  def ignora_comentarios
    if @text_to_scan.start_with?('{') && !@text_to_scan.end_with?('}')
      @current_state = :comment
    elsif @current_state == :comment && @text_to_scan.end_with?('}')
      @current_state = :default
    end

    @text_to_scan = ''
  end

  def current_column
    @full_line.index(@text_to_scan) + 1
  end

  def get_next_token
    token_achado = nil

    Token.types.each do |type, re|
      regexp = /\A(#{re.source})/i
      matches = @text_to_scan.match(regexp)
      next if matches.nil?

      token = type.to_s
      lexema = valor = nil
      match = matches[0]
      coluna = current_column
      @text_to_scan = @text_to_scan.delete_prefix(match).strip

      case type
      when :INTEGER, :REAL
        token = 'Numerico'
        valor = match.to_i
      when :ID, :STRING
        token = 'ID'
        lexema = match
      else
        token = match
      end

      token_achado = Token.new(match, type, token, lexema, valor, @line_number, coluna)

      break(token_achado)
    end

    return token_achado
  end

  def erro_lexico
    raise ScannerError.new(@text_to_scan, @line_number, current_column)
  end
end
