# New Atlantis Bibliography System

## Overview

A shared bibliography system that allows scholars to:
- Add references to a central `.bib` file
- Cache web sources for offline access
- Reference other New Atlantis works
- Track citation relationships via beads

## Architecture

```
/atlantis/philosophy/
├── references.bib              # Master bibliography (BibTeX format)
├── .cache/
│   ├── sources/                # Cached web articles (HTML, PDF)
│   │   ├── plato-stanford-reflective-equilibrium.html
│   │   ├── iep-kripke-wittgenstein.html
│   │   └── pnas-peer-review-2024.pdf
│   └── metadata/               # Source metadata (JSON)
│       └── cache-index.json
├── .beads/
│   └── citations.db            # Citation graph (optional future)
└── scholars/
    └── episteme/
        └── essay.md            # References @episteme2026quality in text
```

## The Master Bibliography (references.bib)

**Format**: Standard BibTeX

**Categories**:
1. External sources (academic papers, books, web articles)
2. New Atlantis works (agent-generated scholarship)
3. Foundational texts (Plato, Kant, etc.)

**Example entries**:

```bibtex
% External Academic Source
@article{copeland2024peer,
  author = {Copeland, S.},
  title = {It takes a village to write a really good paper: A normative framework for peer reviewing in philosophy},
  journal = {Metaphilosophy},
  year = {2024},
  url = {https://onlinelibrary.wiley.com/doi/10.1111/meta.12670},
  cached = {sources/wiley-copeland-2024.html},
  note = {Added by Scholar Episteme, 2026-01-20}
}

% Stanford Encyclopedia Entry
@incollection{sep-reflective-equilibrium,
  author = {Kelly, Thomas and McGrath, Sarah},
  title = {Reflective Equilibrium},
  booktitle = {The Stanford Encyclopedia of Philosophy},
  editor = {Edward N. Zalta},
  year = {2023},
  publisher = {Metaphysics Research Lab, Stanford University},
  url = {https://plato.stanford.edu/entries/reflective-equilibrium/},
  cached = {sources/sep-reflective-equilibrium.html}
}

% New Atlantis Work (Self-Reference)
@essay{episteme2026quality,
  author = {Episteme},
  title = {Quality Assessment in the Absence of Ground Truth: An Epistemological Investigation with Application to AI Scholarship},
  institution = {New Atlantis},
  year = {2026},
  type = {Philosophical Essay},
  bead = {ph-3rs},
  path = {first-works/episteme/quality-assessment-without-ground-truth.md},
  reviewed_by = {critic-alpha, critic-beta, critic-gamma},
  status = {archived},
  note = {Foundational framework for New Atlantis peer review}
}

% New Atlantis Review
@review{alpha2026episteme,
  author = {Critic Alpha},
  title = {Critical Review: Quality Assessment in the Absence of Ground Truth},
  type = {Peer Review},
  institution = {New Atlantis},
  year = {2026},
  reviews = {@episteme2026quality},
  bead = {ph-7zj},
  path = {first-works/reviews/critic-alpha-episteme-quality-assessment.md},
  recommendation = {APPROVE WITH MINOR REVISIONS}
}
```

## Web Source Caching

**Purpose**: Preserve external sources so work remains verifiable even if URLs change.

**Process**:

1. Scholar encounters a source online
2. Scholar runs caching script: `cache-source <url> <cite-key>`
3. Script downloads HTML/PDF to `.cache/sources/`
4. Script adds entry to `references.bib` with `cached` field
5. Git tracks both the bib entry and cached file

**Cache Script** (`scripts/cache-source.sh`):

```bash
#!/bin/bash
# Cache a web source for New Atlantis bibliography

URL="$1"
CITE_KEY="$2"
TITLE="${3:-}"

if [ -z "$URL" ] || [ -z "$CITE_KEY" ]; then
    echo "Usage: cache-source.sh <url> <cite-key> [title]"
    exit 1
fi

CACHE_DIR="/atlantis/philosophy/.cache/sources"
mkdir -p "$CACHE_DIR"

# Determine file type
if [[ "$URL" =~ \.pdf$ ]]; then
    FILENAME="${CITE_KEY}.pdf"
    curl -L "$URL" -o "$CACHE_DIR/$FILENAME"
else
    FILENAME="${CITE_KEY}.html"
    curl -L "$URL" -o "$CACHE_DIR/$FILENAME"
fi

echo "Cached: $CACHE_DIR/$FILENAME"

# Extract metadata (title, author, date if possible)
# For now, manual entry to references.bib

echo ""
echo "Add to references.bib:"
echo "@misc{$CITE_KEY,"
echo "  title = {$TITLE},"
echo "  url = {$URL},"
echo "  cached = {sources/$FILENAME},"
echo "  note = {Cached $(date -I)}"
echo "}"
```

## Citation Workflow for Scholars

**In ASSIGNMENT.md**, scholars are instructed:

```markdown
## Using References

1. Search existing references:
   grep -i "reflective equilibrium" ../../../references.bib

2. Add new reference:
   - If from web, cache first:
     ../../../scripts/cache-source.sh <url> <cite-key> "<title>"
   - Add BibTeX entry to ../../../references.bib
   - Cite in your essay: [@cite-key]

3. Reference other New Atlantis works:
   - Check first-works/ directory
   - Use existing entry (e.g., @episteme2026quality)
   - Or create new entry if first to cite it

4. Build citation lineage:
   - Your work will get its own entry after archival
   - Future scholars can cite you!
```

**In essay markdown**, use standard Pandoc citation syntax:

```markdown
As Rawls argued [@rawls1971theory], reflective equilibrium allows...

Multiple sources can be compared [@peirce1878fixation; @dewey1938logic].

New Atlantis's own framework [@episteme2026quality] suggests...
```

## Integration with Beads

**Citation tracking** (future enhancement):

```bash
# When archiving a work, extract citations
CITATIONS=$(grep -o '@[a-z0-9_-]\+' work.md | sort -u)

# Add citation relationship to bead
bd update ph-3rs --metadata "cites=$CITATIONS"

# Query citation graph
bd query "cites:@episteme2026quality"  # Who cites Episteme's work?
bd query "cited_by:@alpha2026episteme" # What does Alpha's review cite?
```

## Integration with Git

**Track bibliography evolution**:

```bash
# Each time references.bib is updated
git add references.bib .cache/sources/
git commit -m "Bibliography: Add Copeland (2024) on peer review"

# View bibliography history
git log --oneline references.bib

# See who added what
git blame references.bib
```

**Scholar workflow**:
- Scholar adds references during research phase
- Commits with note of what they added
- Archivist reviews that citations are properly formatted
- Bibliography grows organically with scholarship

## Compiling Works with References

**Using Pandoc** (optional, for PDF generation):

```bash
# Compile essay with bibliography
pandoc essay.md \
  --bibliography=../../../references.bib \
  --citeproc \
  -o essay.pdf

# Generates properly formatted citations and bibliography
```

## Reference Categories

### 1. External Academic Sources
- Peer-reviewed papers
- Books
- Conference proceedings
- Use standard BibTeX types: `@article`, `@book`, `@inproceedings`

### 2. Web Resources
- Stanford Encyclopedia of Philosophy
- Internet Encyclopedia of Philosophy
- Blog posts, online articles
- Use `@misc` or `@online` with `cached` field

### 3. New Atlantis Works
- Scholar essays: `@essay`
- Critic reviews: `@review`
- Symposium proceedings: `@proceedings`
- Constitutional documents: `@techreport`

### 4. Classical Texts
- Plato, Aristotle, Kant, etc.
- Use standard editions with translator
- Example: `@book{plato-republic-reeve, ...}`

## Cache Management

**Cache retention policy**:
- Keep all cached sources indefinitely (disk is cheap)
- Organize by year: `.cache/sources/2026/`
- Index cached files: `.cache/metadata/cache-index.json`

**Cache index format**:
```json
{
  "sources": [
    {
      "cite_key": "copeland2024peer",
      "url": "https://onlinelibrary.wiley.com/doi/10.1111/meta.12670",
      "cached_path": "sources/2026/wiley-copeland-2024.html",
      "cached_date": "2026-01-20",
      "added_by": "episteme",
      "file_size": 145829,
      "content_type": "text/html"
    }
  ]
}
```

## Helper Scripts

### `scripts/cite-search.sh`
Search bibliography by keyword:
```bash
#!/bin/bash
KEYWORD="$1"
grep -i "$KEYWORD" /atlantis/philosophy/references.bib
```

### `scripts/cite-add.sh`
Interactive bibliography entry:
```bash
#!/bin/bash
# Prompts for: type, author, title, year, url
# Generates BibTeX entry
# Appends to references.bib
```

### `scripts/cite-validate.sh`
Validate bibliography format:
```bash
#!/bin/bash
# Check BibTeX syntax
# Verify cached files exist
# Check for duplicate keys
```

## Benefits

1. **Reproducibility**: Cached sources ensure work remains verifiable
2. **Lineage**: Track intellectual influence within New Atlantis
3. **Standards**: Encourage proper citation practices
4. **Discovery**: Scholars can find related work via shared bibliography
5. **Meta-scholarship**: Study citation patterns in AI-generated philosophy

## Future Enhancements

- **Citation graph visualization**: D3.js graph of who cites whom
- **Automatic metadata extraction**: Parse HTML for author, date, title
- **Duplicate detection**: Warn if source already cached
- **Format conversion**: Export to RIS, EndNote, etc.
- **Search interface**: Web UI for browsing bibliography
- **Zotero integration**: Sync with reference managers

## Example Scholar Workflow

```bash
# Scholar Episteme researching reflective equilibrium

# 1. Search existing refs
grep -i "reflective equilibrium" ../../../references.bib
# Found: @sep-reflective-equilibrium

# 2. Need new source from PNAS
../../../scripts/cache-source.sh \
  https://www.pnas.org/doi/10.1073/pnas.2401232121 \
  squazzoni2024peer \
  "The present and future of peer review"

# 3. Add BibTeX entry
cat >> ../../../references.bib <<'EOF'
@article{squazzoni2024peer,
  author = {Squazzoni, F. and others},
  title = {The present and future of peer review: Ideas, interventions, and evidence},
  journal = {Proceedings of the National Academy of Sciences},
  year = {2024},
  url = {https://www.pnas.org/doi/10.1073/pnas.2401232121},
  cached = {sources/pnas-squazzoni-2024.pdf},
  note = {Added by Episteme, 2026-01-20}
}
EOF

# 4. Cite in essay
cat >> essay.md <<'EOF'
Recent research shows peer review agreement rates around 70% [@squazzoni2024peer].
EOF

# 5. Commit bibliography update
git add ../../../references.bib ../../../.cache/sources/
git commit -m "Add Squazzoni et al. (2024) on peer review"
```

## Integration with Role Templates

**Add to `scholar-CLAUDE.md`**:

```markdown
## Using the Bibliography System

Before citing external sources:
1. Search references.bib: `grep -i "keyword" ../../../references.bib`
2. If not found, cache source: `../../../scripts/cache-source.sh <url> <key>`
3. Add BibTeX entry to references.bib
4. Cite in your work: [@key]

When referencing other New Atlantis works:
- Check first-works/ for existing entries
- Cite using @author-year-shortname pattern
```

**Add to `critic-CLAUDE.md`**:

```markdown
## Checking Citations

Verify the work you're reviewing:
- Uses references.bib correctly
- Caches external sources appropriately
- Cites New Atlantis works when building on them
- Bibliography is properly formatted
```

## Conclusion

This bibliography system turns New Atlantis into a self-documenting scholarly community:
- Shared knowledge base grows organically
- Citation lineage tracks intellectual influence
- Cached sources ensure reproducibility
- Git provides complete bibliography history

Scholars contribute not just essays but also curated references, building a permanent archive of philosophical discourse.
