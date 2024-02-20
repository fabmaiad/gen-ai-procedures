# Gen-AI Procedures

Este projeto facilita a geração e execução de procedimentos AI utilizando Docker e Makefile para automatizar o processo.

## Requisitos

Para utilizar este projeto, você precisa ter instalado:

- Docker
- Make

# Disclaimer

Para utilizar este projeto, é necessário ter uma **API Key** válida, que pode ser obtida através do contato com **Fabio Maia**.

## Solicitando a API Key

Entre em contato com [Fabio Maia](mailto:fabiomaia@ciandt.com) para solicitar sua API Key. Este passo é crucial para garantir o acesso e a funcionalidade do projeto.

## Configurando a API Key como Variável de Ambiente

Após receber sua API Key, você deve configurá-la como uma variável de ambiente em seu sistema para que o projeto possa utilizá-la de forma segura. Siga as instruções abaixo para configurar a variável de ambiente em sistemas baseados em Unix (Linux/MacOS):

1. Abra o terminal.
2. Execute o seguinte comando, substituindo `SUA_API_KEY` pela chave que você recebeu:

   ```bash
   export OPENAI_API_KEY="SUA_API_KEY"

## Configuração

Antes de construir e executar o container, você pode customizar o nome e a versão da imagem Docker modificando as variáveis `IMAGE_NAME` e `VERSION` no `Makefile`.

## Comandos Disponíveis

### Construir a Imagem Docker

Para construir a imagem Docker com o nome e a versão especificados no `Makefile`, execute:

```bash
make build
```

### Rodar o Container

Para rodar o container Docker, use o seguinte comando:

```bash
make run 
```

Você pode passar múltiplos nomes de roles para o container usando a variável ROLE_NAMES. Por exemplo:

```bash
make run ROLE_NAMES="Analista Desenvolvedor" OPENAI_API_KEY=$OPENAI_API_KEY
```

O valor default de ROLE_NAMES é Analista

## Limpeza

Para remover a imagem Docker criada pelo Makefile, você pode usar o seguinte comando Docker:

```bash
docker rmi $(IMAGE_NAME):$(VERSION)
```

Certifique-se de substituir $(IMAGE_NAME) e $(VERSION) pelos valores reais se você os modificou no Makefile.