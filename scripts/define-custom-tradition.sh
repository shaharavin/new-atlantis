#!/bin/bash
# Helper script for Convener to define custom traditions for a symposium
# When tradition-examples.yml doesn't have what you need

set -e

echo "════════════════════════════════════════════════"
echo "🎓 Custom Tradition Definition Tool"
echo "════════════════════════════════════════════════"
echo ""
echo "Use this when none of the traditions in tradition-examples.yml"
echo "fit your symposium topic well."
echo ""
echo "This will generate a tradition definition you can:"
echo "1. Use immediately for the current symposium"
echo "2. Add to tradition-examples.yml for future use"
echo ""

# Collect inputs
read -p "Scholar name (e.g., 'hume', 'confucius'): " SCHOLAR_NAME
echo ""
read -p "Tradition name (e.g., 'Humean Skepticism & Naturalism'): " TRADITION_NAME
echo ""
read -p "Description (1-2 sentences on core commitments): " DESCRIPTION
echo ""

echo "Key thinkers (enter one per line, empty line when done):"
KEY_THINKERS=()
while true; do
    read -p "  - " THINKER
    if [ -z "$THINKER" ]; then
        break
    fi
    KEY_THINKERS+=("$THINKER")
done
echo ""

echo "Characteristic questions (enter one per line, empty line when done):"
CONCERNS=()
while true; do
    read -p "  - " CONCERN
    if [ -z "$CONCERN" ]; then
        break
    fi
    CONCERNS+=("$CONCERN")
done
echo ""

# Generate YAML entry
YAML_FILE="/tmp/tradition-$SCHOLAR_NAME.yml"

cat > "$YAML_FILE" <<EOF
${SCHOLAR_NAME}:
  tradition: "$TRADITION_NAME"
  description: "$DESCRIPTION"
  key_thinkers:
EOF

for THINKER in "${KEY_THINKERS[@]}"; do
    echo "    - $THINKER" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" <<EOF
  characteristic_concerns:
EOF

for CONCERN in "${CONCERNS[@]}"; do
    echo "    - \"$CONCERN\"" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" <<EOF
  suggested_scholars: ["$SCHOLAR_NAME"]
  example_topics:
    - "[Add example topics that fit this tradition]"
EOF

echo "════════════════════════════════════════════════"
echo "✅ Custom Tradition Defined"
echo "════════════════════════════════════════════════"
echo ""
cat "$YAML_FILE"
echo ""
echo "════════════════════════════════════════════════"
echo "📝 Next Steps:"
echo "════════════════════════════════════════════════"
echo ""
echo "1. Review the definition above"
echo "2. If satisfied, add to tradition-examples.yml:"
echo "   cat $YAML_FILE >> tradition-examples.yml"
echo ""
echo "3. The tradition is now available via get-tradition-assignment.sh:"
echo "   ./scripts/get-tradition-assignment.sh $SCHOLAR_NAME"
echo ""
echo "4. Or save for this symposium only:"
echo "   mv $YAML_FILE traditions-symposium-$(date +%Y%m).yml"
echo ""
