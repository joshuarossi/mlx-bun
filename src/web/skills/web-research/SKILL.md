---
name: web-research
description: Use when the user asks you to research something, do a deep dive, fact-check a claim, compare options, or answer a question that needs current, accurate, real-world information ("what's the latest on…", prices, releases, news, specs). Gives a rigorous workflow for searching the web, reading primary sources, cross-checking claims, and answering with citations.
---

# Web Research

A workflow for answering questions that need current, accurate, real-world
information, using the `web_search` and `web_fetch` tools. The goal is a
trustworthy, well-sourced answer — not a guess dressed up as one.

## When to use this

- The answer depends on current events, recent releases, prices, versions,
  or anything that changes over time.
- The user wants a thorough or authoritative answer, or asks for sources.
- A specific claim needs verifying, or you would otherwise be speculating.

## Workflow

1. **Plan.** Restate the question in your own words and list the 2–4 concrete
   things you need to find out. This keeps the searches focused.
2. **Search broadly.** Call `web_search` with a few focused queries — one idea
   per query — rather than a single vague one. Vary the wording if the first
   results are weak.
3. **Read the best sources.** Use `web_fetch` to actually read the most
   relevant results. Prefer primary sources (official docs, the original
   announcement, the paper, the vendor's own page) over blogs and aggregators.
   Read at least two or three independent sources.
4. **Cross-check.** Confirm each key fact appears in more than one independent
   source. Where sources disagree, surface the disagreement instead of picking
   one silently.
5. **Answer.** Lead with a direct answer, then the supporting detail. Cite
   every nontrivial claim with a Markdown link to a page you actually fetched.
   Separate what's well-supported from what's uncertain.

## Quality rules

- Check publication dates; for fast-moving topics, prefer recent sources.
- Never cite a page you didn't fetch, and never invent quotes, numbers, or URLs.
- Quote sparingly and exactly.
- If the sources are thin or conflicting, say so plainly — don't overstate
  confidence to sound complete.
- If a search returns nothing useful, try different terms before giving up.
