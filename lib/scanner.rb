require 'strscan'
require 'yaml/store'
require 'bigdecimal'
require './lib/posicao'
require './lib/token'

class Scanner
  ARQUIVO_SAIDA = './tabela-lexica.yaml'

  def initialize(arquivo)
    @arquivo = arquivo
    @modo = :normal
    File.open(ARQUIVO_SAIDA, 'w')
  end

  # Essa é a função principal do Scanner.
  # Varre todas linhas do @arquivo e salva os tokens no ARQUIVO_SAIDA
  def scan
    @arquivo.lines.each_with_index do |line, index|
      texto_formatado = line.upcase # Modifica texto da linha para UPCASE
      texto_formatado.gsub!(/\u00a0/, ' ') # padroniza espacos em branco
      texto_formatado.delete!("\n") # remove quebras de linhas
      next if texto_formatado.strip.vazio? # Ignora linha em branco

      # "StringScanner" é uma classe interna do Ruby que recebe uma string de entrada,
      # que nesse caso é o texto da linha atual, e permite varrê-la usando expressões regulares.
      # Link para documentação: https://ruby-doc.org/stdlib-2.6.1/libdoc/strscan/rdoc/StringScanner.html
      @fita = StringScanner.new(texto_formatado)
      @posicao = Posicao.new(linha: index, coluna: @fita.pointer)

      # Repete até chegar no fim da linha
      until @fita.eos? do
        # Se estiver no modo "comentario" ou o próximo caractere é um "{"
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

  # Usado para ler os tokens depois de gerar a tabela léxica
  # le_tokens(0) => retorna o token na posicao zero, ou seja o primeiro token
  # le_tokens(15, 3) => retorna 3 tokens a partir da posicao 15
  # le_tokens(60..) => retorna todos os tokens a partir da posicao 60 até o final da tabela
  def le_tokens(index, length = 1)
    saida = arquivo_saida
    saida.transaction do
      roots = saida.roots
      if index.class == Range
        ids = roots.slice(index)
      else
        ids = roots.slice(index, length)
      end
      return ids.map { |id| saida[id] }
    end
  end

  # Le todos os tokens do primeiro (0) em diante (..)
  def todos_tokens
    le_tokens(0..)
  end

  def arquivo_saida
    YAML::Store.new(ARQUIVO_SAIDA)
  end

  private

  def get_next_token
    token_achado = nil

    # Itera em todos os tipos de tokens definidos em Token.types até encontrar um
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

      token_achado = Token.new(match, type, token, lexema, valor, @posicao)

      break(token_achado) # Para a iteracao caso encontre algum token
    end

    return token_achado
  end

  # Escreve token no ARQUIVO_SAIDA da tabela léxica
  def push_token(token)
    saida = arquivo_saida
    saida.transaction do
      ultimo_id = saida.roots.last || 0
      proximo_id = ultimo_id + 1

      saida[proximo_id] = token
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
