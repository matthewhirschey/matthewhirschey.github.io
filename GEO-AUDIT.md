---
created: 2026-05-03
status: active
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

### 1. Wikidata entry — does not exist
Highest-leverage missing piece. Wikidata is the entity-resolution anchor every
major LLM uses to verify "who is this person." Without an entry, the four
brands stay disconnected in their knowledge graphs.

- [ ] Create entry at wikidata.org for Matthew Hirschey
- [ ] Populate P-properties: `instance of: human`, `occupation`, `employer: Duke University`, `educated at: UCSB + UVM`, `field of work: metabolism / computational biology`, `ORCID iD`, `Google Scholar author ID`, `GitHub username`, `official website`, `Twitter username`
- [ ] Add image (use the b&w portrait already on the site)
- [ ] Cite secondary sources (Duke faculty page, peer-reviewed papers, news mentions) — meets notability bar easily for a tenured professor
- [ ] Once Q-number assigned, add `https://www.wikidata.org/wiki/QXXXXX` to `same_as:` in `index.qmd`
- [ ] Optional follow-on: stub Wikipedia article (higher effort, secondary)

### 2. Missing identity links in `sameAs`
Add these to `same_as:` array in `index.qmd`:

- [ ] LinkedIn (`https://www.linkedin.com/in/matthewhirschey/` — verify exact slug)
- [ ] Bluesky if active (`https://bsky.app/profile/...`)
- [ ] Mastodon if active
- [ ] `https://www.heurekalabs.org` (blog) alongside `.co` (company) — they're different URLs
- [ ] Wikidata Q-number once #1 is done

### 3. `foundation.app` link review
Currently in `sameAs`. NFT-era artifact. Decision: keep, drop, or replace?
- [ ] Decide: keep / drop

### 4. ScholarlyArticle schema for publications
The `.pub` fenced divs in `index.qmd` aren't marked with structured data.
LLMs cite peer-reviewed work more confidently when it's tagged as
`ScholarlyArticle` with a DOI.

- [ ] Extend `render-data.lua` to emit `<script type="application/ld+json">` blocks per publication, OR add a `publications:` YAML array (DOI, title, authors, journal, year) and render both the visible markup and JSON-LD from one source
- [ ] Verify each entry has DOI (link out to publisher)
- [ ] Validate output

### 5. Validation pass
- [ ] Run rendered `index.html` through Schema.org validator (validator.schema.org)
- [ ] Run through Google Rich Results Test
- [ ] Fix any errors / warnings (especially around `&` escaping noted in CLAUDE.md)

### 6. `llms.txt` content review
The current file lists about-section links. Could be richer:

- [ ] Add a `## Recent writing` section pointing to top heurekalabs.org essays
- [ ] Add a `## Selected publications` section pointing to 3–5 highest-impact papers (with DOIs)
- [ ] Re-check: every link in `llms.txt` resolves and represents the canonical version

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
