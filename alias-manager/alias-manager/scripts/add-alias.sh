#!/bin/bash
# Script para agregar o actualizar alias

source "$(dirname "$0")/../utils/common.sh"

if [[ $# -ne 1 ]]; then
    echo "Uso: add-alias 'alias_name=value'"
    exit 1
fi

# Separar nombre y valor del alias
IFS='=' read -r alias_name alias_value <<< "$1"

if [[ -z "$alias_name" || -z "$alias_value" ]]; then
    echo "Formato inválido. Usa: alias_name=value"
    exit 1
fi

update_or_add_alias "$alias_name" "$alias_value"