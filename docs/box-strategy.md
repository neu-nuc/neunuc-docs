# Product Strategy: Box Fulfillment

The 80/20 Box approach for the NeuNuc physical product line. Sell four hero SKUs that generate 80 percent of revenue. One funnel. One checkout. One pack station. One standard shipping rate.

---

## Current State

| Item | Status |
|------|--------|
| Storefront (Next.js + Cloudflare Pages) | Live |
| Admin dashboard (React SPA) | Live |
| Checkout Worker (Cloudflare Worker + Stripe) | Live |
| Fulfillment Worker (Cloudflare Worker + D1 + KV) | Live |
| 32 box SKUs defined | Complete |
| Pack station SOP | Documented |
| First paid order | Not yet closed |

## The 80/20 Box

Four hero SKUs cover 80 percent of orders. The remaining 28 SKUs are seasonal or upsell add-ons.

### Hero SKUs

| SKU | Name | Price | Target Customer |
|-----|------|-------|-----------------|
| bleacher | Bleacher Box | $50 | Youth sports parents |
| back-to-school | Back-to-School Box | $50 | Parents of school-age kids |
| team-mom | Team Mom Box | $50 | Team organizers, PTO leaders |
| birthday-party | Birthday Party Box | $50 / $95 | Parents planning kids parties |

### Product Mix Rule

- No SKU under $25 (Mini Kit is $25 add-on, not standalone)
- Every $50+ box has 4 or more layers: wear, use, organize, customize, gift
- Custom fields carry $5 to $8 fee (built into Standard / Premium)

## Unit Economics

| Metric | Standard Box | Premium Box | Mini Kit |
|--------|-------------|-------------|----------|
| Price | $50 | $95 | $25 |
| COGS | ~$22 | ~$38 | ~$10 |
| Shipping (flat) | $5 | $7 | $5 |
| Gross margin | $23 (46%) | $50 (53%) | $10 (40%) |
| Payment processing | ~$1.65 | ~$2.93 | ~$0.83 |
| Net per unit | ~$21 | ~$47 | ~$9 |

Break-even at 20 orders per month covers a part-time packer.

## Strategy: What to Cut, Build, or Keep

### Cut

| Item | Reason |
|------|--------|
| Inventory-heavy strategy | Start with print-on-demand blanks + batch label printing |
| Multi-carrier shipping | Use flat-rate USPS; negotiate later |
| Complex group pricing | Simplify: $50 / $95 / Group quote only |

### Build

| Item | Priority | Timeline |
|------|----------|----------|
| Pack station SOP execution | High | Week 1 |
| Stripe Payment Links for 4 hero SKUs | High | Week 1 |
| Facebook / Instagram product posts | High | Week 2 |
| Automated order-to-picklist pipeline | Medium | Month 2 |
| Seasonal SKU rotation (fall sports, holidays) | Medium | Month 2 |

### Keep

| Item | Reason |
|------|--------|
| Next.js + Cloudflare Pages stack | Fast, cheap, no server maintenance |
| Stripe Payment Links | No custom checkout code needed |
| D1 + KV for order tracking | Serverless, zero infra overhead |
| 32-SKU registry | Easy to add / remove without code changes |

## Deployment: First Orders

### Week 1: Storefront Live

1. Deploy storefront to Cloudflare Pages
2. Connect 4 Stripe Payment Links
3. Verify checkout flow end-to-end
4. Share link in 3 local Facebook groups

### Week 2: First Orders

1. Monitor Stripe Dashboard for orders
2. Print pack checklists for incoming orders
3. Run pack station SOP on each order
4. Ship via USPS flat rate
5. Follow up with customer for photo / review

### Month 1: Stabilize

1. Track pack time per box (target: 20 min Standard)
2. Identify most-ordered hero SKU
3. Reorder blanks before stockout
4. Add first upsell email (Mini Kit add-on post-purchase)

### Month 2: Scale

1. Hire first packer (5 supervised runs + sign-off)
2. Add 2 seasonal SKUs (e.g., Holiday Box, Senior Night Box)
3. Set up Google Business Profile for local SEO
4. Reach 50 orders for the month

## What Happens After First Orders

| Milestone | Trigger | Action |
|-----------|---------|--------|
| 5 orders in 7 days | Organic demand signal | Post in 3 more local groups; ask for referrals |
| 20 orders in a month | Part-time viable | Hire packer; batch blank orders |
| 50 orders in a month | Near full-time | Evaluate local printer partnership; add DTG for custom colors |
| 100 orders in a month | Scalable | Add auto-ship subscription (monthly Mini Kit); negotiate bulk blank pricing |

## Key Assumptions

| Assumption | Test | Fail Contingency |
|------------|------|------------------|
| Parents will pay $50 for a curated box | First 5 orders | Lower to $45; increase value perception |
| Custom name + team fields drive conversion | A/B test on landing page | Remove fields; use generic team themes |
| Local Facebook groups are best channel | 2-week posting test | Shift to Instagram Reels or school PTO email lists |
| 20-minute pack time is achievable | Time first 10 orders | Add pre-kitted sub-assemblies; hire earlier |

## Next Actions

1. Close first paid order via Stripe Payment Link
2. Document pack time for first 5 orders
3. Set weekly inventory count routine
4. Post storefront link in local parent groups

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| Month 0 | 4 hero SKUs, not 32 | Focus; 32 registry allows seasonal rotation without re-architecture |
| Month 0 | Flat-rate shipping, not real-time rates | Simplicity; revisit at 50+ orders/month |
| Month 0 | Stripe Payment Links, not custom checkout | Speed to revenue; custom checkout only if Payment Links limit conversion |
| Month 0 | Cloudflare Workers, not AWS Lambda | Already in Cloudflare ecosystem; D1 + KV are zero-cost at low volume |

## Revenue Model

| Month | Orders | Revenue | COGS | Net (before labor) |
|-------|--------|---------|------|-------------------|
| 1 | 5 | $250 | $110 | $140 |
| 2 | 15 | $750 | $330 | $420 |
| 3 | 30 | $1,500 | $660 | $840 |
| 6 | 75 | $3,750 | $1,650 | $2,100 |
| 12 | 150 | $7,500 | $3,300 | $4,200 |

At 100 orders/month with a part-time packer ($800/month), net profit is approximately $2,300/month.
