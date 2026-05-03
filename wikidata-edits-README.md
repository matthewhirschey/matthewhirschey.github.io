---
created: 2026-05-03
status: pending Matt
---

# Wikidata edits — Matt Hirschey (Q37379356)

Wikidata entry already exists at https://www.wikidata.org/wiki/Q37379356.
ORCID, Scopus, employer (Duke), occupation already populated. The
QuickStatements batch in `wikidata-quickstatements.txt` adds the missing
LLM-relevant identity links and bio metadata.

## What the batch adds

| Property | Value | Why |
|---|---|---|
| Den (description) | "American researcher in metabolism and computational biology; director of the Duke Center for Computational Thinking; founder of Heureka Labs" | Replaces bare "researcher" |
| P2002 Twitter username | `matthewhirschey` | Identity resolution |
| P2037 GitHub username | `matthewhirschey` | Identity resolution |
| P1960 Google Scholar ID | `OLG9E-sAAAAJ` | Citation graph linkage |
| P69 educated at | UC Santa Barbara (Q263064) — qualifiers: PhD (Q752297), end Sept 2006 | Bio completeness |
| P69 educated at | University of Vermont (Q1048898) — qualifiers: BS (Q787674), end June 2001 | Bio completeness |
| P101 field of work | metabolism (Q1057) | Subject-area context for LLMs |
| P101 field of work | computational biology (Q177005) | Subject-area context |
| P101 field of work | mitochondrion (Q39572) | Subject-area context |
| P39 position held | associate professor (Q9344260) — qualifiers: employer Duke (Q4119601), start March 2019 | Position |
| P856 official website | https://matthewhirschey.com/ | Adds personal site alongside Duke profile |

Each statement carries an `S854` reference URL so future Wikidata reviewers
see the citation source.

Education facts pulled from Hirschey_CV.qmd:
- PhD Chemistry & Biochemistry, UC Santa Barbara, Sept 2006 (advisor: Alison Butler)
- BS Biological Sciences, University of Vermont, June 2001
- Tenured Associate Professor at Duke since March 2019

## How to run it

1. Go to https://quickstatements.toolforge.org
2. Sign in with a Wikidata / Wikimedia account
   - If you don't have one: https://www.wikidata.org/wiki/Special:CreateAccount
   - Account creation is free, no email verification required, takes ~30 sec
3. Click **New batch** → **V1 commands**
4. Paste the contents of `wikidata-quickstatements.txt`
5. Click **Import V1 commands** then **Run**
6. Each statement executes one at a time; expect ~30 sec total

## Verify before paste

- [ ] Confirm `OLG9E-sAAAAJ` is your Scholar ID (URL: scholar.google.com/citations?user=OLG9E-sAAAAJ)
- [ ] OK with the description text? Change in the file before pasting if not.
- [ ] Want to drop the `foundation.app` link from the site at the same time? (Separate question, see GEO-AUDIT.md.)

## After the batch runs

- [ ] Maude updates `wikidata-edits-README.md` status to "completed YYYY-MM-DD"
- [ ] Maude moves on to next gap in GEO-AUDIT.md (LinkedIn / Bluesky in sameAs, ScholarlyArticle schema for pubs)

## Deferred (manual / later)

- **P18 image** — requires uploading the b&w portrait to Wikimedia Commons with explicit CC license. Separate workflow; defer unless wanted.
- **P166 award received** — pull from CV when convenient; not load-bearing for entity resolution.
- **P800 notable work** — would point to specific paper Q-numbers (e.g., 2011 SIRT3 *Nature* paper). Look up Q-numbers and add later.
- **Wikipedia article** — separate effort, much higher bar.
