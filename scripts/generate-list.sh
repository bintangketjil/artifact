#!/bin/sh

set -euo pipefail

show_help() {
    cat <<EOF

List Generator: generate a list from given directory


Usage:
    $(basename "$0") <input_dir> <link_prefix>

Examples:
    $(basename "$0") content/notes writings/notes
    $(basename "$0") content/images images/

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


INPUT_DIR="$1"
LINK_PREFIX="$2"

TYPE=$(basename "$INPUT_DIR")

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
    for file in "$INPUT_DIR"/*.md; do
	[ -e "$file" ] || continue

	read_metadata "$file"

	entries+=(
	    "$entry_date"$'\t'"$entry_title"$'\t'"$entry_slug"$'\t'"$TYPE"
	)
    done
}

sort_entries() {
    printf "%s\n" "${entries[@]}" | sort -r
}

format_date() {
    date -d "$date" "+%d %B %Y"
}

render_entry() {
    local date="$1"
    local title="$2"
    local slug="$3"
    local type="$4"
    
    local pretty
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
		 slug \
		 type
	    do
		render_entry \
		    "$date" \
		    "$title" \
		    "$slug" \
		    "$type"
	done
}

main() {
    collect_entries
    render_entries
}

if [ -z "$INPUT_DIR" ] || [ -z "$LINK_PREFIX" ]; then
    echo "Usage: $0 <input_dir> <link_prefix>"
    exit 1
fi

main "$@"








