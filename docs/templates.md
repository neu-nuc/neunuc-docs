# Templates & Builders
Templates and builders are the starting points for new NeuNuc instances and custom stacks. They provide pre-configured project scaffolds with the correct dependencies, folder structure, and boilerplate.

A builder is more than a template. It is a runnable application that lets operators configure, preview, and export a custom stack. The sovereign stack builder, for example, is a Vite-based React app that walks operators through selecting components, setting policies, and generating deployment artifacts.

**Location:** `templates/builders/`

Current builders:
- `sovereign-stack/` — Ethical AI framework builder

Shared tools:
- `tools/lib/` — Common utilities used by all builders

```powershell
cd templates/builders/sovereign-stack
pnpm run dev
pnpm run build
```

## Sovereign Stack Builder

The Sovereign Stack Builder is an interactive tool for constructing constitutional AI systems. It demonstrates ethical AI principles through guided tours, contextual hints, and configurable policy engines. Operators use it to understand the framework before deploying it to production.

- **Location:** `templates/builders/sovereign-stack/`
- **Stack:** React 18, TypeScript, Vite, Tailwind CSS, shadcn/ui
- **Key deps:** `@github/spark`, `@octokit/core`, `@heroicons/react`

```powershell
pnpm install
pnpm run dev
pnpm run build
pnpm run build:analyze
```

## Builder Architecture

The builder follows a layered architecture: entry → core components → feature modules → utilities. This keeps the codebase modular and makes it easy to add new builders by copying the sovereign stack scaffold.

Structure:
- `index.html` → `main.tsx` → `App.tsx` → `EthicalEngineDemo`
- `src/components/` — Shared UI components
- `src/features/` — Domain-specific modules
- `src/lib/` — Utilities and hooks
- `src/styles/` — Tailwind config and theme

```tsx
// src/App.tsx
import { EthicalEngineDemo } from "./features/ethical-engine";

export default function App() {
  return (
    <div className="min-h-screen bg-neutral-50">
      <EthicalEngineDemo />
    </div>
  );
}
```

## Creating a New Builder

To create a new builder, copy the sovereign-stack directory, rename the package, and replace the feature modules. The shared tooling (Vite config, Tailwind setup, lint rules) stays the same.

1. Copy `templates/builders/sovereign-stack/` to `templates/builders/{name}/`
2. Update `package.json` name and description
3. Replace `src/features/` with new domain logic
4. Update `index.html` title and meta tags
5. Add builder to `templates/builders/README.md`

```powershell
# Scaffold new builder
Copy-Item -Recurse templates/builders/sovereign-stack templates/builders/analytics-builder
cd templates/builders/analytics-builder

# Update package name
(Get-Content package.json) -replace 'sovereign-stack', 'analytics-builder' | Set-Content package.json
```
