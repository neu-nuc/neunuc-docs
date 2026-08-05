# Box Deployment

Current production state and deployment procedures for the NeuNuc Box fulfillment system.

---

## Production Endpoints

| Service | URL | Status |
|---------|-----|--------|
| Storefront | `https://a74343ef.neunuc-storefront.pages.dev` | Live |
| Admin Dashboard | `https://e0539f3f.neunuc-admin.pages.dev` | Live |
| Checkout Worker | `https://neunuc-checkout.helkelx.workers.dev` | Live |
| Fulfillment Worker | `https://neunuc-fulfillment.helkelx.workers.dev` | Live |

## Database Schema (D1)

### `orders` Table

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT |
| `sku` | TEXT | NOT NULL, FK to products |
| `customer_name` | TEXT | NOT NULL |
| `customer_email` | TEXT | NOT NULL |
| `custom_name` | TEXT | For labels |
| `custom_team` | TEXT | For labels |
| `custom_year` | TEXT | For labels |
| `shirt_size` | TEXT | NOT NULL |
| `shirt_color` | TEXT | |
| `shipping_address` | TEXT | NOT NULL |
| `status` | TEXT | DEFAULT 'pending' |
| `stripe_payment_id` | TEXT | |
| `tracking_number` | TEXT | |
| `created_at` | DATETIME | DEFAULT CURRENT_TIMESTAMP |
| `packed_at` | DATETIME | |
| `shipped_at` | DATETIME | |

### `products` Table

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | TEXT | PRIMARY KEY |
| `name` | TEXT | NOT NULL |
| `price` | INTEGER | NOT NULL (cents) |
| `description` | TEXT | |
| `category` | TEXT | |
| `is_hero` | INTEGER | 1 = hero SKU |
| `is_active` | INTEGER | DEFAULT 1 |

### `inventory` Table

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | INTEGER | PRIMARY KEY |
| `bin_code` | TEXT | NOT NULL |
| `item_type` | TEXT | NOT NULL |
| `size` | TEXT | |
| `color` | TEXT | |
| `quantity` | INTEGER | DEFAULT 0 |
| `restock_trigger` | INTEGER | |
| `last_restocked` | DATETIME | |

### `customers` Table

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT |
| `name` | TEXT | NOT NULL |
| `email` | TEXT | NOT NULL, UNIQUE |
| `phone` | TEXT | |
| `address` | TEXT | |
| `city` | TEXT | |
| `state` | TEXT | |
| `zip` | TEXT | |
| `created_at` | DATETIME | DEFAULT CURRENT_TIMESTAMP |

### `shipments` Table

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT |
| `order_id` | INTEGER | NOT NULL, FK to orders |
| `carrier` | TEXT | DEFAULT 'USPS' |
| `tracking_number` | TEXT | |
| `shipping_label_url` | TEXT | |
| `status` | TEXT | DEFAULT 'pending' |
| `created_at` | DATETIME | DEFAULT CURRENT_TIMESTAMP |
| `delivered_at` | DATETIME | |

## Pricing Summary

| SKU | Name | Price | Type |
|-----|------|-------|------|
| bleacher | Bleacher Box | $50.00 | Hero |
| back-to-school | Back-to-School Box | $50.00 | Hero |
| team-mom | Team Mom Box | $50.00 | Hero |
| birthday-party | Birthday Party Box | $50.00 / $95.00 | Hero |
| mini-kit | Mini Kit Add-On | $25.00 | Add-on |
| *28 seasonal* | Various | $25.00 to $150.00 | Seasonal |

Shipping: $5.00 flat rate (single box), $7.00 (multi-box).

## Environment Variables (Production)

| Variable | Service | Value Type |
|----------|---------|------------|
| `STRIPE_SECRET_KEY` | Checkout Worker | `sk_live_...` |
| `STRIPE_WEBHOOK_SECRET` | Checkout Worker | `whsec_...` |
| `STRIPE_LINKS` | Storefront | JSON map of SKU to Payment Link URL |
| `D1_DATABASE_ID` | Fulfillment Worker | D1 database binding |
| `KV_ORDERS_ID` | Fulfillment Worker | KV namespace binding |
| `KV_PACK_LISTS_ID` | Fulfillment Worker | KV namespace binding |
| `KV_INVENTORY_ID` | Fulfillment Worker | KV namespace binding |
| `ADMIN_EMAIL` | All workers | Email address for notifications |
| `SHIPPING_RATE` | Fulfillment Worker | `500` (cents) |

## Worker Endpoints

### Checkout Worker

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/webhooks/stripe` | Stripe webhook handler |
| `GET` | `/health` | Health check |

### Fulfillment Worker

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/orders/pending` | Orders awaiting packing |
| `GET` | `/orders/:id` | Single order details |
| `POST` | `/orders/:id/pack` | Mark order packed |
| `POST` | `/orders/:id/ship` | Mark order shipped + add tracking |
| `GET` | `/inventory` | Current inventory snapshot |
| `POST` | `/inventory/restock` | Add inventory to bin |
| `GET` | `/health` | Health check |

## Deploy Guide

### Prerequisites

- Cloudflare account with Workers + Pages + D1 enabled
- Stripe account with live keys
- pnpm installed (`npm install -g pnpm`)
- Wrangler CLI authenticated (`npx wrangler login`)

### Step 1: D1 Database

```bash
cd neunuc-box-fulfillment
npx wrangler d1 create neunuc-orders
# Copy database_id from output
```

Add to `wrangler.toml`:

```toml
[[d1_databases]]
binding = "DB"
database_name = "neunuc-orders"
database_id = "YOUR_DATABASE_ID"
```

Create tables:

```bash
npx wrangler d1 execute neunuc-orders --file=./infra/schema.sql
```

### Step 2: KV Namespaces

```bash
npx wrangler kv:namespace create "ORDERS"
npx wrangler kv:namespace create "PACK_LISTS"
npx wrangler kv:namespace create "INVENTORY"
npx wrangler kv:namespace create "CONFIG"
```

Add IDs to `wrangler.toml`:

```toml
[[kv_namespaces]]
binding = "ORDERS"
id = "YOUR_ORDERS_NAMESPACE_ID"

[[kv_namespaces]]
binding = "PACK_LISTS"
id = "YOUR_PACK_LISTS_NAMESPACE_ID"

[[kv_namespaces]]
binding = "INVENTORY"
id = "YOUR_INVENTORY_NAMESPACE_ID"

[[kv_namespaces]]
binding = "CONFIG"
id = "YOUR_CONFIG_NAMESPACE_ID"
```

### Step 3: Deploy Workers

```bash
# Checkout Worker
cd workers/api
npx wrangler deploy

# Fulfillment Worker
cd ../fulfillment
npx wrangler deploy
```

### Step 4: Deploy Storefront

```bash
cd apps/site
npm run build
npx wrangler pages deploy .next/out
```

Or with static export:

```bash
npm run build
# Copy out/ directory to Pages
```

### Step 5: Deploy Admin

```bash
cd apps/web
npm run build
npx wrangler pages deploy dist
```

### Step 6: Configure Stripe

1. Stripe Dashboard, Developers, Webhooks, Add endpoint
2. URL: `https://neunuc-checkout.helkelx.workers.dev/webhooks/stripe`
3. Events: `checkout.session.completed`
4. Copy signing secret to `STRIPE_WEBHOOK_SECRET`

5. Create 4 Payment Links (see Box Stripe Setup)
6. Copy links to `STRIPE_LINKS` in `apps/site/pages/checkout.tsx`
7. Redeploy storefront

### Step 7: Verify

Run through end-to-end test:

1. Visit storefront URL
2. Select hero SKU
3. Complete Stripe test payment (`4242 4242 4242 4242`)
4. Verify order appears in admin dashboard
5. Verify picklist generates in fulfillment worker
6. Run pack station SOP
7. Mark packed + shipped via admin
8. Verify customer receives confirmation + tracking

## Quick Health Check

```bash
curl https://neunuc-checkout.helkelx.workers.dev/health
curl https://neunuc-fulfillment.helkelx.workers.dev/health
```

Expected: `{"status":"ok"}`

## Rollback

Workers rollback:

```bash
cd workers/api
npx wrangler deploy --tag previous
```

Pages rollback:

Use Cloudflare Dashboard, Pages, project, Deployments, Rollback.

## Monitoring

| Metric | Source | Check Frequency |
|--------|--------|-----------------|
| Worker errors | Cloudflare Workers dashboard | Daily |
| D1 query latency | Cloudflare D1 analytics | Weekly |
| Order volume | Admin dashboard + Stripe | Daily |
| Inventory levels | Admin dashboard | Daily |
| Pack time | Manual log (first 50 orders) | Per order |
| Customer reviews | Stripe + follow-up email | Weekly |

## Secrets Status

| Secret | Stored In | Rotation Needed |
|--------|-----------|-----------------|
| `STRIPE_SECRET_KEY` | Worker env var | If key leaked |
| `STRIPE_WEBHOOK_SECRET` | Worker env var | If endpoint regenerated |
| `ADMIN_EMAIL` | Worker env var | If admin changes |
| `D1_DATABASE_ID` | `wrangler.toml` | Never (unless DB recreated) |
| `KV_NAMESPACE_ID` | `wrangler.toml` | Never (unless namespace recreated) |
