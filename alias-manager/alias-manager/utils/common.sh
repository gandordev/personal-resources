#!/bin/bash
# Funciones comunes para manejo de alias en Linux

BASHRC="$HOME/.bashrc"

# Función para verificar si un alias existe
alias_exists() {
    local name="$1"
    grep -E "^alias $name=" "$BASHRC"
}

# Función para agregar o actualizar un alias
update_or_add_alias() {
    local name="$1"
    local value="$2"

    local existing
    existing=$(alias_exists "$name")

    if [[ -n "$existing" ]]; then
        echo -e "Este alias ya existe: $existing"
        read -p "¿Deseas actualizarlo? [Y/n] " resp
        resp=${resp:-y}
        if [[ "$resp" =~ ^[Yy]$ ]]; then
            # Reemplazar la línea existente
            sed -i.bak "/^alias $name=/c\alias $name='$value'" "$BASHRC"
            echo "Alias actualizado: $name='$value'"
        else
            echo "Alias no modificado."
        fi
    else
        # Agregar al final
        echo "alias $name='$value'" >> "$BASHRC"
        echo "Alias agregado: $name='$value'"
    fi
}