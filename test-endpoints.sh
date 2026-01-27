#!/bin/bash

# Test all claude-jobs endpoints (parsed dynamically from SKILL.md)
# Usage: ./test-endpoints.sh [--parallel N] [--remove-dead] [--update-readme]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_FILE="$SCRIPT_DIR/SKILL.md"

PARALLEL=0
REMOVE_DEAD=false
UPDATE_README=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --parallel)
            PARALLEL="${2:-4}"
            shift 2
            ;;
        --remove-dead)
            REMOVE_DEAD=true
            shift
            ;;
        --update-readme)
            UPDATE_README=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--parallel N] [--remove-dead] [--update-readme]"
            exit 1
            ;;
    esac
done

if [[ ! -f "$SKILL_FILE" ]]; then
    echo "ERROR: SKILL.md not found at $SKILL_FILE"
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

RESULTS_DIR=$(mktemp -d)
trap 'rm -rf "$RESULTS_DIR"' EXIT
touch "$RESULTS_DIR/passed" "$RESULTS_DIR/failed" "$RESULTS_DIR/job_counts"

test_endpoint() {
    local company=$1
    local url=$2

    printf "Testing %-20s ... " "$company"

    response=$(curl -s -w "\n%{http_code}" --max-time 30 "$url" 2>/dev/null) || {
        echo -e "${RED}FAILED${NC} (connection error)"
        echo "$company" >> "$RESULTS_DIR/failed"
        return 0
    }

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" != "200" ]; then
        echo -e "${RED}FAILED${NC} (HTTP $http_code)"
        echo "$company" >> "$RESULTS_DIR/failed"
        return 0
    fi

    if echo "$body" | grep -qiE '"(title|text|name|position|role)".*:.*"[^"]+"|"(location|office|city)".*:.*"[^"]+"'; then
        job_count=$(echo "$body" | grep -oiE '"(title|text|name)"[[:space:]]*:[[:space:]]*"[^"]+"' | wc -l | tr -d ' ')
        if [ "$job_count" -eq 0 ]; then
            job_count="?"
        fi
        echo -e "${GREEN}OK${NC} (~$job_count jobs)"
        echo "$company" >> "$RESULTS_DIR/passed"
        echo "$company	$job_count" >> "$RESULTS_DIR/job_counts"
    elif echo "$body" | grep -qE '^\[.*\]$|"jobs"'; then
        echo -e "${YELLOW}OK${NC} (structure unclear)"
        echo "$company" >> "$RESULTS_DIR/passed"
        echo "$company	?" >> "$RESULTS_DIR/job_counts"
    elif echo "$body" | grep -qiE '<title>.*jobs|careers.*</title>|class=".*job|posting|position.*"'; then
        echo -e "${GREEN}OK${NC} (HTML job board)"
        echo "$company" >> "$RESULTS_DIR/passed"
        echo "$company	?" >> "$RESULTS_DIR/job_counts"
    else
        echo -e "${RED}FAILED${NC} (invalid response)"
        echo "$company" >> "$RESULTS_DIR/failed"
    fi

    return 0
}

# Parse companies from SKILL.md table (skip header and separator rows)
parse_companies() {
    grep -E '^\|[^-]' "$SKILL_FILE" | grep -viE '^\| *company' | while IFS='|' read -r _ company url _; do
        company=$(echo "$company" | xargs)
        url=$(echo "$url" | xargs)
        [[ -n "$company" && -n "$url" ]] && printf '%s\t%s\n' "$company" "$url"
    done
}

export -f test_endpoint
export RESULTS_DIR RED GREEN YELLOW NC

echo "Testing claude-jobs endpoints (from SKILL.md)..."
echo ""

COMPANIES=$(parse_companies)
TOTAL=$(echo "$COMPANIES" | wc -l | tr -d ' ')

if [[ "$PARALLEL" -gt 0 ]]; then
    echo "$COMPANIES" | tr '\t' '|' | xargs -P "$PARALLEL" -I {} bash -c '
        company="${1%%|*}"
        url="${1##*|}"
        test_endpoint "$company" "$url"
    ' _ "{}"
else
    while IFS=$'\t' read -r company url; do
        test_endpoint "$company" "$url"
    done <<< "$COMPANIES"
fi

echo ""

PASSED=$(wc -l < "$RESULTS_DIR/passed" | tr -d ' ')
FAILED=$(wc -l < "$RESULTS_DIR/failed" | tr -d ' ')

echo "Results: $PASSED passed, $FAILED failed (out of $TOTAL)"

if [[ "$FAILED" -gt 0 ]]; then
    echo ""
    echo "Dead endpoints:"
    while read -r company; do
        echo "  - $company"
    done < "$RESULTS_DIR/failed"

    if [[ "$REMOVE_DEAD" == true ]]; then
        echo ""
        echo "Removing dead endpoints from SKILL.md..."
        while read -r company; do
            sed -i '' "/^| *${company} *|/d" "$SKILL_FILE"
            echo "  Removed: $company"
        done < "$RESULTS_DIR/failed"
    fi
fi

# Update README with company count and test date
if [[ "$UPDATE_README" == true ]]; then
    README_FILE="$SCRIPT_DIR/README.md"
    if [[ ! -f "$README_FILE" ]]; then
        echo "WARNING: README.md not found, skipping update"
    else
        echo ""
        echo "Updating README.md with test results..."

        DATE=$(date +%Y-%m-%d)

        # Build company list from job_counts (alphabetical, names only)
        COMPANY_LIST=""
        while IFS=$'\t' read -r company _; do
            display_name="$(echo "$company" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"
            COMPANY_LIST+="$display_name, "
        done < <(sort -t$'\t' -k1,1 "$RESULTS_DIR/job_counts")

        # Remove trailing ", "
        COMPANY_LIST="${COMPANY_LIST%, }"

        DATE=$(date +%Y-%m-%d)

        # Write new section to temp file, then use python to do the replacement
        NEW_SECTION_FILE="$RESULTS_DIR/new_section.txt"
        cat > "$NEW_SECTION_FILE" <<SECTION_EOF
## Supported Companies

> **${PASSED} companies** tracked (last tested: ${DATE})

${COMPANY_LIST}

**Want to add your company?** [See how](CONTRIBUTING.md)
SECTION_EOF

        python3 -c "
import re
with open('$NEW_SECTION_FILE') as f:
    new_section = f.read().rstrip()
with open('$README_FILE') as f:
    readme = f.read()
pattern = r'## Supported Companies.*?(?=\n## |\Z)'
updated = re.sub(pattern, new_section, readme, flags=re.DOTALL)
with open('$README_FILE', 'w') as f:
    f.write(updated)
"
        echo "  README.md updated"
    fi
fi

if [[ "$FAILED" -gt 0 ]]; then
    exit 1
fi
