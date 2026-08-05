# Metasystem
The NeuNūc Metasystem is the AI-powered knowledge graph and project management layer. It runs as a desktop Electron application with a local server and React UI.

The Metasystem is where long-term memory lives. It builds knowledge graphs from conversations, documents, and project artifacts. Operators use it to manage projects, view AI-generated insights, and navigate connected data through a spatial node map. Everything is local-first: the graph lives on disk, not in a remote database.

**Location:** `apps/nuc-metasystem/`

Architecture:
- `nuc-server/` — Fastify/Node.js backend, graph database, AI inference proxy
- `nuc-ui/` — React SPA with spatial node map, project dashboards, AI chat
- `electron.js` — Desktop shell wrapping server + UI
- `sites/public/` — Static site generator output

Dev mode (runs server + UI concurrently):

```powershell
cd apps/nuc-metasystem
pnpm run dev
```

Production build:

```powershell
pnpm run build
pnpm run electron:dist
```

## Nuc Server

The server is the brain of the Metasystem. It manages the knowledge graph, proxies AI requests, and serves the UI. It uses a local graph database (embedded) for zero-config operation.

**Location:** `apps/nuc-metasystem/nuc-server/`

Key modules:
- `src/graph/` — Graph CRUD and query engine
- `src/ai/` — OpenAI/Foundry proxy with caching
- `src/projects/` — Project metadata and artifact links
- `src/connections/` — External service integrations

```powershell
cd apps/nuc-metasystem/nuc-server
pnpm run dev        # hot-reload server on :3001
pnpm run start      # production server
```

## Nuc UI

The UI is a React application that renders the knowledge graph as a spatial node map, shows project dashboards, and provides an AI chat interface. It communicates with the nuc-server over HTTP/WebSocket.

**Location:** `apps/nuc-metasystem/nuc-ui/`

Key components:
- `NodeMap.jsx` — Spatial graph visualization
- `AIChat.jsx` — Conversational AI interface
- `ProjectDashboard.jsx` — Project overview and metrics
- `PerspectiveViewer.jsx` — Multi-perspective data views
- `ConnectionsManager.jsx` — External service links

```powershell
cd apps/nuc-metasystem/nuc-ui
pnpm run dev        # Vite dev server on :5173
pnpm run build      # Production bundle to dist/
```

## Knowledge Graph

The graph stores entities (people, projects, documents, concepts) and relationships between them. It is queryable via a custom graph language and visualized as a force-directed node map.

**Storage:** Local embedded database in `apps/nuc-metasystem/data/graph.db`  
**Schema:** Defined in `nuc-server/src/graph/schema.js`

```javascript
// Graph query example
const result = await graph.query(`
  MATCH (p:Project {name: "NeuNuc Docs"})
  -[:HAS_ARTIFACT]->(a:Artifact)
  RETURN a.title, a.type
`);
```

## AI Proxy

The AI proxy forwards chat and completion requests to configured providers (Azure OpenAI, OpenAI, local) while maintaining conversation history and caching frequent queries.

**Config:** `apps/nuc-metasystem/.env` or `nuc-server/.env`

Supported providers:
- Azure OpenAI
- OpenAI
- Local ONNX runtime (via runtime bridge)

```env
# .env
AI_PROVIDER=azure_openai
AZURE_OPENAI_ENDPOINT=https://neunuc.openai.azure.com/
AZURE_OPENAI_KEY=...
AZURE_OPENAI_DEPLOYMENT=gpt-4o
```

## Electron Distribution

The Electron shell packages the server and UI into a single desktop application. This is how most operators interact with the Metasystem.

**Entry:** `apps/nuc-metasystem/electron.js`  
**Build:** `pnpm run electron:dist`  
**Output:** `dist/NeuNuc-Metasystem-*.exe` (Windows), `.dmg` (macOS), `.AppImage` (Linux)

```powershell
# Build all platforms
pnpm run electron:dist

# Build Windows only
pnpm run electron:dist -- --win
```
