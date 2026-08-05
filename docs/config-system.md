# Config System
`neunuc.config.json` is the single source of truth for org identity, deployment targets, design tokens, integrations, and trust boundaries. No component should hardcode values that belong in this file.

## File location

Repository root: `neunuc.config.json`

## Top-level schema

```json
{
  "org": { ... },
  "trustBoundary": { ... },
  "deployment": { ... },
  "design": { ... },
  "integrations": { ... },
  "builders": { ... },
  "workspace": { ... },
  "runtime": { ... }
}
```

## `org`

Identity and contact metadata.

| Field | Type | Purpose |
|-------|------|---------|
| `name` | string | Org display name |
| `shortName` | string | Short name for UI |
| `description` | string | Short descriptor |
| `url` | string | Primary domain |
| `contact.email` | string | Primary contact |
| `contact.url` | string | Contact URL |

## `trustBoundary`

Explicit security declaration. All components respect these flags.

| Field | Type | Default | Purpose |
|-------|------|---------|---------|
| `publicOnly` | boolean | `true` | All surfaces are public; no auth required |
| `noAuth` | boolean | `true` | No authentication layer |
| `noUploads` | boolean | `true` | No file upload endpoints |
| `staticOnly` | boolean | `true` | Static HTML only; no server-side rendering |
| `clientOnly` | boolean | `true` | All processing happens client-side |
| `privacyNotice` | string | — | Human-readable privacy statement |

**Rule**: If a boundary flag is `true`, the corresponding capability is locked out. No silent fallbacks.

## `deployment`

Target platforms and routing rules.

| Field | Type | Purpose |
|-------|------|---------|
| `defaultTarget` | string | Primary deploy target (`Cloudflare Pages`, `Netlify`, `Vercel`, `GitHub Pages`) |
| `allowedTargets` | string[] | All supported targets |
| `spaRouting` | boolean | Whether SPA routing is enabled |
| `cachePolicy` | object | Cache headers for static assets and HTML |
| `securityHeaders` | object | X-Content-Type-Options, X-Frame-Options, Referrer-Policy |

**Cache policy:**

| Asset type | Default header |
|-----------|----------------|
| Static assets | `public, max-age=31536000, immutable` |
| HTML pages | `public, max-age=0, must-revalidate` |

## `design`

Design tokens used by all outreach surfaces and dashboards.

| Field | Type | Value | Usage |
|-------|------|-------|-------|
| `themePreset` | string | `"meadow"` | Theme key |
| `tokens.accentColor` | string | `"#155c3a"` | Primary accent |
| `tokens.backgroundColor` | string | `"#f7f7f2"` | Page background |
| `tokens.surfaceColor` | string | `"#ffffff"` | Card/surface background |
| `tokens.textColor` | string | `"#17251f"` | Primary text |
| `tokens.mutedColor` | string | `"#45574b"` | Secondary text |
| `tokens.borderColor` | string | `"#c8d2ca"` | Borders and dividers |
| `tokens.cornerRadius` | string | `"16"` | Border radius in px |
| `tokens.contentWidth` | string | `"1120"` | Max content width in px |
| `tokens.density` | string | `"balanced"` | Spacing density |
| `tokens.headingStyle` | string | `"system"` | Heading font style |
| `darkMode.accentColor` | string | `"#85d9b0"` | Dark mode accent |
| `darkMode.backgroundColor` | string | `"#0a0a0a"` | Dark mode background |
| `darkMode.surfaceColor` | string | `"#141414"` | Dark mode surface |
| `darkMode.textColor` | string | `"#e8e8e8"` | Dark mode text |
| `darkMode.mutedColor` | string | `"#8a8a8a"` | Dark mode muted text |
| `darkMode.borderColor` | string | `"#2a2a2a"` | Dark mode borders |

## `integrations`

Third-party service credentials and feature flags.

| Field | Type | Purpose |
|-------|------|---------|
| `analytics` | object | Provider, endpoint, event whitelist |
| `leadCapture` | object | Form endpoint, success message, data notice |
| `turnstile` | object | Site key, verification endpoint |
| `payments` | object | Provider, checkout endpoint |
| `discord` | object | Bot ID, public key, application ID, guild ID |

**Analytics events:**
- `site_view`
- `cta_clicked`
- `offer_selected`
- `lead_capture_success`

All credential fields are optional and ignored when the corresponding capability is disabled.

## `builders`

Builder registry for the ops workspace.

| Field | Type | Purpose |
|-------|------|---------|
| `defaults.hosting` | string[] | Supported hosting targets |
| `defaults.deploymentTargets` | string[] | Supported deploy targets |
| `defaults.status` | string | Builder readiness status (`ready`, `wip`, `deprecated`) |
| `registryPath` | string | Path to builder templates (`apps/neunuc-ops-workspace/templates/builders`) |

## `workspace`

Ops workspace tuning.

| Field | Type | Purpose |
|-------|------|---------|
| `port` | number | `5173` |
| `host` | string | `"127.0.0.1"` (localhost only) |
| `allowedOrigins` | string[] | CORS allowed origins |
| `cors.enabled` | boolean | Whether CORS is enabled |
| `cors.allowedOrigins` | string[] | Additional CORS origins |

## `runtime`

Runtime tuning for `apps/neunuc-runtime/`.

| Field | Type | Purpose |
|-------|------|---------|
| `port` | number | Default HTTP port (`8787`) |
| `host` | string | Bind address (`127.0.0.1`) |

## Precedence

When a component loads config, values are resolved in this order (highest wins):

1. Environment variable override (`NEUNUC_CONFIG_*`)
2. Component-specific `.env` file
3. `neunuc.config.json`
4. Built-in defaults

## Editing guidelines

- Only edit `neunuc.config.json` directly. Do not scatter config across package.json files.
- Run `pnpm repo:audit` after config changes to verify no references are stale.
- Commit config changes separately from code changes for clean diffs.

---

## Universal Config Resolver

`tools/lib/config.mjs` is the shared loader used by scripts and apps that need runtime access to `neunuc.config.json`. It merges environment-specific overrides from `config/environments/{env}.json` and returns a frozen, validated config object.

This loader exists so no component re-implements config parsing. It handles deep merging, environment overrides, caching, and dot-path resolution. It has zero dependencies beyond Node built-ins.

- **Location:** `tools/lib/config.mjs`
- **Exports:** `loadConfig()`, `getCachedConfig()`, `getConfigValue()`, `validateConfigPaths()`
- **Cache:** Module-level, keyed by `env:root`. Use `invalidateCache: true` to force reload.

```js
import { loadConfig, getConfigValue } from '../../tools/lib/config.mjs';

const config = await loadConfig(); // Uses NEUNUC_ENV or defaults to 'local'
const orgName = getConfigValue(config, 'org.name', 'NeuNuc');
const accent = getConfigValue(config, 'design.tokens.accentColor');
const privacyNotice = getConfigValue(config, 'trustBoundary.privacyNotice');
```

### API

| Function | Args | Returns | Description |
|---|---|---|---|
| `loadConfig(options)` | `{ env, root, invalidateCache }` | `Promise<Object>` | Loads base + override, freezes result, caches it |
| `getCachedConfig()` | none | `Object \| null` | Returns cached config without reloading |
| `getConfigValue(config, path, default)` | `config, dotPath, fallback` | `*` | Resolves `"org.name"` against the config object |
| `validateConfigPaths(config, paths)` | `config, string[]` | `string[]` | Returns missing paths, empty if all present |

### Environment overrides

The loader looks for `config/environments/{env}.json` where `{env}` is:

1. `options.env`
2. `process.env.NEUNUC_ENV`
3. `'local'` (fallback)

If the override file exists, it is deep-merged into the base config. If it does not exist, the base config is used unchanged.
