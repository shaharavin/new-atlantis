#!/bin/bash
# Cache a web source for New Atlantis bibliography
# Usage: cache-source.sh <url> <cite-key> [title]

set -e

URL="$1"
CITE_KEY="$2"
TITLE="${3:-Unknown Title}"

if [ -z "$URL" ] || [ -z "$CITE_KEY" ]; then
    cat <<EOF
Usage: cache-source.sh <url> <cite-key> [title]

Examples:
  # Cache a PDF
  cache-source.sh https://example.com/paper.pdf smith2024ai "AI and Understanding"

  # Cache an HTML page
  cache-source.sh https://plato.stanford.edu/entries/truth/ sep-truth "Truth (SEP)"

The script will:
1. Download the source to .cache/sources/
2. Print a BibTeX entry template
3. You manually add the entry to references.bib
EOF
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Execute in container
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
    set -e

    CACHE_DIR=\"/atlantis/philosophy/.cache/sources/\$(date +%Y)\"
    mkdir -p \"\$CACHE_DIR\"

    # Determine file extension
    if [[ '$URL' =~ \.pdf$ ]]; then
        EXT='pdf'
    elif [[ '$URL' =~ \.html$ ]]; then
        EXT='html'
    else
        EXT='html'  # Default to HTML
    fi

    FILENAME=\"${CITE_KEY}.\$EXT\"
    FILEPATH=\"\$CACHE_DIR/\$FILENAME\"

    # Download
    echo \"→ Downloading from $URL\"
    echo \"→ Saving to \$FILEPATH\"

    curl -L '$URL' -o \"\$FILEPATH\" 2>&1 | grep -v '^  % Total' || true

    # Get file size
    SIZE=\$(stat -c%s \"\$FILEPATH\" 2>/dev/null || stat -f%z \"\$FILEPATH\")
    echo \"✅ Cached \$SIZE bytes to \$FILEPATH\"

    # Print BibTeX template
    RELATIVE_PATH=\".cache/sources/\$(date +%Y)/\$FILENAME\"

    echo \"\"
    echo \"═══════════════════════════════════════════\"
    echo \"Add this entry to references.bib:\"
    echo \"═══════════════════════════════════════════\"
    echo \"\"

    # Determine BibTeX type based on URL
    if [[ '$URL' =~ plato.stanford.edu ]]; then
        cat <<BIBTEX
@incollection{$CITE_KEY,
  title = {$TITLE},
  booktitle = {The Stanford Encyclopedia of Philosophy},
  editor = {Edward N. Zalta},
  year = {\$(date +%Y)},
  publisher = {Metaphysics Research Lab, Stanford University},
  url = {$URL},
  cached = {\$RELATIVE_PATH},
  note = {Cached \$(date -I)}
}
BIBTEX
    elif [[ '$URL' =~ iep.utm.edu ]]; then
        cat <<BIBTEX
@incollection{$CITE_KEY,
  title = {$TITLE},
  booktitle = {Internet Encyclopedia of Philosophy},
  year = {\$(date +%Y)},
  url = {$URL},
  cached = {\$RELATIVE_PATH},
  note = {Cached \$(date -I)}
}
BIBTEX
    elif [[ '$URL' =~ \.pdf$ ]]; then
        cat <<BIBTEX
@article{$CITE_KEY,
  author = {[Author Name]},
  title = {$TITLE},
  journal = {[Journal Name]},
  year = {[Year]},
  url = {$URL},
  cached = {\$RELATIVE_PATH},
  note = {Cached \$(date -I)}
}
BIBTEX
    else
        cat <<BIBTEX
@misc{$CITE_KEY,
  author = {[Author Name]},
  title = {$TITLE},
  year = {\$(date +%Y)},
  url = {$URL},
  cached = {\$RELATIVE_PATH},
  note = {Cached \$(date -I)}
}
BIBTEX
    fi

    echo \"\"
    echo \"═══════════════════════════════════════════\"
    echo \"\"
    echo \"Next steps:\"
    echo \"1. Edit the BibTeX entry above (add author, year, etc.)\"
    echo \"2. Add it to /atlantis/philosophy/references.bib\"
    echo \"3. Commit: git add references.bib .cache/sources/\"
    echo \"4. Cite in your work: [@$CITE_KEY]\"
"

echo ""
echo "✅ Source cached successfully!"
