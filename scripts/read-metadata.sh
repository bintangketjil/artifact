#!/usr/bin/env bash

FILE="$1"

printf "path\t%s\n" "$FILE"

in_yaml=false

while IFS= read -r line; do
    case "$line" in
	"---")
	    if ! $in_yaml; then
		in_yaml=true
	    else
		break
	    fi
	    continue
	    ;;
    esac

    $in_yaml || continue

    [[ "$line" =~ ^[[:space]]*$ ]] && continue
    [[ "$line" =~ ^# ]] && continue

    key=${line%%:*}
    value=${line#*:}

    # trim leading whitespace
    value="${value#"${value%%[![:space:]]*}"}"

    printf "%s\t%s\n" "$key" "$value"

done < "$FILE"
