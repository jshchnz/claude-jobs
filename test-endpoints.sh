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

    printf "Testing %-15s ... " "$company"

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
test_endpoint "affirm" "https://boards-api.greenhouse.io/v1/boards/affirm/jobs?content=true"
test_endpoint "airbnb" "https://boards-api.greenhouse.io/v1/boards/airbnb/jobs?content=true"
test_endpoint "airtable" "https://boards-api.greenhouse.io/v1/boards/airtable/jobs?content=true"
test_endpoint "algolia" "https://boards-api.greenhouse.io/v1/boards/algolia/jobs?content=true"
test_endpoint "amplitude" "https://boards-api.greenhouse.io/v1/boards/amplitude/jobs?content=true"
test_endpoint "anthropic" "https://boards-api.greenhouse.io/v1/boards/anthropic/jobs?content=true"
test_endpoint "anyscale" "https://jobs.ashbyhq.com/anyscale"
test_endpoint "applovin" "https://boards-api.greenhouse.io/v1/boards/applovin/jobs?content=true"
test_endpoint "asana" "https://boards-api.greenhouse.io/v1/boards/asana/jobs?content=true"
test_endpoint "axiom" "https://boards-api.greenhouse.io/v1/boards/axiom/jobs?content=true"
test_endpoint "benchling" "https://boards-api.greenhouse.io/v1/boards/benchling/jobs?content=true"
test_endpoint "block" "https://boards-api.greenhouse.io/v1/boards/block/jobs?content=true"
test_endpoint "brex" "https://boards-api.greenhouse.io/v1/boards/brex/jobs?content=true"
test_endpoint "calendly" "https://boards-api.greenhouse.io/v1/boards/calendly/jobs?content=true"
test_endpoint "carta" "https://boards-api.greenhouse.io/v1/boards/carta/jobs?content=true"
test_endpoint "chime" "https://boards-api.greenhouse.io/v1/boards/chime/jobs?content=true"
test_endpoint "circleci" "https://boards-api.greenhouse.io/v1/boards/circleci/jobs?content=true"
test_endpoint "cloudflare" "https://boards-api.greenhouse.io/v1/boards/cloudflare/jobs?content=true"
test_endpoint "cockroachlabs" "https://boards-api.greenhouse.io/v1/boards/cockroachlabs/jobs?content=true"
test_endpoint "cohere" "https://jobs.ashbyhq.com/cohere"
test_endpoint "coinbase" "https://boards-api.greenhouse.io/v1/boards/coinbase/jobs?content=true"
test_endpoint "contentful" "https://boards-api.greenhouse.io/v1/boards/contentful/jobs?content=true"
test_endpoint "coursera" "https://boards-api.greenhouse.io/v1/boards/coursera/jobs?content=true"
test_endpoint "databricks" "https://boards-api.greenhouse.io/v1/boards/databricks/jobs?content=true"
test_endpoint "datadog" "https://boards-api.greenhouse.io/v1/boards/datadog/jobs?content=true"
test_endpoint "deel" "https://jobs.ashbyhq.com/deel"
test_endpoint "descript" "https://boards-api.greenhouse.io/v1/boards/descript/jobs?content=true"
test_endpoint "discord" "https://boards-api.greenhouse.io/v1/boards/discord/jobs?content=true"
test_endpoint "dollarshaveclub" "https://boards-api.greenhouse.io/v1/boards/dollarshaveclub/jobs?content=true"
test_endpoint "dropbox" "https://boards-api.greenhouse.io/v1/boards/dropbox/jobs?content=true"
test_endpoint "duolingo" "https://boards-api.greenhouse.io/v1/boards/duolingo/jobs?content=true"
test_endpoint "elastic" "https://boards-api.greenhouse.io/v1/boards/elastic/jobs?content=true"
test_endpoint "faire" "https://boards-api.greenhouse.io/v1/boards/faire/jobs?content=true"
test_endpoint "fastly" "https://boards-api.greenhouse.io/v1/boards/fastly/jobs?content=true"
test_endpoint "fetch" "https://boards-api.greenhouse.io/v1/boards/fetch/jobs?content=true"
test_endpoint "figma" "https://boards-api.greenhouse.io/v1/boards/figma/jobs?content=true"
test_endpoint "fivetran" "https://boards-api.greenhouse.io/v1/boards/fivetran/jobs?content=true"
test_endpoint "flexport" "https://boards-api.greenhouse.io/v1/boards/flexport/jobs?content=true"
test_endpoint "gitlab" "https://boards-api.greenhouse.io/v1/boards/gitlab/jobs?content=true"
test_endpoint "grammarly" "https://boards-api.greenhouse.io/v1/boards/grammarly/jobs?content=true"
test_endpoint "gusto" "https://boards-api.greenhouse.io/v1/boards/gusto/jobs?content=true"
test_endpoint "hightouch" "https://boards-api.greenhouse.io/v1/boards/hightouch/jobs?content=true"
test_endpoint "instacart" "https://boards-api.greenhouse.io/v1/boards/instacart/jobs?content=true"
test_endpoint "intercom" "https://boards-api.greenhouse.io/v1/boards/intercom/jobs?content=true"
test_endpoint "labelbox" "https://boards-api.greenhouse.io/v1/boards/labelbox/jobs?content=true"
test_endpoint "lattice" "https://boards-api.greenhouse.io/v1/boards/lattice/jobs?content=true"
test_endpoint "launchdarkly" "https://boards-api.greenhouse.io/v1/boards/launchdarkly/jobs?content=true"
test_endpoint "linear" "https://jobs.ashbyhq.com/linear"
test_endpoint "liveperson" "https://boards-api.greenhouse.io/v1/boards/liveperson/jobs?content=true"
test_endpoint "lucidmotors" "https://boards-api.greenhouse.io/v1/boards/lucidmotors/jobs?content=true"
test_endpoint "lyft" "https://boards-api.greenhouse.io/v1/boards/lyft/jobs?content=true"
test_endpoint "marqeta" "https://boards-api.greenhouse.io/v1/boards/marqeta/jobs?content=true"
test_endpoint "mercury" "https://boards-api.greenhouse.io/v1/boards/mercury/jobs?content=true"
test_endpoint "mixpanel" "https://boards-api.greenhouse.io/v1/boards/mixpanel/jobs?content=true"
test_endpoint "mongodb" "https://boards-api.greenhouse.io/v1/boards/mongodb/jobs?content=true"
test_endpoint "moveworks" "https://boards-api.greenhouse.io/v1/boards/moveworks/jobs?content=true"
test_endpoint "netlify" "https://boards-api.greenhouse.io/v1/boards/netlify/jobs?content=true"
test_endpoint "nextdoor" "https://boards-api.greenhouse.io/v1/boards/nextdoor/jobs?content=true"
test_endpoint "notion" "https://jobs.ashbyhq.com/notion"
test_endpoint "nuro" "https://boards-api.greenhouse.io/v1/boards/nuro/jobs?content=true"
test_endpoint "okta" "https://boards-api.greenhouse.io/v1/boards/okta/jobs?content=true"
test_endpoint "openai" "https://jobs.ashbyhq.com/openai"
test_endpoint "pagerduty" "https://boards-api.greenhouse.io/v1/boards/pagerduty/jobs?content=true"
test_endpoint "palantir" "https://api.lever.co/v0/postings/palantir"
test_endpoint "peloton" "https://boards-api.greenhouse.io/v1/boards/peloton/jobs?content=true"
test_endpoint "pendo" "https://boards-api.greenhouse.io/v1/boards/pendo/jobs?content=true"
test_endpoint "perplexity" "https://jobs.ashbyhq.com/perplexity"
test_endpoint "pinterest" "https://boards-api.greenhouse.io/v1/boards/pinterest/jobs?content=true"
test_endpoint "plaid" "https://api.lever.co/v0/postings/plaid"
test_endpoint "postman" "https://boards-api.greenhouse.io/v1/boards/postman/jobs?content=true"
test_endpoint "ramp" "https://jobs.ashbyhq.com/ramp"
test_endpoint "reddit" "https://boards-api.greenhouse.io/v1/boards/reddit/jobs?content=true"
test_endpoint "retool" "https://boards-api.greenhouse.io/v1/boards/retool/jobs?content=true"
test_endpoint "revenuecat" "https://jobs.ashbyhq.com/revenuecat"
test_endpoint "robinhood" "https://boards-api.greenhouse.io/v1/boards/robinhood/jobs?content=true"
test_endpoint "salesloft" "https://boards-api.greenhouse.io/v1/boards/salesloft/jobs?content=true"
test_endpoint "samsara" "https://boards-api.greenhouse.io/v1/boards/samsara/jobs?content=true"
test_endpoint "scaleai" "https://boards-api.greenhouse.io/v1/boards/scaleai/jobs?content=true"
test_endpoint "seatgeek" "https://boards-api.greenhouse.io/v1/boards/seatgeek/jobs?content=true"
test_endpoint "sendbird" "https://boards-api.greenhouse.io/v1/boards/sendbird/jobs?content=true"
test_endpoint "sentry" "https://sentry.io/jobs/list.json"
test_endpoint "sofi" "https://boards-api.greenhouse.io/v1/boards/sofi/jobs?content=true"
test_endpoint "spotify" "https://api.lever.co/v0/postings/spotify"
test_endpoint "squarespace" "https://boards-api.greenhouse.io/v1/boards/squarespace/jobs?content=true"
test_endpoint "stripe" "https://boards-api.greenhouse.io/v1/boards/stripe/jobs?content=true"
test_endpoint "tailscale" "https://boards-api.greenhouse.io/v1/boards/tailscale/jobs?content=true"
test_endpoint "taskrabbit" "https://boards-api.greenhouse.io/v1/boards/taskrabbit/jobs?content=true"
test_endpoint "thumbtack" "https://boards-api.greenhouse.io/v1/boards/thumbtack/jobs?content=true"
test_endpoint "toast" "https://boards-api.greenhouse.io/v1/boards/toast/jobs?content=true"
test_endpoint "twilio" "https://boards-api.greenhouse.io/v1/boards/twilio/jobs?content=true"
test_endpoint "twitch" "https://boards-api.greenhouse.io/v1/boards/twitch/jobs?content=true"
test_endpoint "udemy" "https://boards-api.greenhouse.io/v1/boards/udemy/jobs?content=true"
test_endpoint "vanta" "https://jobs.ashbyhq.com/vanta"
test_endpoint "vercel" "https://boards-api.greenhouse.io/v1/boards/vercel/jobs?content=true"
test_endpoint "veriff" "https://boards-api.greenhouse.io/v1/boards/veriff/jobs?content=true"
test_endpoint "waymo" "https://boards-api.greenhouse.io/v1/boards/waymo/jobs?content=true"
test_endpoint "webflow" "https://boards-api.greenhouse.io/v1/boards/webflow/jobs?content=true"
test_endpoint "yext" "https://boards-api.greenhouse.io/v1/boards/yext/jobs?content=true"
test_endpoint "ziprecruiter" "https://boards-api.greenhouse.io/v1/boards/ziprecruiter/jobs?content=true"
test_endpoint "zscaler" "https://boards-api.greenhouse.io/v1/boards/zscaler/jobs?content=true"

echo ""
echo "Results: $PASSED passed, $FAILED failed"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
