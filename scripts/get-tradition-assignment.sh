#!/bin/bash
# Helper script to generate tradition assignment text for a scholar
# Reads from traditions.yml and formats for ASSIGNMENT.md

set -e

SCHOLAR_NAME="$1"

if [ -z "$SCHOLAR_NAME" ]; then
    echo "Usage: get-tradition-assignment.sh <scholar-name>"
    echo "Example: get-tradition-assignment.sh solon"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check for traditions in multiple locations:
# 1. tradition-examples.yml (standard library)
# 2. traditions.yml (legacy, for backward compat)
# 3. traditions-symposium-*.yml (symposium-specific)

TRADITIONS_FILE=""
if [ -f "$PROJECT_ROOT/tradition-examples.yml" ]; then
    TRADITIONS_FILE="$PROJECT_ROOT/tradition-examples.yml"
elif [ -f "$PROJECT_ROOT/traditions.yml" ]; then
    TRADITIONS_FILE="$PROJECT_ROOT/traditions.yml"
else
    # Check for symposium-specific files
    SYMPOSIUM_FILES=$(ls "$PROJECT_ROOT"/traditions-symposium-*.yml 2>/dev/null || echo "")
    if [ -n "$SYMPOSIUM_FILES" ]; then
        TRADITIONS_FILE=$(echo "$SYMPOSIUM_FILES" | head -1)
    fi
fi

if [ -z "$TRADITIONS_FILE" ] || [ ! -f "$TRADITIONS_FILE" ]; then
    echo "Error: No traditions file found. Checked:"
    echo "  - $PROJECT_ROOT/tradition-examples.yml"
    echo "  - $PROJECT_ROOT/traditions.yml"
    echo "  - $PROJECT_ROOT/traditions-symposium-*.yml"
    exit 1
fi

# Simple YAML parser using awk
# This extracts the tradition info for the specified scholar
extract_tradition() {
    local scholar=$1
    local field=$2

    awk -v scholar="$scholar" -v field="$field" '
    BEGIN { in_scholar=0; in_field=0 }

    # Found our scholar section
    /^  [a-z]+:$/ {
        current_scholar = substr($1, 1, length($1)-1)
        in_scholar = (current_scholar == scholar)
        in_field = 0
        next
    }

    # New scholar section started
    /^  [a-z]+:$/ && in_scholar { in_scholar = 0 }

    # Found our field
    in_scholar && $1 == field":" {
        in_field = 1
        # Print quoted value on same line
        if (NF > 1) {
            line = substr($0, index($0, $2))
            gsub(/^"|"$/, "", line)
            print line
            in_field = 0
        }
        next
    }

    # Continuation of field value
    in_scholar && in_field && /^      -/ {
        line = substr($0, 9)
        print line
        next
    }

    # End of field
    in_scholar && in_field && /^    [a-z_]+:/ {
        in_field = 0
    }
    ' "$TRADITIONS_FILE"
}

# Extract fields
TRADITION_NAME=$(extract_tradition "$SCHOLAR_NAME" "tradition")
DESCRIPTION=$(extract_tradition "$SCHOLAR_NAME" "description")
KEY_THINKERS=$(extract_tradition "$SCHOLAR_NAME" "key_thinkers")
CONCERNS=$(extract_tradition "$SCHOLAR_NAME" "characteristic_concerns")

# Format output
cat <<EOF
## Your Philosophical Tradition

**You are Scholar ${SCHOLAR_NAME}, representing the ${TRADITION_NAME} tradition.**

### Your Approach
${DESCRIPTION}

### Key Thinkers in Your Tradition
$(echo "$KEY_THINKERS" | sed 's/^/- /')

### Characteristic Questions You Ask
$(echo "$CONCERNS" | sed 's/^/- /')

### Your Task
Engage the symposium topic **through the lens of your tradition**. This means:

1. **Frame the question** using concepts and distinctions from your tradition
2. **Draw on thinkers** who exemplify this approach (you may cite others, but ground your argument here)
3. **Apply characteristic methods** - what would a ${TRADITION_NAME%% *} analysis look like for this question?
4. **Identify tensions** - where might your tradition's commitments create challenges or insights others miss?

**Important**: You are not merely *describing* this tradition - you are *thinking within* it. Bring genuine philosophical rigor, not summary. You may critically examine your tradition's limitations, but your analysis should be recognizably grounded in this tradition's core commitments and methods.

### Why This Matters
New Atlantis values **philosophical diversity**. We assign distinct traditions to ensure the symposium explores the topic from genuinely different perspectives. Your contribution is not just "an essay" but a contribution from the ${TRADITION_NAME} tradition that will be compared with other traditions' approaches.

**Convergence across traditions is significant**. If your analysis (grounded in ${TRADITION_NAME}) reaches similar conclusions to scholars working from different traditions, that convergence provides evidence of robustness. But **divergence is equally valuable** - it reveals where philosophical commitments lead to different practical recommendations.

### Intellectual Freedom Within Tradition
This is not a constraint on your thinking - it's an **invitation to expertise**. You have full freedom in:
- Which aspects of the tradition to emphasize
- How to apply traditional concepts to novel questions (AI governance!)
- Whether to criticize or defend traditional positions
- How to integrate insights from other traditions

What you don't have freedom to do is abandon your tradition's core commitments or write a generic analysis that could come from any perspective. Make it distinctively grounded in ${TRADITION_NAME}.
EOF
