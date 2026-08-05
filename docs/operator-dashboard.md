# Operator Dashboard
The Operator Dashboard is the central command surface. It organizes controls into nine lenses — each isolates a specific concern so operators switch contexts rather than navigating nested menus.

**Location:** `apps/neunuc-operator-dashboard/`  
**Stack:** React SPA with Vite, WebSocket runtime connection, local-first state

```powershell title="Dev"
cd apps/neunuc-operator-dashboard
pnpm run dev
```

```powershell title="Build"
pnpm run build
```

---

## Lens Architecture

A lens is a self-contained functional unit with its own state, data sources, and view components. All lenses live in `src/lens/`. Each exports a default component and a metadata object.

```javascript
// src/lens/DashboardLens.jsx
export const meta = {
  id: "dashboard",
  label: "Dashboard",
  icon: "dashboard",
  default: true
};

export default function DashboardLens() {
  // lens-specific logic
}
```

---

## Dashboard Lens

The default landing lens. Shows runtime health, active surfaces, recent events, and quick actions.

- **Data sources:** Runtime health API, surface connection counts, event log tail
- **Components:** `src/ui/components/Panel.jsx`, `src/ui/components/Table.jsx`

```javascript
<div className="dashboard-grid">
  <Panel title="Runtime Health">
    <HealthIndicator status={runtime.status} />
  </Panel>
  <Panel title="Active Surfaces">
    <Table rows={surfaces} columns={["name", "protocol", "connections"]} />
  </Panel>
</div>
```

## Automations Lens

View, trigger, and edit automations (scripts, webhooks, scheduled tasks). Stored in the config system and executed by the runtime's op_layer.

- **Data:** `config/automations/` or runtime config API
- **Actions:** Run, pause, edit, delete

```powershell
POST /api/v1/automations/{id}/trigger
Body: { "params": { "target": "staging" } }
```

## Business Lens

Business metrics, billing status, subscription tiers, and customer analytics. Connects to Stripe and the customer-vc system.

- **Integrations:** Stripe API, customer-vc metrics endpoint
- **Cache:** 5-minute refresh

```javascript
const metrics = await businessApi.getMetrics({
  period: "30d",
  granularity: "day"
});
```

## Evidence Lens

Browse and search OSINT evidence captured by NucBot. Filter by guild, channel, user, date range, or event type. Export chains as PDF or JSON.

- **Data source:** NucBot SQLite or Cloud SQL
- **Search:** Full-text index on `payload` JSON
- **Export:** PDF (styled report), JSON (raw chain)

```powershell
GET /api/v1/evidence/export?guild_id=...&format=pdf
```

## Marketing Lens

Campaign performance, public release metrics, SEO data, and social engagement. Connects to neunuc-public-release analytics.

- **Integrations:** Google Analytics, social media APIs
- **Data:** Page views, conversions, referral sources

```javascript
const campaigns = await marketingApi.getCampaigns({
  status: "active",
  channel: "discord"
});
```

## Projects Lens

Active projects, timelines, artifacts, and team assignments. Lightweight view into the Metasystem's project graph.

- **Data source:** Metasystem API (`nuc-server`)
- **Sync:** Bidirectional

```javascript
const projects = await metaApi.getProjects({
  status: "in_progress",
  assigned_to: currentUser.id
});
```

## Settings Lens

Operator preferences, runtime configuration, security policies, and integration credentials. The only lens that writes directly to the config system.

- **Backend:** Config system (`apps/neunuc-ops-workspace/config/`)
- **Validation:** Schema-enforced before write
- **Audit:** All changes logged with operator ID and timestamp

```yaml
# Example settings change
runtime:
  inference:
    default_device: directml
    fallback_device: cpu
```

## State Lens

Real-time view of the entire platform state: runtime status, active connections, queued jobs, memory usage, and error rates. The diagnostic lens.

- **Data sources:** Runtime health API, surface metrics, job queue status
- **Refresh:** Live WebSocket stream (1-second interval)

```javascript
const stateStream = new WebSocket("ws://localhost:8001/state");
stateStream.onmessage = (msg) => {
  const state = JSON.parse(msg.data);
  updateDashboard(state);
};
```
