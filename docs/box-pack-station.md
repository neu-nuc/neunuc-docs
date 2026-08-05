# Pack Station SOP

Physical pack station standard operating procedure. Target pack time per Standard Box: 20 minutes or less.

---

## Station Layout

```
PACK STATION (6ft table or workbench)
-----------------------------------------------
[A1] Shirts    [A2] Hoodies   [A3] Blanks
[B1] Drinkware [B2] Pouches   [B3] Labels
[C1] Decals    [C2] Paper     [C3] Boxes
PRINTER + HEAT PRESS / DTG STATION
SHIPPING SCALE + LABEL PRINTER
```

## Bin Map

| Bin | Code | Contents | Restock Trigger |
|-----|------|----------|-----------------|
| A1 | S | Blank t-shirts (youth/adult sizes by color) | 5 or fewer per size |
| A2 | H | Blank hoodies (adult sizes, neutral + team colors) | 3 or fewer per size |
| A3 | B | Backup blanks (last-season colors, misc sizes) | 2 or fewer per size |
| B1 | D | Tumblers, cups, drinkware inserts | 5 or fewer each |
| B2 | P | Pouches, bags, small organizers | 5 or fewer each |
| B3 | L | Name labels, number labels, team labels (pre-cut sheets) | 20 or fewer sheets |
| C1 | De | Decals, stickers, car decals (sorted by theme) | 10 or fewer each |
| C2 | Ch | Checklists, cards, schedules, thank-you notes | 25 or fewer each |
| C3 | Bx | Shipping boxes (3 sizes), filler, tape, tissue | 10 or fewer each size |

## Pre-Pack Checklist

Complete before every order:

- Print order sheet with custom fields highlighted (name, number, team, town, year)
- Verify blank inventory for size and color needed
- Check label printer has correct label stock loaded
- Confirm heat press / DTG is warmed up (if needed)
- Verify shipping address printed legibly on order sheet

## Pick Sequence (60 seconds)

1. Read order sheet — note size, color, custom text
2. A1 to B1 to B2 to C1 to C2 — pick all standard components
3. A2 — only if Premium or Hoodie upgrade ordered
4. B3 — grab correct label sheet; verify spelling against order

## Customize Sequence (5 to 10 minutes)

| Step | Action | Quality Check |
|------|--------|---------------|
| 1 | Print name / number labels | Spelling matches order exactly |
| 2 | Apply labels to shirt / pouch / tumbler | Straight, centered, no bubbles |
| 3 | If team order: print roster checklist | One per order, not per box |
| 4 | If custom color request: verify heat press settings | Test on scrap first |
| 5 | Sign pack checklist with initials + time | Required for every box |

## Pack Sequence (3 to 5 minutes)

1. Fold apparel — neat, face-up, size tag visible
2. Nest drinkware — wrap in tissue, place in pouch if included
3. Layer paper goods — checklist on top (first thing customer sees)
4. Add labels / decals — in small envelope or taped to checklist
5. Insert keepsake — if applicable (ornament, keychain)
6. Close box — tape seal, no overstuffing
7. Attach shipping label — scan barcode, confirm weight

## Post-Pack (2 minutes)

- Photo box closed (for disputes / quality log)
- Mark order "packed" in system
- Move to "shipped" bin for carrier pickup
- Update inventory count in `inventory.db` or sheet

## Quality Gates

| Gate | Rule | Fail Action |
|------|------|-------------|
| Spelling | Custom name must match order letter-for-letter | Reprint label, do not ship |
| Size | Apparel size must match order | Re-pick from bin; if unavailable, contact customer |
| Completeness | Every layer (wear / use / organize) present per SKU spec | Re-open, add missing item |
| Damage | No stains, wrinkles, or print defects on blanks | Replace from A3 backup bin |
| Weight | Standard approximately 1.2 lbs; Premium approximately 2.5 lbs | If off by more than 20 percent, re-check contents |

## Speed Targets

| Box Type | Target Time | Month 1 | Month 3 | Month 6 |
|----------|-------------|---------|---------|---------|
| Mini Kit | 10 min | 15 min | 10 min | 8 min |
| Standard | 20 min | 40 min | 25 min | 18 min |
| Premium | 30 min | 50 min | 35 min | 25 min |
| Group (6 shirts) | 45 min | 60 min | 40 min | 30 min |

## Daily Station Reset (5 minutes at end of day)

- Count bins; flag any below restock trigger
- Clean heat press / DTG platen
- Empty trash; restock tape, tissue, labels
- Verify tomorrow's orders printed and queued
- Lock label printer in drawer if shared space

## Hiring First Packer

**When:** Month 2 or when weekly orders exceed 20

**Pay structure:** $15/hr or per-box piece rate ($4 Standard, $6 Premium)

**Training:** Run 5 supervised packs using this SOP; sign off on spelling gate

**Tools given:** Printed SOP, bin map photo, order sheet highlighter, spelling checklist
