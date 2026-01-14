#!/bin/bash

# Author: Julio Prata
# Created: 01 dez 2025
# Last Modified: 14 jan 2026
# Version: 1.3
# Description: Script de deploy híbrido com limpeza forçada para evitar erros de diretório

# Cores
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_NAME=$(basename "$PWD")

echo -e "${CYAN}--- Iniciando Deploy para: $PROJECT_NAME ---${NC}"

# Define mensagem de commit
msg="Update $(date)"
if [ $# -eq 1 ]; then
  msg="$1"
fi

# VERIFICAÇÃO DE SITE HUGO
if [ -f "hugo.toml" ] || [ -f "config.toml" ]; then
    echo -e "${GREEN}--> Site Hugo detectado.${NC}"
    
    # BIZU: Limpeza total da pasta de destino para evitar o erro "not a directory"
    echo -e "${YELLOW}--> Limpando diretório de build (docs/)...${NC}"
    rm -rf docs/*
    
    echo -e "${GREEN}--> Iniciando build do Hugo...${NC}"
    # Tenta construir o site
    if hugo --minify -d docs; then
        echo -e "${GREEN}--> Build OK!${NC}"
    else
        echo -e "${RED}--> ERRO: Falha crítica no Hugo. Deploy cancelado.${NC}"
        exit 1
    fi
else
    # Se não for site Hugo (modo repositório simples)
    echo -e "${YELLOW}--> Nenhum arquivo Hugo detectado. Pulando build.${NC}"
fi

# PARTE DO GIT
# Verifica se há alterações
if [[ -z $(git status -s) ]]; then
    echo -e "${CYAN}--> Nada para commitar. O diretório está limpo.${NC}"
    exit 0
fi

echo -e "${GREEN}--> Enviando alterações para o GitHub...${NC}"
git add .
git commit -m "$msg ($PROJECT_NAME)"
git push origin main

echo -e "${CYAN}--- Deploy do $PROJECT_NAME concluído com sucesso! ---${NC}"
