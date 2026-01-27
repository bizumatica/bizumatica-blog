#!/bin/bash

# Author: Julio Prata
# Created: 01 dez 2025
# Last Modified: 27 jan 2026
# Version: 1.4
# Description: Script de deploy aperfeiçoado para Hugo com gestão de submódulos e limpeza de cache

# Cores para o terminal
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PROJECT_NAME=$(basename "$PWD")

echo -e "${CYAN}--- Iniciando Deploy para: $PROJECT_NAME ---${NC}"

# 1. Define mensagem de commit
msg="Update $(date +'%d/%m/%Y %H:%M:%S')"
if [ $# -eq 1 ]; then
  msg="$1"
fi

# 2. Sincronização de Submódulos (Garante que o tema não venha vazio)
if [ -d ".git" ]; then
    echo -e "${YELLOW}--> Verificando temas e submódulos...${NC}"
    git submodule update --init --recursive --quiet
fi

# 3. VERIFICAÇÃO E BUILD DO HUGO
if [ -f "hugo.toml" ] || [ -f "config.toml" ] || [ -f "hugo.yaml" ]; then
    echo -e "${GREEN}--> Site Hugo detectado.${NC}"
    
    # Limpeza total da pasta de destino para evitar o erro "not a directory"
    # e garantir que arquivos deletados não permaneçam no ar
    echo -e "${YELLOW}--> Limpando diretório de build (docs/)...${NC}"
    rm -rf docs/*
    
    echo -e "${GREEN}--> Iniciando build do Hugo (com limpeza de cache)...${NC}"
    # --gc: Executa a coleta de lixo (limpa arquivos não utilizados)
    # --minify: Otimiza HTML, CSS e JS para o site carregar mais rápido
    if hugo --gc --minify -d docs; then
        echo -e "${GREEN}--> Build concluído com sucesso!${NC}"
    else
        echo -e "${RED}--> ERRO: Falha crítica na geração do site. Verifique o console acima.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}--> Nenhum arquivo de configuração Hugo encontrado. Pulando etapa de build.${NC}"
fi

# 4. GESTÃO DO GIT
# Verifica se há alterações reais para subir
if [[ -z $(git status -s) ]]; then
    echo -e "${CYAN}--> Nada para commitar. O repositório já está atualizado.${NC}"
    exit 0
fi

echo -e "${GREEN}--> Adicionando arquivos ao Git...${NC}"
git add .

echo -e "${GREEN}--> Criando commit: \"$msg ($PROJECT_NAME)\"${NC}"
git commit -m "$msg ($PROJECT_NAME)"

echo -e "${GREEN}--> Enviando para o GitHub (branch main)...${NC}"
if git push origin main; then
    echo -e "${CYAN}--- Deploy de $PROJECT_NAME finalizado com sucesso! 🚀 ---${NC}"
else
    echo -e "${RED}--> ERRO: Falha ao enviar para o GitHub. Verifique sua conexão ou permissões.${NC}"
    exit 1
fi