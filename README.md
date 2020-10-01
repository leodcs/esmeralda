# Esmeralda
<p align="center">
  <img width="150" height="150" src="https://i.imgur.com/38xxS4c.png">
</p>

<p align="center">
  Um compilador para a matéria de Compiladores (8ᵒ período, 2020.2) <br/>
  no curso de Ciência da Computação, FACAPE.
</p>

# Fases da compilação
![esmeralda.png](https://i.imgur.com/7wbXPu0.png)

# Como usar

Para usar, é necessário modificar o arquivo `input.txt`
conforme a sintaxe da linguagem e rodar o seguinte comando dentro da pasta do projeto:

```ruby
ruby compiler.rb
```

# Observação importante :warning:
A depender do tamanho do algoritmo sendo compilado, é possível que a compilação demore proporcionalmente. </br>
Isso é devido a usarmos um arquivo, ao invés da memória RAM, para salvar a tabela léxica. <br/>
Para visualizá-la, veja o arquivo gerado no caminho: `tmp/tabela-lexica.yaml`