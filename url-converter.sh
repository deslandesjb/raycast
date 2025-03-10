#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clarins URL Converter
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔄
# @raycast.argument1  { "type": "dropdown", "placeholder": "Env", "optional": false, "data": [ { "title": "Staging", "value": "staging" }, { "title": "Production", "value": "prod" }, { "title": "Development", "value": "dev" } ] }

# Documentation:
# @raycast.author Aoyama
# @raycast.description Convertit les URLs Clarins entre les environnements prod, staging et dev

# Fonction pour convertir de prod vers staging
prod_to_staging() {
    local url=$(pbpaste)
    local country_code=""
    local path=""
    
    # Extraire le code pays (2 lettres) et le chemin
    if [[ $url =~ clarins\.([a-z]{2})\/(.*) ]]; then
        country_code=${BASH_REMATCH[1]}
        path=${BASH_REMATCH[2]}
    elif [[ $url =~ bnl\.clarins\.com\/fr\/(.*) ]]; then
        country_code="bnl"
        path=${BASH_REMATCH[1]}
    elif [[ $url =~ bnl\.clarins\.com\/nl\/(.*) ]]; then
        country_code="bnl"
        path="nl/${BASH_REMATCH[1]}"
    else
        echo "URL non reconnue"
        return 1
    fi
    
    local staging_base="https://staging-clarins-ecommera.demandware.net/s/clarins"
    local result="${staging_base}${country_code}/${path}"
    
    echo -n "$result" | pbcopy
}

# Fonction pour convertir de staging vers prod
staging_to_prod() {
    local url=$(pbpaste)
    local country_code=""
    local path=""
    
    if [[ $url =~ /s/clarins([a-z]{2,3})/(.*) ]]; then
        country_code=${BASH_REMATCH[1]}
        path=${BASH_REMATCH[2]}
        
        if [ "$country_code" = "bnl" ]; then
            if [[ $path =~ ^nl/(.*) ]]; then
                result="https://bnl.clarins.com/nl/${BASH_REMATCH[1]}"
            else
                result="https://bnl.clarins.com/fr/${path}"
            fi
        else
            result="https://www.clarins.${country_code}/${path}"
        fi
        
        echo -n "$result" | pbcopy
    else
        echo "Format d'URL de staging invalide"
        return 1
    fi
}

# Fonction pour convertir vers dev
convert_to_dev() {
    local url=$(pbpaste)
    
    # Si l'URL est en prod, d'abord la convertir en staging
    if [[ $url != *"staging-clarins-ecommera"* ]]; then
        prod_to_staging
        url=$(pbpaste)
    fi
    
    # Maintenant convertir de staging vers dev
    if [[ $url =~ /s/clarins([a-z]{2,3})/(.*) ]]; then
        country_code=${BASH_REMATCH[1]}
        path=${BASH_REMATCH[2]}
        
        local result="https://stg-eu.npr.clarins.com/clarins${country_code}/${path}"
        echo -n "$result" | pbcopy
    else
        echo "Format d'URL invalide"
        return 1
    fi
}

# Fonction principale
main() {
    local target_env=$1
    local url=$(pbpaste)
    
    echo "URL source: $url"
    
    case "$target_env" in
        "staging")
            if [[ $url == *"stg-eu.npr.clarins"* ]]; then
                # Conversion de dev vers staging
                if [[ $url =~ /clarins([a-z]{2,3})/(.*) ]]; then
                    country_code=${BASH_REMATCH[1]}
                    path=${BASH_REMATCH[2]}
                    result="https://staging-clarins-ecommera.demandware.net/s/clarins${country_code}/${path}"
                    echo -n "$result" | pbcopy
                fi
            else
                # Conversion de prod vers staging
                prod_to_staging
            fi
            ;;
        "prod")
            if [[ $url == *"staging-clarins-ecommera"* ]]; then
                staging_to_prod
            elif [[ $url == *"stg-eu.npr.clarins"* ]]; then
                # De dev vers staging puis vers prod
                if [[ $url =~ /clarins([a-z]{2,3})/(.*) ]]; then
                    country_code=${BASH_REMATCH[1]}
                    path=${BASH_REMATCH[2]}
                    result="https://staging-clarins-ecommera.demandware.net/s/clarins${country_code}/${path}"
                    echo -n "$result" | pbcopy
                    staging_to_prod
                fi
            fi
            ;;
        "dev")
            convert_to_dev
            ;;
        *)
            echo "Environnement non reconnu"
            return 1
            ;;
    esac
    
    echo "URL convertie: $(pbpaste)"
}

# Appel de la fonction principale avec l'argument
main "$1" 