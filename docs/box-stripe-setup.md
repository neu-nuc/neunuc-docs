# Stripe Setup for Box Storefront

Stripe account configuration for the NeuNuc Box storefront. Estimated time to first live payment: 30 minutes.

---

## Step 1: Create Stripe Account

1. Go to https://dashboard.stripe.com/register
2. Use business email: `founder@hkneunuc.llc`
3. Business name: helen kella / neunuc llc (or DBA if registered)
4. Industry: Gifts & Special Events, then Custom Merchandise
5. Estimated monthly volume: $1,000 to $5,000

## Step 2: Create Payment Links for Hero SKUs

Stripe Payment Links are the fastest path — no backend code needed.

### Standard Box ($50)

1. Stripe Dashboard, Payment Links, Create
2. Product name: Bleacher Box — Standard
3. Price: $50.00
4. Description: Everything for game day in one box: shirt, cup, pouch, decal, checklist. Custom name / team fields at checkout.
5. Collect customer name: Yes
6. Collect shipping address: Yes
7. After payment: Show confirmation page
8. Copy link, paste into `STRIPE_LINKS.bleacher` in `checkout/page.tsx`

### Repeat for all heroes

| SKU | Name | Price | Link variable |
|-----|------|-------|---------------|
| bleacher | Bleacher Box | $50 | `STRIPE_LINKS.bleacher` |
| back-to-school | Back-to-School Box | $50 | `STRIPE_LINKS['back-to-school']` |
| team-mom | Team Mom Box | $50 | `STRIPE_LINKS['team-mom']` |
| birthday-party | Birthday Party Box | $50 / $95 | Create two links: Standard + Premium |

### Mini Kit Add-On ($25)

Create as a separate product:

- Name: Mini Kit Add-On
- Price: $25
- Description: Complete the moment: sticker, keychain, pouch, checklist, bag tag.
- Use as upsell link in post-purchase email (not on product page)

## Step 3: Configure Shipping (Flat Rate)

Stripe Dashboard, Settings, Shipping & Delivery

Add flat-rate shipping:

- Name: Standard Shipping
- Rate: $5.00 (or $7.00 if more than 1 box)
- Delivery estimate: 3 to 5 business days
- Countries: United States

## Step 4: Custom Fields at Checkout

For each Payment Link, enable:

- Name (required)
- Custom text field: Custom name for labels (optional)
- Custom text field: Team / town / year (optional)
- Custom text field: Shirt size (Y S, Y M, Y L, Adult S to 3XL) (required)

These fields feed directly into the pack station SOP.

## Step 5: Test Purchase

1. Stripe Dashboard, Payment Links, click link, Copy
2. Open in incognito window
3. Use Stripe test card: `4242 4242 4242 4242`, any future date, any CVC, any ZIP
4. Complete purchase
5. Verify:
   - Order appears in Stripe Dashboard
   - Custom fields captured correctly
   - Shipping address complete
   - Confirmation email sent

## Step 6: Connect to Cloudflare Pages

Deploy the storefront:

```bash
cd neunuc-box-fulfillment/apps/site
# Ensure STRIPE_LINKS in checkout/page.tsx are updated with real links
npm run build
# Deploy to Cloudflare Pages
npx wrangler pages deploy .next/out
```

Or if using static export:

```bash
npm run build
# Copy out/ to Pages
```

## Step 7: Post-Purchase Flow

Set up Stripe webhooks (optional but recommended):

1. Stripe Dashboard, Developers, Webhooks, Add endpoint
2. Endpoint URL: `https://your-domain.com/api/webhooks/stripe` (or use a Cloudflare Worker)
3. Events to listen: `checkout.session.completed`
4. Action on event:
   - Send order notification to operator email
   - Log order to D1 or Google Sheet
   - Trigger pack station queue

Simple alternative: Just check Stripe Dashboard daily. At fewer than 20 orders per week, manual is fine.

## Pricing Rules

| Rule | Implementation |
|------|----------------|
| No SKU under $25 | Mini Kit is add-on only |
| Every $50+ box has 4 or more layers | Description lists wear / use / organize / customize / gift |
| Custom fields carry $5 to $8 fee | Included in Standard / Premium; add-on for Mini Kit |
| Group boxes require 50% deposit | Use Request quote flow instead of instant checkout |
| Rush fees non-refundable | Add rush as separate Payment Link product ($15 / $35) |

## Estimated Time to Revenue

| Step | Time | Cumulative |
|------|------|------------|
| Stripe account setup | 5 min | 5 min |
| 4 Payment Links created | 10 min | 15 min |
| Shipping configured | 3 min | 18 min |
| Test purchase | 5 min | 23 min |
| Deploy to Pages | 5 min | 28 min |
| **First real order possible** | — | **~30 min** |

## Next Actions

- [ ] Create Stripe account
- [ ] Build 4 Payment Links
- [ ] Replace `STRIPE_LINKS` in `checkout/page.tsx`
- [ ] Deploy to Cloudflare Pages
- [ ] Run test purchase
- [ ] Share link in local Facebook groups

## Resources

- Stripe docs: https://stripe.com/docs/payment-links
