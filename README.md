# Gen-AI Procedures

Este projeto facilita a geração e execução de procedimentos AI utilizando Docker e Makefile para automatizar o processo.

## Requisitos

Para utilizar este projeto, você precisa ter instalado:

- Docker
- Make

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
make run ROLE_NAMES="Analista Desenvolvedor"
```

O valor default de ROLE_NAMES é Analista

## Limpeza

Para remover a imagem Docker criada pelo Makefile, você pode usar o seguinte comando Docker:

```bash
docker rmi $(IMAGE_NAME):$(VERSION)
```

Certifique-se de substituir $(IMAGE_NAME) e $(VERSION) pelos valores reais se você os modificou no Makefile.