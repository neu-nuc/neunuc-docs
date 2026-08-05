# Stripe Checkout Worker
Cloudflare Worker adapter for Stripe-hosted Checkout Sessions. Optional — only needed when Payment Links are insufficient.

---

## Explainer

A separate Cloudflare Worker adapter for the Public Access Site. Not deployed or configured by default. The static site can use Stripe Payment Links without this Worker; use this adapter only when Stripe-hosted Checkout Sessions are required.

- **Path**: `apps/neunuc-ops-workspace/adapters/stripe-checkout-worker/`
- **Platform**: Cloudflare Workers
- **API**: Stripe API version `2026-05-27.dahlia`
- **Binding**: Workers KV namespace `STRIPE_EVENTS`

```powershell
cd apps/neunuc-ops-workspace/adapters/stripe-checkout-worker
pnpm dlx wrangler deploy --config wrangler.jsonc
```

---

## Security Boundary

| Guard | Behavior |
|-------|----------|
| Allowlist only | Browser sends only `offerId`; never amount, price ID, key, or URL |
| Server-side mapping | Worker maps `offerId` to Price IDs and creates Checkout Sessions |
| Dynamic methods | Omits `payment_method_types` so Stripe Dashboard dynamic methods remain available |
| Origin lock | Permits only configured `ALLOWED_ORIGIN` |
| HTTPS requirement | Success and cancel URLs must be HTTPS on the allowed origin |
| Webhook verification | Stripe signature verification + KV idempotency; fails closed if either is absent |

---

## Configure

1. Create a Workers KV namespace:
   ```powershell
   pnpm dlx wrangler kv namespace create STRIPE_EVENTS
   ```

2. Copy `wrangler.jsonc.example` to `wrangler.jsonc` and replace the KV namespace placeholder.

3. Set non-secret variables in the Worker dashboard:
   - `ALLOWED_ORIGIN`
   - `SUCCESS_URL`
   - `CANCEL_URL`
   - Three offer Price IDs

4. Set secrets via Cloudflare secret store. Use a Stripe restricted key with only Checkout permissions:
   ```powershell
   pnpm dlx wrangler secret put STRIPE_SECRET_KEY
   pnpm dlx wrangler secret put STRIPE_WEBHOOK_SECRET
   ```

5. Deploy only after configuration is complete:
   ```powershell
   pnpm dlx wrangler deploy --config apps/neunuc-ops-workspace/adapters/stripe-checkout-worker/wrangler.jsonc
   ```

6. Set the deployed `/create-checkout` URL as `payments.checkoutEndpoint` in the public `site-config.json`. Configure the Stripe webhook destination as the deployed `/webhook` URL.

---

## Recurring Support

For subscriptions, use the `recurring-support` offer mapping. It creates Checkout in `subscription` mode.

Configure Stripe Customer Portal in the Stripe Dashboard for authenticated customer self-service. Do not build manual renewal loops or expose a portal link from the unauthenticated static site.

---

## What's Not Included

No project, account, domain, Stripe key, price ID, webhook secret, or Worker URL is included in this repository.
