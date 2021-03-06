require 'strscan'
require_relative 'posicao'
require_relative 'token'
require_relative 'arquivo_saida'

class Scanner
  SAIDA = './tabela-lexica.yaml'

  def initialize(arquivo)
    @arquivo = padroniza_encoding(arquivo)
    @modo = :normal
    @tokens = ArquivoSaida.new(SAIDA)
  end

  # Essa é a função principal do Scanner.
  # Varre todas linhas do @arquivo e salva os tokens no ARQUIVO_SAIDA
  def scan
    @arquivo.lines.each_with_index do |line, index|
      texto_formatado = line.rstrip.chomp # Remove quebras de linhas (\n) e espaços desnecessarios no fim da linha
      texto_formatado.upcase! # Modifica texto da linha para UPCASE
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
          push_token(token) unless token.type == :ESPACO
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
  def le_tokens(index, length = 1)
    @tokens.read(index, length)
  end

  # Le todos os tokens do primeiro (0) em diante (..)
  def todos_tokens
    le_tokens(0..)
  end

  private

  def get_next_token
    token_achado = nil

    # Itera em todos os tipos de tokens definidos em Token.types até encontrar um
    Token.types.each do |type, regexp|
      @posicao.coluna = @fita.pointer + 1
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
        valor = match.to_f
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
    @tokens.push(token)
  end

  def ignora_comentarios
    fecha_chave = Token.types[:FECHA_CHAVE]

    # Se tiver "}" na mesma linha, move o ponteiro para depois do "}".
    # Se não tiver, coloca no modo "comentario" e ignora a linha atual inteira
    if @fita.exist?(fecha_chave)
      @fita.skip_until(fecha_chave)
      @modo = :normal
    else
      @modo = :comentario
      @fita.terminate
    end
  end

  # Tentar padronizar o arquivo para o encoding UTF-8
  def padroniza_encoding(arquivo)
    arquivo_limpo = arquivo.dup.force_encoding('UTF-8')
    unless arquivo_limpo.valid_encoding?
      arquivo_limpo = arquivo.encode('UTF-8', 'Windows-1252' )
    end
    return arquivo_limpo
  rescue EncodingError
    # Força para UTF-8, sobrescrevendo caracteres inválidos
    arquivo.encode!('UTF-8', invalid: :replace, undef: :replace)
  end

  def erro_lexico
    raise ScannerError.new(@fita, @posicao)
  end
end
