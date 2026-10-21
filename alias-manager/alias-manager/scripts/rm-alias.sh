#!/bin/bash
# Script para eliminar un alias

BASHRC="$HOME/.bashrc"

if [[ $# -ne 1 ]]; then
    echo "Uso: rm-alias alias_name"
    exit 1
fi

alias_name="$1"
existing=$(grep -E "^alias $alias_name=" "$BASHRC")

if [[ -z "$existing" ]]; then
    echo "Alias '$alias_name' no existe."
    exit 1
fi

# Eliminar línea
sed -i.bak "/^alias $alias_name=/d" "$BASHRC"
echo "Alias '$alias_name' eliminado."