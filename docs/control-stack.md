# Control Stack

The Control Stack is a generic, local-first control console for modular platform infrastructure. It enforces policies, manages resource allocation, and provides a unified interface for controlling distributed components.

The Control Stack is the governance layer. It decides what runs, where it runs, and what resources it gets. It is "generic" by design: policies are defined in code, not hard-coded rules. This means the same stack can control the NeuNuc runtime, the Metasystem, or any future component without modification.

**Location:** `apps/control-stack/`

Key files:
- `app.js` — Control console HTTP server
- `policy-engine.mjs` — Policy evaluation and enforcement
- `scripts/build.mjs` — Build pipeline

```powershell
cd apps/control-stack
node app.js
pnpm run test
```

## Policy Engine

The policy engine evaluates rules against resource requests. Rules are written in JavaScript modules and loaded at startup. Each rule receives a context object (requestor, resource type, current load) and returns `allow`, `deny`, or `defer`.

- **Location:** `policy-engine.mjs`
- **Tests:** `policy-engine.test.mjs`

Rule structure:
- `name` — Human-readable identifier
- `priority` — Evaluation order (lower first)
- `evaluate(context)` — Returns decision

```javascript
// policy-engine.mjs
export const rules = [
  {
    name: "max-runtime-instances",
    priority: 1,
    evaluate(ctx) {
      if (ctx.resource === "runtime" && ctx.instances >= 4) {
        return { decision: "deny", reason: "Max 4 runtime instances" };
      }
      return { decision: "defer" };
    }
  }
];
```

## Resource Allocation

The control stack tracks resource usage across all managed components. It maintains a live inventory of CPU, memory, GPU, and network capacity. When a component requests resources, the policy engine checks availability and constraints.

- **Inventory:** In-memory with periodic disk snapshot
- **Update interval:** 5 seconds
- **Persistence:** `data/inventory.json`

```javascript
// Resource request
const allocation = await controlStack.allocate({
  component: "neunuc-runtime",
  cpu: 2,
  memory: "4Gi",
  gpu: 1
});

if (allocation.decision === "allow") {
  startRuntime(allocation.resources);
}
```

## Control API

The control console exposes a REST API for external components to register, request resources, and report health. All endpoints require a valid component token.

- **Base URL:** `http://localhost:9000`
- **Auth:** Component token in `X-Component-Token` header

Endpoints:
- `POST /register` — Register a new component
- `POST /allocate` — Request resources
- `POST /heartbeat` — Report health
- `GET /inventory` — View current allocation

```bash
# Register a component
curl -X POST http://localhost:9000/register \
  -H "X-Component-Token: $TOKEN" \
  -d '{"id":"runtime-01","type":"runtime","capabilities":["gpu","websocket"]}'
```
