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











# CONFIG_FILE=./procedures.json
# ROLE_NAME=Desempenho
# # Analista - Mermaid - Desenvolvedor - Desempenho

# OPENAI_API_KEY=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
# ROLE_DESCRIPTION=$(shell jq -r --arg ROLE_NAME "$(ROLE_NAME)" '.Roles[] | select(.Name==$$ROLE_NAME) | .Description' $(CONFIG_FILE))
# TEMPLATE_PATH=$(shell jq -r --arg ROLE_NAME "$(ROLE_NAME)" '.Roles[] | select(.Name==$$ROLE_NAME) | .TemplatePath' $(CONFIG_FILE))
# PROMPT=$(shell jq -r --arg ROLE_NAME "$(ROLE_NAME)" '.Roles[] | select(.Name==$$ROLE_NAME) | .Prompt' $(CONFIG_FILE))
# OUTPUT_PATH=$(shell jq -r --arg ROLE_NAME "$(ROLE_NAME)" '.Roles[] | select(.Name==$$ROLE_NAME) | .OutputPath' $(CONFIG_FILE))


# SCRIPT=./src/procedure_genai.py
# PROMPT_FILE_PATH=./SP/foobar.sql

# .PHONY: run
# run:
# 	@echo "Executando o script com as configurações da role $(ROLE_NAME)..."
# 	@echo $(OPENAI_API_KEY)
# 	@python3 $(SCRIPT) "$(OPENAI_API_KEY)" "$(ROLE_DESCRIPTION)" "$(TEMPLATE_PATH)" "$(PROMPT)" "$(PROMPT_FILE_PATH)" "$(OUTPUT_PATH)"