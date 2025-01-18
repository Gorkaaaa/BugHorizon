#!/bin/bash
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'

function estado {
    echo -e "${BOLD}${CYAN}$1${NC}"
}

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}¡Este script debe ejecutarse como root!${NC}"
    exit 1
fi

estado "Iniciando proceso de instalación..."

estado "Actualizando el sistema..."
apt update && apt upgrade -y

estado "Instalando dependencias necesarias..."
apt install -y git python3-pip wget

estado "Instalando Katana..."
git clone https://github.com/und3rf10w/katana.git /opt/katana
cd /opt/katana
chmod +x katana.py

estado "Instalando Dirsearch..."
git clone https://github.com/maurosoria/dirsearch.git /opt/dirsearch
cd /opt/dirsearch
pip3 install -r requirements.txt

estado "Verificando la instalación..."
if command -v katana &>/dev/null && command -v dirsearch &>/dev/null; then
    echo -e "${GREEN}Las herramientas Katana y Dirsearch se instalaron correctamente.${NC}"
else
    echo -e "${RED}Hubo un error al instalar las herramientas.${NC}"
    exit 1
fi

estado "Creando archivo de dominios de ejemplo..."
echo "example.com" > valid_domains.txt
echo "test.com" >> valid_domains.txt

estado "Creando directorio para resultados..."
mkdir -p web_scan_results

estado "Instalación completa. Ahora puede ejecutar el script de escaneo."
