# Contributing to claude-jobs

Add your company in 5 minutes!

## How to add your company

### 1. Find your public job API endpoint

Your endpoint must be publicly accessible. JSON APIs are preferred, but HTML job board pages also work. Common patterns:

- **Greenhouse**: `https://boards-api.greenhouse.io/v1/boards/yourcompany/jobs`
- **Lever**: `https://api.lever.co/v0/postings/yourcompany`
- **Ashby**: `https://api.ashbyhq.com/posting-api/job-board/yourcompany`
- **Ashby (HTML)**: `https://jobs.ashbyhq.com/yourcompany` (if API doesn't return all jobs)
- **Custom**: `https://yourcompany.com/api/jobs` or `https://yourcompany.com/jobs.json`

### 2. Test your endpoint

```bash
curl https://your-endpoint-url
```

### 3. Add your company to SKILL.md

Fork this repo and add a row to the Companies table in `SKILL.md`:

```markdown
| yourcompany | https://your-endpoint-url |
```

### 4. Submit a pull request

```bash
git checkout -b add-yourcompany
git commit -m "Add YourCompany job listings"
git push origin add-yourcompany
```

### Checklist

- [ ] Endpoint is publicly accessible
- [ ] Added row to Companies table in `SKILL.md`
- [ ] Tested with `curl`

## Other contributions

- **Report issues**: [Open an issue](https://github.com/jshchnz/claude-jobs/issues/new)
- **Improve the skill**: PRs welcome for better filtering, formatting, or error handling

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
