# frozen_string_literal: true

class Scanner
  ARQUIVO_SAIDA = './tabela-lexica.yaml'

  def initialize(file)
    @file = file
    @modo = :normal
    File.open(ARQUIVO_SAIDA, 'w')
  end

  def scan
    @file.lines.each_with_index do |line, index|
      @scanner = StringScanner.new(line.upcase.strip)
      @posicao = Posicao.new(linha: index, coluna: @scanner.pointer)

      until @scanner.eos?
        if @modo == :normal && (token = get_next_token)
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
    store = YAML::Store.new(ARQUIVO_SAIDA)
    store.transaction do
      ids = store.roots.slice(index, length)
      return ids.map { |id| store[id] }
    end
  end

  private

  def get_next_token
    token_achado = nil

    Token.types.each do |type, re|
      @scanner.skip(/\s*/) # Ignora espaco(s) em branco
      regexp = /#{re.source}/i # Ignora case na string
      @posicao.coluna = @scanner.pointer + 1
      match = @scanner.scan(regexp)
      next unless match

      token = type.to_s
      lexema = nil
      valor = nil

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

      token_achado = Token.new(match, type, token, lexema, valor, @posicao.linha, @posicao.coluna)

      break(token_achado)
    end

    return token_achado
  end

  def push_token(token)
    store = YAML::Store.new(ARQUIVO_SAIDA)
    store.transaction do
      ultimo_id = store.roots.last || 0
      proximo_id = ultimo_id + 1

      store[proximo_id] = token
    end
  end

  def erro_lexico
    raise ScannerError.new(@scanner, @posicao)
  end
end
