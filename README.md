# RubyScraping

## Descrição
O projeto RubyScraping é uma ferramenta Ruby desenvolvida especificamente para coletar dados de análise de tráfego da web do SimilarWeb. Por padrão o projeto roda na porta 4567.

## Observação
Foi necessário a utilização da biblioteca Watir, pois a página do SimilarWeb precisa ficar aberta por 5 segundos devido a uma validação específica para poder carregar o conteúdo da página.

## Pré-requisitos
Certifique-se de ter as seguintes ferramentas instaladas em seu sistema:
- Ruby
- RubyGems
- Bundler (caso não esteja instalado, você pode instalá-lo com `gem install bundler`)

## Instalando as dependências

1. Para instalar as dependências execute este comando:
bundle install

## Variáveis de ambiente

1. Utilize o arquivo .env.example como modelo para definir suas variáveis de ambiente.

## Executando o projeto

1. Para executar o projeto execute esse comando: 
ruby app.rb

## Endpoints da API

### 1. /salve_info
**Descrição:** Este endpoint permite iniciar o processamento para coletar informações de um site especificado.

**Método HTTP:** POST

**Parâmetros de Solicitação:**
- `url` (string) - A URL do site que deseja coletar informações, passada como parâmetro query `?url` sem o "https://" e "www".

**Exemplo de Solicitação:**
```http
POST http://localhost:4567/salve_info?url=google.com
```

### 2. /get_info/:url
**Descrição:** Este endpoint permite consultar as informações coletadas de um site após o processamento.

**Método HTTP:** POST

**Parâmetros de Solicitação:**
- `url` (string) - A url desejada.


**Exemplo de Solicitação:**
```http
POST http://localhost:4567/get_info/google.com
```

### 3. /status/:id
**Descrição:** Este endpoint permite consultar o status do processamento de um site com base no ID do processo.

**Método HTTP:** GET

**Parâmetros de Solicitação:**
- `id` (string) - O ID do processo.


**Exemplo de Solicitação:**
```http
GET http://localhost:4567/status/6924f30b-bd06-4067-ac5a-0edad6074651
```




   