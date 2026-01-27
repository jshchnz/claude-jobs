---
name: claude-jobs
description: Find job openings at tech companies. Use when user asks about jobs, careers, openings, positions, roles, or salaries - either at specific companies or general tech job queries.
allowed-tools: WebFetch
---

# Job Search

## Companies

| Company | Endpoint |
|---------|----------|
| airbnb | https://boards-api.greenhouse.io/v1/boards/airbnb/jobs |
| anthropic | https://boards-api.greenhouse.io/v1/boards/anthropic/jobs |
| cloudflare | https://boards-api.greenhouse.io/v1/boards/cloudflare/jobs |
| coinbase | https://boards-api.greenhouse.io/v1/boards/coinbase/jobs |
| datadog | https://boards-api.greenhouse.io/v1/boards/datadog/jobs |
| discord | https://boards-api.greenhouse.io/v1/boards/discord/jobs |
| dropbox | https://boards-api.greenhouse.io/v1/boards/dropbox/jobs |
| figma | https://boards-api.greenhouse.io/v1/boards/figma/jobs |
| gitlab | https://boards-api.greenhouse.io/v1/boards/gitlab/jobs |
| instacart | https://boards-api.greenhouse.io/v1/boards/instacart/jobs |
| linear | https://api.ashbyhq.com/posting-api/job-board/linear |
| lyft | https://boards-api.greenhouse.io/v1/boards/lyft/jobs |
| netlify | https://boards-api.greenhouse.io/v1/boards/netlify/jobs |
| notion | https://api.ashbyhq.com/posting-api/job-board/notion |
| revenuecat | https://jobs.ashbyhq.com/revenuecat |
| sentry | https://sentry.io/jobs/list.json |
| stripe | https://boards-api.greenhouse.io/v1/boards/stripe/jobs |
| vercel | https://boards-api.greenhouse.io/v1/boards/vercel/jobs |

Add your company: https://github.com/jshchnz/claude-jobs

## Instructions

User query: $ARGUMENTS

**IMPORTANT**: Do NOT use WebSearch. Only use WebFetch on the company endpoints from the table above.

### For company-specific queries:
1. Find company in table above (case-insensitive)
2. If not found: list available companies, link to GitHub to add more
3. WebFetch the endpoint with prompt: "List all jobs with title, location, department, salary if available, and apply URL (from absolute_url field for JSON or href for HTML)"
4. Display results grouped by department
5. Support filters: location, department, keywords (e.g., "engineering jobs in SF")
6. Always include an [Apply](url) hyperlink for each job using the absolute_url field
7. For "highest paying" queries, sort by salary (highest first) and show top results

### For general queries (no specific company mentioned):
When user asks general questions like "what tech jobs are open" or "highest paying tech roles":
1. WebFetch from multiple company endpoints (prioritize 3-5 companies)
2. Compile results and display the most relevant jobs
3. For salary-focused queries, sort by salary across all companies and show top results
4. Always mention which company each job is from
