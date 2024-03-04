##
##

IMAGE_NAME=gen-ai-procedures
VERSION=v0.0.1

# O Path para o Dockerfile
DOCKERFILE_PATH=./Dockerfile

# Construir a imagem Docker
build:
	docker build -t $(IMAGE_NAME):$(VERSION) -f $(DOCKERFILE_PATH) .

# Rodar o container
run:
	docker run --rm -it -v $(PWD)/output:/app/output -e ROLE_NAMES="${ROLE_NAMES}"  -e OPENAI_API_KEY="${OPENAI_API_KEY}" $(IMAGE_NAME):$(VERSION)


all: build

.PHONY: build run all