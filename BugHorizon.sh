#!/bin/bash

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'

if [ ! -f "valid_domains.txt" ]; then
    echo -e "${RED}El archivo 'valid_domains.txt' no se encuentra.${NC}"
    exit 1
fi

DIRECTORIO="web_scan_results"
mkdir -p "$DIRECTORIO"

function estado {
    echo -e "${BOLD}${CYAN}$1${NC}"
}

function ejecutar_katana {
    dominio=$1
    dominio_dir="$DIRECTORIO/$dominio"
    mkdir -p "$dominio_dir"

    estado "Ejecutando Katana en $dominio..."
    katana -u "$dominio" -o "$dominio_dir/$dominio.katana.txt"
    
    if [ -s "$dominio_dir/$dominio.katana.txt" ]; then
        echo -e "${GREEN}Katana encontró resultados para $dominio:${NC}"
        head -n 10 "$dominio_dir/$dominio.katana.txt" | while read line; do
            echo -e "${BOLD}$line${NC}"
        done
    else
        echo -e "${YELLOW}Katana no encontró resultados para $dominio.${NC}"
    fi
}

function ejecutar_dirsearch {
    dominio=$1
    dominio_dir="$DIRECTORIO/$dominio"

    estado "Ejecutando Dirsearch en $dominio..."
    dirsearch -u "$dominio" -e * --plain-text-report="$dominio_dir/$dominio.dirsearch.txt" > /dev/null 2>&1

    if [ -s "$dominio_dir/$dominio.dirsearch.txt" ]; then
        echo -e "${GREEN}Dirsearch encontró resultados para $dominio:${NC}"
        grep -E '(200|301|302)' "$dominio_dir/$dominio.dirsearch.txt" | head -n 10 | while read line; do
            echo -e "${BOLD}$line${NC}"
        done
    else
        echo -e "${YELLOW}Dirsearch no encontró resultados para $dominio.${NC}"
    fi
}

estado "Procesando dominios desde 'valid_domains.txt'..."

while read dominio; do
    if [ -z "$dominio" ]; then
        continue
    fi
    
    estado "Procesando dominio: $dominio"

    ejecutar_katana "$dominio"

    ejecutar_dirsearch "$dominio"

done < valid_domains.txt

estado "El escaneo ha finalizado. Los resultados se encuentran en el directorio '$DIRECTORIO'."
