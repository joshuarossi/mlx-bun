# Website + README pass — audit findings and fix plan (2026-07-01)

Scope: the `website/` Astro subproject (mlx-bun.dev), `README.md`, and the
`docs/reference/` sources that feed both. Audited read-only against current
main **and against the published `v0.0.8` tag** (what installers actually
get). Every claim below was verified in source (`git show v0.0.8:…` for
release attribution), not doc-vs-doc.

## 0. The one decision that gates everything

**The site and README already document v0.0.9 behavior.** The published
v0.0.8 binary serves on **port 8090, bound to all interfaces**; main (and
every doc: README, quickstart, http-api, the synced server-config page)
says **8080 + loopback**. A fresh `brew install` user today follows the
quickstart and every curl example fails. The five auto-synced reference
pages likewise already describe `--max-tokens`, logprobs, `--sft-scope`,
and `/v1/completions` — all post-tag.

Two coherent options:

- **(A) Recommended: cut v0.0.9, then deploy the site.** All docs become
  true simultaneously; nothing below needs version annotations. The
  release-notes draft already exists (`docs/planning/release-notes-v0.0.9.md`).
- **(B)** If v0.0.9 is not imminent: hold site deploys, and treat every
  item marked *v0.0.9* below as blocked. (Reverting docs to 8090 is churn
  for nothing — don't.)

The rest of this plan assumes (A); each item is still marked
**[safe-now]** (true for v0.0.8 users too) or **[v0.0.9]** (true only
after release).

## 1. Mechanism: how site content is produced

- **Generated (cannot drift):** 5 pages built from `docs/reference/*.md`
  by `website/scripts/sync-reference-docs.mjs`, run on every
  dev/build via the `astro:config:setup` hook in `astro.config.mjs`:
  `server-api.md`, `server-config.md`, `training.md` → `reference/`;
  `library-api.md`, `embedding.md` → `guides/`. Generated copies are
  gitignored. This works well — verified accurate against main.
- **Hand-written (tracked, CAN silently drift, and did):** `index.mdx`,
  `getting-started/{introduction,installation,quickstart,models}`,
  `guides/{http-api,troubleshooting}`, `reference/cli.md`, `about/*` (4).
  The three that drifted are exactly the ones duplicating CLI/model facts:
  `reference/cli.md`, `getting-started/models.md`, `guides/http-api.md`.
- **Not synced at all:** `docs/reference/{memory,models,orpo-quickstart,distribution}.md`.
  The first three are user-facing and site-worthy; distribution.md is
  maintainer-ops, keep repo-only.

### Mechanism bugs

1. **Deploy trigger misses the source docs.** `.github/workflows/deploy-site.yml`
   triggers only on `paths: website/**`. Edits to `docs/reference/*.md`
   alone never redeploy — the "cannot drift" pages drift *in production*
   until the next unrelated website commit. **Fix [safe-now]:** add
   `docs/reference/**` to the paths filter.
2. **"Edit page" links on the 5 generated pages 404.** Starlight's global
   `editLink.baseUrl` points at `website/src/content/docs/…`, but those
   files are gitignored, so GitHub 404s. **Fix [safe-now]:** have the sync
   script inject per-page `editUrl:` frontmatter pointing at the real
   source (`docs/reference/<file>.md`).
3. **Local dev/build needs Node ≥ 22.12** (Astro 6). The machine default
   is nvm Node 18 → `bun run build` fails locally; CI uses Node 22 and is
   fine. **Fix [safe-now]:** add `"engines": { "node": ">=22.12.0" }` to
   `website/package.json` and a one-liner in `website/README.md`
   (`nvm use 22` or `bunx --bun astro build`).

### Build health (measured)

- Build: **green** — 18 pages, pagefind index, sitemap (built with Node 22 semantics via `bunx --bun astro build`).
- Internal links: **all 17 unique internal hrefs resolve** to built routes.
- GitHub `blob/main` links (22 unique): **all targets exist** in the repo.
- Assets: `public/{CNAME,install.sh,favicon.svg}` present.
- The only broken-link class is the editLink bug above.

## 2. WRONG (fix first — actively misleads)

| # | Where | Claim | Truth | Gate |
|---|---|---|---|---|
| W1 | Site quickstart/installation/index-hero, README (lines 96/108/208/235/286), synced server-config | server on `localhost:8080`, loopback | **v0.0.8 = port 8090, all interfaces**; 8080+loopback is post-tag (8ee691d) | **[v0.0.9]** — resolves itself under option (A) |
| W2 | `website/…/reference/cli.md:29` | `--no-kv-quant` / `--kv-bits <n>` | Never existed. Real flag: `--kv-quant config\|off\|4\|8` | [safe-now] |
| W3 | `website/…/reference/cli.md:30` | `--adapter id=dir` | Syntax is `--adapter <dir>` | [safe-now] |
| W4 | `README.md:304` | "Published to npm as `mlx-bun` (current: 0.0.4)" | 0.0.8 | [safe-now] |
| W5 | `getting-started/models.md:19` + `introduction.md:33` | "Currently MiniCPM5 plus the Gemma-4 quants… Qwen 3.x is next on the roadmap" | **Qwen3.5-4B is supported in v0.0.8** (support.ts at tag) — and `about/comparison.md:39` already says so; the site contradicts itself | [safe-now] |
| W6 | `README.md:39`, `installation.mdx:22` | pin example `MLX_BUN_VERSION=v0.0.4` | Use `v0.0.8` (or drop the pinned example) | [safe-now] |

## 3. STALE (true once, now behind)

- S1 `getting-started/models.md` table: add the Qwen3.5-4B row (copy the
  README's row: 3.1 GB, 8 GB, thinking + tool calling). [safe-now]
- S2 `guides/http-api.md:85-89` endpoint list: `/stats`, `/fit`,
  `/library`, `/downloads` existed at v0.0.8 and are undocumented
  [safe-now]; `/v1/completions`, `/v1/embeddings`, `/health`,
  logprobs/top_logprobs are **[v0.0.9]**.
- S3 `about/benchmarks.md:6`: "mlx-optiq 0.2.1" — oracle venv now runs
  0.2.4; also "clean-machine re-measure is pending" (line 35) — refresh or
  date-stamp when the re-measure lands. [safe-now, low priority]
- S4 README "Status" section: reflect the v0.0.9 wave (CI gate now exists,
  Tier-0 generics, mlx-lm tool parity) — **[v0.0.9]**.

## 4. MISSING (goals with no page)

- M1 **Memory system — goal 5 — has ZERO website presence.** The
  README sells it; the site never mentions it. `docs/reference/memory.md`
  is accurate and site-worthy. **Fix:** add to the sync MAP →
  `guides/memory.md` ("Personal memory") + a home-page feature card + a
  sidebar entry. Read path (init/status/open/search/agent tools) shipped
  in v0.0.8 [safe-now]; `memory synthesize` as a real pipeline is
  **[v0.0.9]** (f7dad8f is post-tag) — under option (A) publish the whole
  page at once.
- M2 **CLI reference covers 7 of ~21 verbs.** Missing and in v0.0.8:
  `gen/generate`, `bench`, `train`, `train-watch`, `memory`, `pi`, `help`
  [safe-now]. Missing and post-tag: `embed`, `gc`, `fuse`, `convert`,
  `upload`, `perplexity`, `setup` alias **[v0.0.9]**. **Structural fix:**
  stop hand-writing it — create `docs/reference/cli.md` as the tracked
  source (or generate from `printHelp`) and add it to the sync MAP, so the
  CLI page can never drift again.
- M3 **Model management** (`get`/`scan`/`ls`/`gc`, cache layout, gc safety
  rails): `docs/reference/models.md` is accurate + site-worthy → sync to
  `guides/model-management.md`. gc verb is **[v0.0.9]**; the rest safe-now.
- M4 **Drop-in mlx-lm replacement — goal 1 — has no page.** It's v0.0.9's
  headline (mlx_lm.server endpoint/flag/sampler/logprobs parity, same
  port/host defaults, `fuse`/`convert`/`perplexity`/`upload` tool parity).
  **Fix [v0.0.9]:** new `guides/drop-in-mlx-lm.md` — "stop
  `mlx_lm.server`, start `mlx-bun serve`, same curl works" with the
  parity table and the deliberately-not-ported list.
- M5 **Tier-0 generic models** (UniversalDense, 11 archs, L1-gated,
  bit-exact goldens for llama/qwen2/gemma2): reframes the scope story from
  "a few models" to "runs what mlx-lm runs; *optimizes* the targets".
  Rewrite `models.md` around the targeted-vs-generic tier split (`ls`
  already labels it). **[v0.0.9]**.
- M6 **The lab — goal 6 — is invisible.** ORPO training (orpo-quickstart
  is accurate + site-worthy), DSpark speculative decoding, the curve
  designer (`/curves` UI ships in v0.0.8!), diffusion-gemma, the
  train-watch dashboard. **Fix:** new `about/lab.md` (or top-level "The
  lab") presenting these as the experimental playground with GitHub links
  into docs/design + docs/investigations; sync orpo-quickstart →
  `guides/fine-tuning-quickstart.md`. Mostly [safe-now] (frame as
  experimental); `--sft-scope` mention is [v0.0.9].
- M7 **README link coverage:** memory paragraphs (137–145) should link
  `docs/reference/memory.md` + `docs/design/memory-synthesis.md`; the
  model table (155) should link `docs/reference/models.md`; nothing links
  to **mlx-bun.dev** anywhere except install.sh — add a "Docs:
  https://mlx-bun.dev" line at the top. [safe-now]

## 5. Structure / information architecture

### Website — proposed sidebar (new items marked)

```
Getting started
  Introduction · Installation · Quickstart · Choosing a model (rewrite: tiers, M5)
Guides
  The HTTP API
  Drop-in for mlx-lm            ← NEW (M4, v0.0.9)
  Personal memory               ← NEW (M1, synced from docs/reference/memory.md)
  Model management              ← NEW (M3, synced from docs/reference/models.md)
  Using the library · Embedding in a Mac app
  Fine-tuning quickstart        ← NEW (M6, synced from orpo-quickstart.md)
  Troubleshooting
Reference
  CLI (→ synced, M2) · Server API · Server configuration · Training & fine-tuning
About
  Why mlx-bun · How it compares · Benchmarks · Correctness
  The lab                       ← NEW (M6)
```

### Six-goals legibility scorecard (today → after)

| Goal | Today | After |
|---|---|---|
| 1 Drop-in mlx-lm replacement | implicit ("OpenAI-compatible") | M4 page + home card names mlx_lm.server explicitly |
| 2 JS library / Mac apps | ✅ library + embedding guides | unchanged (already good) |
| 3 Memory/quality/speed | ✅ benchmarks + correctness + fit | S3 refresh |
| 4 One command <60s, 4 paths | ✅ home hero + installation | W1 port fix is the blocker |
| 5 Memory showcase | ❌ absent | M1 guide + home feature card |
| 6 Playground | ❌ absent | M6 lab page + home card |

- **Home page:** the 6 feature cards cover goals 1–4 twice and 5–6 never.
  Swap/add two cards: "Personal memory" (goal 5) and "The lab" (goal 6);
  make the Protocols card say "drop-in for mlx_lm.server" (goal 1).
- **Reading order** is otherwise sound: hero → install → quickstart →
  guides works; introduction.md and why.md duplicate two paragraphs
  verbatim — acceptable, but keep them in sync or have intro link out.

### README

- The 60-second promise is buried at line 92 inside the *fourth* install
  path. Move it into the opening: "one command, chatting in under a
  minute" as the first bold claim, install one-liner immediately after —
  matching the website hero (they should tell the same story; today the
  README leads with the product-bet essay).
- Add the six goals as an explicit bulleted frame (the "What mlx-bun is"
  section at line 120 is close — reorder it to map 1:1 and give the memory
  system and the lab their own H2s with doc links).
- Add the mlx-bun.dev docs link at the top (M7).
- Keep README ⊆ website: README states, website explains — every README
  section should end with a link to the corresponding site page once M1–M6
  land.

## 6. Execution order

1. **[safe-now, no release needed]** W2–W6, S1–S3, M7, mechanism fixes
   (deploy paths filter, editUrl injection, engines field). Note: do NOT
   deploy the site after these until step 2, because the synced pages
   already carry v0.0.9 content (W1).
2. **Josh: cut v0.0.9** (release-notes draft exists).
3. **[with v0.0.9]** W1 becomes true; land M1–M6 + S4 + README
   restructure; deploy once. New synced pages = add 4 entries to the
   sync-script MAP (cli, memory, models→model-management,
   orpo-quickstart→fine-tuning-quickstart) + sidebar entries + link
   rewrites for the new routes.

## Appendix: release-attribution ground truth (verified via `git show v0.0.8:`)

- **In v0.0.8:** verbs get/scan/ls/fit/serve/gen/bench/evals/pi/harness/
  train/train-watch/memory(read-path); Qwen3.5 + DiffusionGemma support;
  `/curves`, `/dag`, `/stats`, `/fit`, `/library`, `/downloads`, chat UI;
  port **8090**, host **all interfaces**.
- **Post-tag (v0.0.9):** port 8080 + loopback, `--temp`/`--max-tokens`,
  `/v1/completions`, `/health`, `/v1/embeddings`, logprobs/top_logprobs,
  sampler parity (min_p/XTC/logit_bias/penalties), verbs
  embed/gc/fuse/convert/perplexity/upload, `--sft-scope`, Tier-0
  UniversalDense (11 archs, L1 goldens), memory synthesize (real
  pipeline), registry dedupe, CI gate, `--l2` tier-contract fix.
