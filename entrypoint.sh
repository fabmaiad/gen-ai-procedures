#!/bin/bash

# Definindo o arquivo de configuração
CONFIG_FILE="./procedures.json"

# Definindo as roles como uma lista separada por espaços
# Opções: Analista - Mermaid - Desenvolvedor - Desempenho
ROLE_NAMES=${ROLE_NAMES:-"Analista"}

# Definindo chave da API
OPENAI_API_KEY=${OPENAI_API_KEY}

SCRIPT="./src/main.py"
PROMPT_FILE_PATH="./SP/"

for ROLE_NAME in $ROLE_NAMES; do
    ROLE_DESCRIPTION=$(jq -r --arg ROLE_NAME "$ROLE_NAME" '.Roles[] | select(.Name==$ROLE_NAME) | .Description' $CONFIG_FILE)
    TEMPLATE_PATH=$(jq -r --arg ROLE_NAME "$ROLE_NAME" '.Roles[] | select(.Name==$ROLE_NAME) | .TemplatePath' $CONFIG_FILE)
    PROMPT=$(jq -r --arg ROLE_NAME "$ROLE_NAME" '.Roles[] | select(.Name==$ROLE_NAME) | .Prompt' $CONFIG_FILE)
    OUTPUT_PATH=$(jq -r --arg ROLE_NAME "$ROLE_NAME" '.Roles[] | select(.Name==$ROLE_NAME) | .OutputPath' $CONFIG_FILE)

    # Executando o script Python para a role
    echo "****** Executando o script com as configurações da role $ROLE_NAME... ******"
    python3 $SCRIPT "$OPENAI_API_KEY" "$ROLE_DESCRIPTION" "$TEMPLATE_PATH" "$PROMPT" "$PROMPT_FILE_PATH" "$OUTPUT_PATH"
done