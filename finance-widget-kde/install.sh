#!/bin/bash
# Script de instalação do Finance Tracker Widget para KDE

set -e

echo "==================================="
echo "Finance Tracker Widget - Instalação"
echo "==================================="

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Verifica se está no diretório correto
if [ ! -f "metadata.json" ]; then
    echo -e "${RED}[ERRO]${NC} Execute este script do diretório do widget (onde está metadata.json)"
    exit 1
fi

echo -e "\n${GREEN}[1/5]${NC} Verificando dependências do sistema..."

# Verifica comandos necessários
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}[ERRO]${NC} Python3 não encontrado. Instale com: sudo apt install python3"
    exit 1
fi

if ! command -v kpackagetool6 &> /dev/null; then
    echo -e "${RED}[ERRO]${NC} kpackagetool6 não encontrado. Instale com: sudo apt install plasma-framework-dev"
    exit 1
fi

echo -e "${GREEN}[2/5]${NC} Verificando dependências Python..."

# Verifica yfinance
if ! python3 -c "import yfinance" 2>/dev/null; then
    echo "Instalando yfinance..."
    # Tenta instalar via apt primeiro
    if command -v apt &> /dev/null; then
        echo "Tentando instalar via apt..."
        sudo apt install -y python3-yfinance 2>/dev/null || {
            echo "Pacote não disponível via apt, usando pip com --break-system-packages..."
            pip3 install --user --break-system-packages yfinance
        }
    else
        pip3 install --user --break-system-packages yfinance
    fi
fi

echo -e "${GREEN}[3/5]${NC} Tornando script Python executável..."
chmod +x contents/code/finance.py

echo -e "${GREEN}[4/5]${NC} Instalando/Atualizando widget..."

# Verifica se já está instalado
if kpackagetool6 --type Plasma/Applet --show org.kde.plasma.financetracker &> /dev/null; then
    echo "Widget já instalado. Atualizando..."
    kpackagetool6 --type Plasma/Applet --upgrade .
else
    echo "Instalando widget..."
    kpackagetool6 --type Plasma/Applet --install .
fi

echo -e "${GREEN}[5/5]${NC} Reiniciando Plasma Shell..."
kquitapp6 plasmashell && kstart plasmashell &

echo -e "\n${GREEN}[SUCESSO]${NC} Widget instalado com sucesso!"
echo ""
echo "Para adicionar ao painel:"
echo "  1. Clique direito no painel"
echo "  2. Escolha 'Adicionar widgets'"
echo "  3. Procure por 'Finance Tracker'"
echo "  4. Arraste para o painel ou área de trabalho"
echo ""
echo "Para configurar:"
echo "  Clique direito no widget > Configurar"
echo ""
