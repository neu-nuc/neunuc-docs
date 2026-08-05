# Box Builder

Physical product assembly system for generating print-ready assets per order.

---

## What It Builds

| Output | Purpose | Location |
|--------|---------|----------|
| Pack checklist PDF | What goes in each box, bin locations, custom fields highlighted | `output/pack/` |
| Label sheet PDF | Name labels, team labels, number labels, print-ready | `output/labels/` |
| Insert card | Thank you note + component list + QR code for reorder | `output/inserts/` |
| Shipping label | Pre-formatted with customer address + custom fields | `output/shipping/` |
| Inventory pick list | What to pull from bins for today's orders | `output/pick/` |

## Usage

Generate all assets for an order:

```powershell
cd C:\Users\mysti\neunuc-box-fulfillment
node scripts/build-box.js --order 1720893
```

Generate labels only:

```powershell
node scripts/build-box.js --order 1720893 --labels-only
```

Generate pack checklist only:

```powershell
node scripts/build-box.js --order 1720893 --pack-only
```

## Label Specs

| Spec | Dimensions | Count | Use |
|------|------------|-------|-----|
| Avery 5160 | 1" x 2-5/8" | 30 per sheet | Name / team labels |
| Avery 5167 | 1/2" x 1-3/4" | 80 per sheet | Return address size |
| Custom waterproof | 2" x 3" | Per order | Name labels on waterproof vinyl |

## Print Settings

| Material | Printer | Settings |
|----------|---------|----------|
| Name labels | Inkjet or laser | Standard, no bleed |
| Shirt labels | Heat transfer vinyl | Mirror image, 320F, 15 sec |
| Decals | Inkjet + clear laminate | High quality, let dry 24h |
| Insert cards | Cardstock 110lb | Borderless, best quality |
| Shipping labels | Thermal (Rollo/Zebra) or laser | 4x6, no margins |

## Registry

Box definitions live in `content/boxes/registry.json` — 32 SKUs with `recipientConfig` specifying compatible roles, age bands, contextual fields, and core items per box.
