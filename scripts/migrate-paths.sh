#!/usr/bin/env bash
# migrate-paths.sh
# Migrates SKILL.md path references from bare construction/ and memory-bank/
# to llm/construction/ and llm/memory-bank/ respectively.
#
# Rules:
#   1. construction/  -> llm/construction/   (path refs only, not frontmatter name/description)
#   2. memory-bank/   -> llm/memory-bank/    (NOT operations-memory-bank/)
#   3. operations-memory-bank/ -> llm/operations-memory-bank/
#   4. No double-prefixing: llm/construction/ and llm/memory-bank/ are left alone

set -euo pipefail

PLUGINS_DIR="$(cd "$(dirname "$0")/../plugins" && pwd)"

echo "=== Migrating skill path references to llm/ layout ==="
echo "Plugins dir: $PLUGINS_DIR"
echo ""

# Collect all SKILL.md files
mapfile -t SKILL_FILES < <(find "$PLUGINS_DIR" -name "SKILL.md" | sort)
echo "Found ${#SKILL_FILES[@]} SKILL.md files"
echo ""

for file in "${SKILL_FILES[@]}"; do
    # macOS sed requires '' after -i for in-place without backup
    # We process each substitution in order, taking care to avoid double-prefixing.
    #
    # Strategy:
    # Step 1: Protect operations-memory-bank/ by replacing it with a placeholder
    # Step 2: Replace bare memory-bank/ with llm/memory-bank/   (won't match placeholder)
    # Step 3: Restore placeholder to llm/operations-memory-bank/
    # Step 4: Replace bare construction/ (path refs only) with llm/construction/
    #         Path refs appear after: backtick, space, slash, quote ("), dash (-), or start-of-line

    sed -i '' \
        -e 's|operations-memory-bank/|__OPS_MEMORY_BANK_PLACEHOLDER__|g' \
        -e 's|llm/memory-bank/|__LLM_MEMORY_BANK_PLACEHOLDER__|g' \
        -e 's|memory-bank/|llm/memory-bank/|g' \
        -e 's|__LLM_MEMORY_BANK_PLACEHOLDER__|llm/memory-bank/|g' \
        -e 's|__OPS_MEMORY_BANK_PLACEHOLDER__|llm/operations-memory-bank/|g' \
        "$file"

    # Handle construction/ path references.
    # Match construction/ only when preceded by: backtick, space, slash, double-quote, or start-of-line.
    # Do NOT match if already prefixed with llm/ (handled by checking for llm/construction/ first).
    sed -i '' \
        -e 's|llm/construction/|__LLM_CONSTRUCTION_PLACEHOLDER__|g' \
        -e 's|\([` "/]\)construction/|\1llm/construction/|g' \
        -e 's|^construction/|llm/construction/|g' \
        -e 's|__LLM_CONSTRUCTION_PLACEHOLDER__|llm/construction/|g' \
        "$file"
done

echo "Migration complete."
echo ""

# =============================================================================
# Verification: show any remaining bare references
# =============================================================================
echo "=== Verification: checking for remaining bare path references ==="
echo ""

echo "--- Bare memory-bank/ references (excluding frontmatter name/description) ---"
# Exclude lines that are frontmatter 'name:' or 'description:' fields
BARE_MB=$(grep -rn "memory-bank/" "$PLUGINS_DIR" --include="SKILL.md" \
    | grep -v "llm/memory-bank/" \
    | grep -v "operations-memory-bank/" \
    | grep -v "llm/operations-memory-bank/" \
    | grep -v "^[^:]*:[ ]*name:" \
    | grep -v "^[^:]*:[ ]*description:" \
    || true)
if [ -z "$BARE_MB" ]; then
    echo "  (none found - migration successful)"
else
    echo "$BARE_MB"
fi
echo ""

echo "--- Bare construction/ references (excluding frontmatter name/description) ---"
BARE_CONST=$(grep -rn "construction/" "$PLUGINS_DIR" --include="SKILL.md" \
    | grep -v "llm/construction/" \
    | grep -v "^[^:]*:[ ]*name:" \
    | grep -v "^[^:]*:[ ]*description:" \
    || true)
if [ -z "$BARE_CONST" ]; then
    echo "  (none found - migration successful)"
else
    echo "$BARE_CONST"
fi
echo ""

echo "=== Done ==="
