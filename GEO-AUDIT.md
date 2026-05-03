---
created: 2026-05-03
completed: 2026-05-03
status: shipped (PR #4)
reference: ~/sage/drafts/2026-05-02-geo-leo-research.md
---

# GEO / LEO Audit — matthewhirschey.com

Generative Engine Optimization audit against Sage's research brief
(`~/sage/drafts/2026-05-02-geo-leo-research.md`). Most recommendations
already shipped Apr 11, 2026. This file tracks the remaining gaps.

## Already shipped

- JSON-LD `Person` schema in `template.html` (worksFor, alumniOf, knowsAbout, sameAs)
- `sameAs` chain — Twitter, Lab, Heureka, DDH, Foundation, ORCID, Scholar, GitHub, Duke Scholars
- `robots.txt` permissive to GPTBot, ClaudeBot, PerplexityBot, Google-Extended, CCBot, Applebot-Extended
- `sitemap.xml`, `llms.txt`, `index.md` (gfm mirror for crawlers)
- Open Graph + Twitter Card + canonical URL + author meta
- Server-rendered (Quarto static; ~17 KB HTML, no JS framework)

## Gaps

### 1. Wikidata entry — Q37379356 ✅
Existing Wikidata entity. Properties (occupation, employer, ORCID, Scopus) were already populated; the parallel agent's `wikidata-quickstatements.txt` batch adds Twitter/GitHub/Scholar/LinkedIn IDs and the UCSB PhD education statement, all referenced to `matthewhirschey.com/`.

- [x] Q-number assigned: Q37379356
- [x] `https://www.wikidata.org/wiki/Q37379356` added to `same_as:` in `index.qmd`
- [x] QuickStatements batch prepared at `wikidata-quickstatements.txt`; Matt to upload via [quickstatements.toolforge.org](https://quickstatements.toolforge.org/) (manual one-time step)
- ~~Wikipedia stub~~ — skipped per audit note (higher effort, secondary)

### 2. `sameAs` additions ✅
- [x] LinkedIn `https://www.linkedin.com/in/matthew-hirschey/` (slug confirmed)
- ~~Bluesky~~ — no active account
- ~~Mastodon~~ — no active account
- [x] `https://www.heurekalabs.org` (blog) added alongside `.co` (company)
- [x] Wikidata Q37379356 added

### 3. `foundation.app` link review ✅
- [x] Dropped — small experiment, no longer active. Removed from `same_as:` and from `misc` bullet.

### 4. ScholarlyArticle schema for publications ✅
- [x] `publications:` YAML array drives both visible markup and JSON-LD from one source (`render-data.lua` `render_publications()`)
- [x] All 16 visible entries carry a publisher DOI (15 from Crossref, 1 supplied by Matt). Visible titles are clickable DOI links (`target="_blank"`, `rel="noopener"`)
- [x] All 16 JSON-LD blocks parse cleanly; `index.html` 28 → 29 KB, under 30 KB cap
- [x] JSON-LD emitted for HTML output only (`FORMAT == "html"` gate); GFM mirror stays clean
- [x] `json_escape()` uses Unicode escapes (`&`, `<`, `>`) so future titles with `&`/`<`/`>` survive cleanly

### 5. Validation pass — partial
- [x] schema.org validator: Person clean (0 errors / 0 warnings) on live site pre-merge; ScholarlyArticle blocks pending live deploy
- [x] Google Rich Results: "no items detected" is expected — Person and ScholarlyArticle aren't rich-result-eligible types in Google's catalog. "Crawled successfully" is the only positive signal available
- [ ] Re-run schema.org validator on the deployed site after PR merge (URL mode) to confirm all 16 ScholarlyArticle entries register

### 6. `llms.txt` enrichment ✅
- [x] `## Recent writing` section — three heurekalabs.org essays
- [x] `## Selected publications` section — top 7 papers with publisher DOIs
- [x] LinkedIn + Wikidata added to `## About`
- [x] All existing links re-resolved

## Order of operations

1. **Wikidata** (#1) — biggest unlock, gates other improvements
2. **sameAs additions** (#2 + #3) — 15-min edit once Wikidata Q exists
3. **`llms.txt` enrichment** (#6) — quick win
4. **ScholarlyArticle schema** (#4) — biggest code change, save for last
5. **Validation** (#5) — final pass, gates "ship"

## Replicating to other sites

This audit pattern applies to the other Hirschey-aligned web properties
(Hirschey Lab, Heureka Labs, eventually CCT / Open Academy). Once
matthewhirschey.com is done, copy this file as a template per site —
the gap shape will be different but the structure transfers.

Pattern:
1. Pull current state of `<head>`, schema, robots, llms.txt, sitemap
2. Diff against Sage brief Top 10
3. Document gaps + order of operations
4. Execute
