#!/usr/bin/env bash

set -euo pipefail

show_help() {
    cat <<EOF
List Generator

Generate a Markdown list from a collection of Markdown files.

Usage:
    generate-list.sh <link_prefix> <file...>

Example:
    generate-list.sh writings/notes \
        content/notes/a.md \
        content/notes/b.md

Options:
    -h, --help  Show this help message
EOF
}

case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
esac

if [ "$#" -lt 2  ]; then
    echo "Usage: $0 <link_prefix> <file...>"
    exit 1
fi

LINK_PREFIX="$1"
shift

FILES=("$@")

entries=()

read_metadata() {
    local file="$1"

    entry_title=$(sed -n 's/^title:[[:space:]]*//p' "$file" | head -1 | tr -d '\r')
    entry_date=$(sed -n 's/^date:[[:space:]]*//p' "$file" | head -1 | tr -d '\r')
    entry_date=$(printf "%s" "$entry_date" | sed -E 's/-([0-9])$/-0\1/')
    entry_slug=$(basename "$file" .md)

    entry_summary=""
    entry_tags=""
}

collect_entries() {
    local file
    
    for file in "${FILES[@]}"; do
	[ -f "$file" ] || continue

	read_metadata "$file"

	entries+=("$entry_date"$'\t'"$entry_title"$'\t'"$entry_slug")
    done
}

sort_entries() {
    printf "%s\n" "${entries[@]}" | sort -r
}

format_date() {
    local date="$1"
    date -d "$date" "+%d %B %Y"
}

render_entry() {
    local date="$1"
    local title="$2"
    local slug="$3"

    local pretty_date
    
    pretty_date=$(format_date "$date")
    
    printf -- "- [%s](/%s/%s.html) []{.liner} [%s]{.date}\n" \
	   "$title" \
	   "$LINK_PREFIX" \
	   "$slug" \
	   "$pretty_date"
    
}

render_entries() {
    sort_entries |
	while IFS=$'\t' read -r \
		 date \
		 title \
		 slug
	    do
		render_entry \
		    "$date" \
		    "$title" \
		    "$slug"
	done
}

main() {
    collect_entries
    render_entries
}


main "$@"
