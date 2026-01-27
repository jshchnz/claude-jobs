#!/bin/bash

# Test all claude-jobs endpoints
# Usage: ./test-endpoints.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

FAILED=0
PASSED=0

test_endpoint() {
    local company=$1
    local url=$2

    printf "Testing %-12s ... " "$company"

    response=$(curl -s -w "\n%{http_code}" --max-time 30 "$url" 2>/dev/null) || {
        echo -e "${RED}FAILED${NC} (connection error)"
        FAILED=$((FAILED + 1))
        return 0
    }

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" != "200" ]; then
        echo -e "${RED}FAILED${NC} (HTTP $http_code)"
        FAILED=$((FAILED + 1))
        return 0
    fi

    # Validate response looks like job data by checking for common job-related fields
    # This handles various API structures (arrays, nested objects, different field names)
    if echo "$body" | grep -qiE '"(title|name|position|role)".*:.*"[^"]+"|"(location|office|city)".*:.*"[^"]+"'; then
        # Try to estimate job count by counting title/position occurrences
        job_count=$(echo "$body" | grep -oiE '"(title|name)"[[:space:]]*:[[:space:]]*"[^"]+"' | wc -l | tr -d ' ')
        if [ "$job_count" -eq 0 ]; then
            job_count="?"
        fi
        echo -e "${GREEN}OK${NC} (~$job_count jobs)"
        PASSED=$((PASSED + 1))
    elif echo "$body" | grep -qE '^\[.*\]$|"jobs"'; then
        # Looks like JSON array or has jobs key but couldn't find typical fields
        echo -e "${YELLOW}OK${NC} (structure unclear)"
        PASSED=$((PASSED + 1))
    elif echo "$body" | grep -qiE '<title>.*jobs|careers.*</title>|class=".*job|posting|position.*"'; then
        # HTML job board page
        echo -e "${GREEN}OK${NC} (HTML job board)"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}FAILED${NC} (invalid response)"
        FAILED=$((FAILED + 1))
    fi

    return 0
}

echo "Testing claude-jobs endpoints..."
echo ""

# All companies (alphabetical)
test_endpoint "airbnb" "https://boards-api.greenhouse.io/v1/boards/airbnb/jobs"
test_endpoint "anthropic" "https://boards-api.greenhouse.io/v1/boards/anthropic/jobs"
test_endpoint "cloudflare" "https://boards-api.greenhouse.io/v1/boards/cloudflare/jobs"
test_endpoint "coinbase" "https://boards-api.greenhouse.io/v1/boards/coinbase/jobs"
test_endpoint "datadog" "https://boards-api.greenhouse.io/v1/boards/datadog/jobs"
test_endpoint "discord" "https://boards-api.greenhouse.io/v1/boards/discord/jobs"
test_endpoint "dropbox" "https://boards-api.greenhouse.io/v1/boards/dropbox/jobs"
test_endpoint "figma" "https://boards-api.greenhouse.io/v1/boards/figma/jobs"
test_endpoint "gitlab" "https://boards-api.greenhouse.io/v1/boards/gitlab/jobs"
test_endpoint "instacart" "https://boards-api.greenhouse.io/v1/boards/instacart/jobs"
test_endpoint "linear" "https://api.ashbyhq.com/posting-api/job-board/linear"
test_endpoint "lyft" "https://boards-api.greenhouse.io/v1/boards/lyft/jobs"
test_endpoint "netlify" "https://boards-api.greenhouse.io/v1/boards/netlify/jobs"
test_endpoint "notion" "https://api.ashbyhq.com/posting-api/job-board/notion"
test_endpoint "revenuecat" "https://jobs.ashbyhq.com/revenuecat"
test_endpoint "sentry" "https://sentry.io/jobs/list.json"
test_endpoint "stripe" "https://boards-api.greenhouse.io/v1/boards/stripe/jobs"
test_endpoint "vercel" "https://boards-api.greenhouse.io/v1/boards/vercel/jobs"

echo ""
echo "Results: $PASSED passed, $FAILED failed"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
