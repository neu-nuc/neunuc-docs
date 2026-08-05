# CI/CD
Continuous Integration and Continuous Deployment for the NeuNuc ecosystem. GitHub Actions run tests, validate templates, audit dependencies, and deploy to production.

CI/CD is the automation layer. It ensures every commit is tested, every build is reproducible, and every deployment is traceable. Operators should not manually deploy — they push to a branch and the pipeline handles the rest.

**Location:** `.github/workflows/`

Workflows:
- `codeql.yml` — Security analysis
- `control-stack-ci.yml` — Control stack tests
- `customer-vc-ci.yml` — Customer VC tests
- `customer-vc-pilot-ci.yml` — Pilot tests
- `deploy-control-stack.yml` — Control stack deployment
- `deploy-pages.yml` — Static site deployment
- `lifecycle-audit.yml` — Dependency and secret audit
- `neunuc-public-release.yml` — Public release build
- `template-validation.yml` — Builder template tests

```powershell
gh run list --workflow=neunuc-public-release.yml
```

## Workflow Structure

Every workflow follows the same pattern: checkout → setup → install → test → build → deploy. This consistency makes it easy to debug failures and add new workflows.

Shared setup:
- Node.js 20+ via `actions/setup-node`
- pnpm via `pnpm/action-setup`
- Python 3.10+ via `actions/setup-python` (for runtime tests)

```yaml
# Reusable setup snippet
- uses: pnpm/action-setup@v4
  with:
    version: 9
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: 'pnpm'
- run: pnpm install
```

## Public Release Pipeline

The public release workflow builds the marketing site, runs Lighthouse audits, and deploys to the CDN. It triggers on every push to the `release` branch.

**Workflow:** `.github/workflows/neunuc-public-release.yml`

Jobs:
1. `build` — Install, build, test
2. `lighthouse` — Performance audit
3. `deploy` — Upload to Netlify/Cloudflare Pages

```yaml
name: Deploy Public Release
on:
  push:
    branches: [release]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
      - run: pnpm install
      - run: pnpm -r run build
      - run: pnpm -r run test
```

## Security Audit (CodeQL)

CodeQL scans the codebase for security vulnerabilities, injection risks, and unsafe patterns. It runs on every push to `main` and on a weekly schedule.

**Workflow:** `.github/workflows/codeql.yml`  
**Languages:** JavaScript, TypeScript, Python  
**Severity threshold:** Medium+

```powershell
# View latest CodeQL results
gh codeql results list --repo mysti/neunuc
```

## Lifecycle Audit

The lifecycle audit checks for outdated dependencies, unused packages, leaked secrets, and stale branches. It runs weekly and opens issues for anything found.

**Workflow:** `.github/workflows/lifecycle-audit.yml`  
**Tools:** `npm audit`, `trufflehog`, `depcheck`  
**Issue template:** `lifecycle-audit.md`

```yaml
# lifecycle-audit.yml
- name: Audit dependencies
  run: pnpm audit --json > audit.json
- name: Check for secrets
  uses: trufflesecurity/trufflehog@main
  with:
    path: ./
    base: main
```

## Template Validation

Every builder template is validated before it can be used. The template validation workflow builds the template, runs its tests, and checks that it scaffolds correctly.

**Workflow:** `.github/workflows/template-validation.yml`  
**Templates tested:** `templates/builders/sovereign-stack/`  
Failures block template promotion.

```yaml
# template-validation.yml
- name: Validate sovereign stack
  run: |
    cd templates/builders/sovereign-stack
    pnpm install
    pnpm run build
    pnpm run test
```
