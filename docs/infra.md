# Infrastructure
The Infrastructure layer defines how NeuNuc deploys to production. It includes public-host nginx configs, release scripts, and the deployment pipeline.

Infrastructure is not just servers. It is the contract between the codebase and the runtime environment. The public-host nginx config defines how traffic enters the platform. Release scripts define how code moves from commit to live. Together they form the deployment contract.

- **Location:** `infra/`
- `public-host/nginx/` — Reverse proxy and SSL termination
- `public-host/scripts/` — Release activation, staging, rollback
- `deploy.ps1` — Top-level deployment orchestrator

```powershell
cd C:\Users\mysti\neunuc
.\scripts\deploy.ps1 -Environment production
```

## Public Host Foundation

The public host is a provider-neutral Linux server running nginx. It is **not** Netlify, **not** Cloudflare Pages, and **not** part of the custody runtime. It is an organization-controlled host where public releases are staged and activated manually by an operator.

This foundation publishes only versioned static releases from `apps/neunuc-public-release/`. The custody runtime, its keys, and protected data are not installed on this host.

- **Location:** `infra/public-host/`
- **Web root:** `/srv/www/neunuc.com/`
- **Config:** `infra/public-host/nginx/neunuc.com.conf`
- **Scripts:** `infra/public-host/scripts/`

```bash
# First host setup
# 1. Provision Linux server (org-owned)
# 2. Install nginx, Node.js 22, rsync, certbot
# 3. Create /srv/www/neunuc.com/releases/
# 4. Copy nginx/neunuc.com.conf to sites-available
# 5. Point DNS apex and www at the host
# 6. Verify HTTP, issue TLS cert, enable HTTPS block
# 7. Test: nginx -t && nginx -s reload
```

### Release layout

```text
/srv/www/neunuc.com/
  releases/
    0.1.0/
  current -> releases/0.1.0
  previous -> releases/<last-release>
```

A release is staged into a new immutable directory, validated, then made live by atomically replacing `current`. The former `current` becomes `previous` for one-command rollback.

### Scripts

| Script | Purpose |
|--------|---------|
| `stage-release.sh` | Copies release source to a new versioned directory, runs `validate.mjs` |
| `activate-release.sh` | Atomically swaps `current` symlink to the staged release |
| `rollback-release.sh` | Reverts `current` to `previous` |

```bash
# Stage a release
bash infra/public-host/scripts/stage-release.sh apps/neunuc-public-release 0.1.0

# Activate it
bash infra/public-host/scripts/activate-release.sh 0.1.0

# Roll back if needed
bash infra/public-host/scripts/rollback-release.sh
```

**Staging safety:**
- Runs the release's `validate.mjs` before copying
- Refuses an existing release ID (immutable)
- Only publishes after DNS resolves, TLS is valid, and validation passes

### Verification

```bash
curl --fail --location https://neunuc.com/
curl --fail --location https://neunuc.com/what-we-build
curl --fail --location https://neunuc.com/architecture
curl --fail --location https://neunuc.com/services
curl --fail --location https://neunuc.com/contact
```

Also verify: mobile navigation, keyboard focus, 404 route, project-intake email fallback.

### Operating rule

This foundation deliberately has **no provider-specific deploy command** and **no remote auto-deploy credential**. A host operator explicitly stages and activates each release, leaving a clear rollback pointer.
