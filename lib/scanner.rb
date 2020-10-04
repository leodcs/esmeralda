# frozen_string_literal: true

class Scanner
  ARQUIVO_SAIDA = './tabela-lexica.yaml'

  def initialize(arquivo)
    @arquivo = arquivo
    @modo = :normal
    File.open(ARQUIVO_SAIDA, 'w')
  end

  def scan
    @arquivo.lines.each_with_index do |line, index|
      texto_formatado = line.upcase # Modifica texto da linha para UPCASE
      texto_formatado.gsub!(/\u00a0/, ' ') # padroniza espacos em branco
      texto_formatado.delete!("\n") # remove quebras de linhas
      next if texto_formatado.strip.blank? # Ignora linha em branco

      @fita = StringScanner.new(texto_formatado)
      @posicao = Posicao.new(linha: index, coluna: @fita.pointer)

      # Repete até chegar no fim da linha
      until @fita.eos? do
        if @modo == :comentario || @fita.scan(/\s*{/)
          ignora_comentarios
        elsif @modo == :normal && (token = get_next_token)
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

    Token.types.each do |type, regexp|
      @posicao.coluna = @fita.pointer + 1
      @fita.skip(/[[:space:]]*/) # Pula espaco(s) em branco no comeco da linha
      match = @fita.scan(regexp)
      next unless match

      token = type.to_s
      lexema = nil
      valor = nil

      case type
      when :INTEGER
        token = 'Numerico'
        valor = match.to_i
      when :REAL
        token = 'Numerico'
        valor = BigDecimal(match)
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

  def ignora_comentarios
    fecha_chave = Token.types[:FECHA_CHAVE]

    if @fita.exist?(fecha_chave)
      @fita.skip_until(fecha_chave)
      @modo = :normal
    else
      @modo = :comentario
      @fita.terminate
    end
  end

  def erro_lexico
    raise ScannerError.new(@fita, @posicao)
  end
end
