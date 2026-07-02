# Web UI pass — ranked fix list (2026-07-01 audit)

Read-only audit of every web surface against the current server contract:
`src/web/app.html` (unified SPA: chat / quantize / finetune / dataset /
status+library / routes), `src/assets/curve-designer.html` (/curves),
`src/pi-web.ts` (WS chat bridge), `src/server.ts` routes, plus the dead
`src/status-page.html`. Method: diffed every fetch/WS consumer in the pages
against the actual handler shapes in `server.ts`, `src/jobs/types.ts`,
`src/train/{job,trainer}.ts`, `src/quantize/job.ts`, `src/download.ts`,
`src/registry.ts`, `src/model/support.ts`.

**Live click-through was skipped deliberately**: GPU-loading test suites
(`bun test tests/server.test.ts …`, loads MiniCPM5) were running for the whole
audit window, and starting a second model server would have contended with
them. Every finding below is source-verified on both sides of the contract.

Port sweep: no stale `8090` or hardcoded URLs remain in any html/js.
`curve-designer.html:92` falls back to `http://localhost:8080` (matches the
new default) and uses `location.origin` when served at `/curves`. ✓

---

## WRONG (bugs — fix first)

1. **Fine-tune live stats never show LR or tok/s — metric field-name mismatch.**
   `src/web/app.html:2317-2318` reads `e.lr` / `e.tps`, but the trainer emits
   `learning_rate` / `tokens_per_sec` (`src/train/trainer.ts:559-560`, same at
   :724-727 and :966-969; contract comment in `src/jobs/types.ts:23`). The
   "learning rate" and "tok/s" chart stats stay `—` for the entire run.
   Also update the protocol doc-comment at `app.html:1089` (`lr?`, `tps?`).
   **Fix:** read `e.learning_rate` and `e.tokens_per_sec`.

2. **Chat queue bar renders arrays as strings and empty tags.**
   `pi-web.ts:183` sends `queue_update` with `steering: readonly string[]` and
   `followUp: readonly string[]` (arrays). `app.html:1683-1684` does
   `if (q.steering) … esc(String(q.steering))` — an empty array is truthy, so
   every `queue_update` renders empty `steering:`/`queued:` pills, and multiple
   queued messages render comma-joined.
   **Fix:** guard with `.length` and render `q.followUp.map(...)` (or
   `q.steering[q.steering.length-1]`).

3. **Library table loads exactly once per app lifetime — new quants never appear.**
   `app.html:2603` gates `loadLibrary()`/`loadFit()` behind `fitLoaded`, which
   is never reset. The server explicitly invalidates its 30 s `/library` cache
   when a quantize job completes so "the next poll rescans and shows it"
   (`src/server.ts:2510-2513`) — but the UI never re-polls. A model quantized,
   downloaded, or gc'd mid-session never shows until a full page reload.
   **Fix:** refresh the library on its own interval (e.g. every 15 s inside
   `tick()`), and force one refresh when a quantize job reaches `done`.

4. **Adapter mount failure toasts "[object Object]".**
   `POST /v1/adapters` errors use the OpenAI envelope `{error:{message}}`
   (`src/server.ts:1600`), and the `api()` helper (`app.html:1080`) keeps
   `data.error` as that object; `onSelectAdapter` (`app.html:1908-1909`) then
   string-concatenates it. Any mount failure reads
   `adapter: [object Object]`.
   **Fix:** in `api()`, unwrap
   `data.error && typeof data.error === "object" ? data.error.message : …`.

5. **Quantize inspect result parsing targets a response shape the server never sends.**
   `inspectModel` returns `support: boolean` (`src/quantize/job.ts:101`), but
   `app.html:2135-2140` checks `d.support === "supported" | "ok" | "untested"`
   (all dead branches) and, when `support` is false, prints
   `esc(d.support || "unknown architecture")` → always "unknown architecture"
   even when `arch` was resolved. `size_gb` is also rendered raw (unrounded
   float, and `0` when a direct path bypasses the registry).
   **Fix:** treat `support` as boolean; show `arch` + "not quantizable" on
   false; `(+d.size_gb).toFixed(2)` and hide when 0.

6. **Stale vision claim in the chat attach path.**
   `app.html:1848`: "This model can't see images — switch to the **12B** for
   vision." SigLIP landed: e2b/e4b/26B/31B are vision-capable too
   (`src/registry.ts:213-219` `visionCapable`), so the 12B-only advice is
   wrong.
   **Fix:** model-agnostic copy: "This model can't see images — serve a
   vision-capable model (Gemma vision builds show a *vision* tag in the
   Library)."

---

## MISSING (current capabilities the UI doesn't expose)

7. **`sft_scope` absent from the fine-tune form.**
   The finetune job accepts `sft_scope: "full" | "response"` and validates it
   at submit (`src/train/job.ts:54,74-76`); default is now `"full"`
   (paper/TRL-faithful, commit d32fe32). The ORPO panel
   (`app.html:791-800`) has λ + schedule but no scope control, and
   `collectHP()` (`app.html:2276-2289`) never sends it.
   **Fix:** add a segmented control (full · response) to `#f-orpo-extra` with
   a hint ("full = paper/TRL chosen-NLL over the whole sequence; response =
   pre-2026-07 response-only"), include `sft_scope` in `collectHP()` when
   method === "orpo".

8. **`min_p` / `xtc_probability` / `xtc_threshold` / `logprobs` not in any request-builder UI.**
   Server supports them per-request (`src/server.ts:280-304`, wired at
   :1138-1141). The chat sampling popover (`app.html:592-613`) only has
   temperature/top_p/top_k — and the whole chain is width-limited: the
   `set_sampling` WS frame (`pi-web.ts:160`), `SamplingOverrides`
   (`pi-web.ts:408-412`), and `injectSampling` (`pi-web.ts:420-440`) all only
   carry those three fields.
   **Fix (scoped):** add `min_p` (slider 0–0.5) end-to-end: popover row →
   `set_sampling` frame → `SamplingOverrides.min_p` → `injectSampling`. XTC and
   logprobs are power-user/API features; document rather than add sliders.

9. **No gc/reclaim story in Library or Downloads.**
   `mlx-bun gc` exists (CLI `src/cli.ts:1100`; planner
   `src/registry.ts:375-455` `planGc`/`executeGc`) and the download path
   prints "gc reclaims ~X GB" (`cli.ts:1015-1018`) — but the web Library shows
   superseded revisions' disk cost with no affordance. **Needs a new server
   endpoint first** (e.g. `GET /api/gc/plan`, `POST /api/gc/execute {yes}`),
   then a Library footer line: "N superseded snapshots · reclaim X GB —
   [Clean up]". (Separate from the listCanonical wiring below, but pairs
   naturally with it: dedupe hides the stale revisions, gc deletes them.)

10. **Other accepted-but-hidden finetune/quantize knobs** (lower priority):
    `grad_accumulation_steps`, `warm_start_adapter`, adapter naming (submit
    always writes `adapter-<timestamp>`, `src/server.ts:2529-2530`) on the
    finetune form; `reference`, `calibration_mix`, `n_calibration`
    (`src/server.ts:2460-2461`) on the mixed-bpw quantize step. Add an
    "Advanced" disclosure rather than more top-level fields.

---

## BLOCKED on the queued server.ts listCanonical / visionCapable / tier wiring

The functions exist and are tested (`Registry.listCanonical`
`src/registry.ts:181`, `visionCapable` :217, `supportTier`
`src/model/support.ts:53`) but the server still serves the old view. UI
consumption points to touch when the wiring lands:

11. **Revision duplicates in /library and /v1/models.**
    `src/server.ts:1263` (`/library`) and :1491 (`/v1/models`) iterate
    `reg.list()` — one row per cached snapshot revision. Both should use
    `reg.listCanonical()`. UI needs no change; the Library table and every
    /v1/models-driven picker (external pi, CLI) currently show dupes.

12. **`vision` flag understates capability.**
    `src/server.ts:1278` sends `vision: m.hasVisionSidecar`, which misses the
    12B's encoder-free `gemma4_unified_vision` (config-declared, no sidecar
    file). Should be `visionCapable(m)`. UI consumption at `app.html:2663`
    then needs no change.

13. **`supported` is a boolean; tiers are invisible.**
    `src/server.ts:1264` sends `supported: isSupportedModelRecord(...)`.
    Generic Tier-0 models (universal-dense descriptors) now count as
    supported — correct — but the Library can't distinguish "targeted
    (L2/L3 paths)" from "generic (L1 monolith only)". When the server sends
    `tier: "targeted" | "generic" | null` (from `supportTier`), update:
    - `app.html:2659` status cell: keep `unsupported (model_type)` for null;
      add a dim "generic" badge for Tier-0 rows.
    - Keep `supported` as a boolean alongside `tier` for one release so the
      UI change can land independently.

---

## CONFUSING / polish

14. **Sampling popover "recommended" values are hardcoded to MiniCPM5.**
    `app.html:1824-1825` (`SAMP_REC {topP:.95, topK:0}`, `recTemp()` 0.9/0.7)
    claims to "mirror server toOptions defaultTemp", but the server resolves
    defaults from each model's `generation_config.json`
    (`src/server.ts:1120-1132`). For any other served model the dimmed "auto"
    readouts lie. Fix: surface `genDefaults` (e.g. on the `ready` frame or
    `/v1/models` extras) and seed the popover from it.

15. **Adapter dropdown goes stale after training.**
    `refreshAdapters()` runs only at chat init and on `ready` frames
    (`app.html:1789-1792, 2037`). An adapter trained in the Fine-tune tab
    doesn't appear until reconnect/reload. Refresh on finetune `done` and on
    chat `enter()`. Also escape the interpolation at `app.html:1897-1898`
    (`a.id`/`a.path` go into HTML unescaped).

16. **Dead file: `src/status-page.html` (497 lines) + `scripts/status-page-stub.ts`.**
    Nothing imports it since the SPA absorbed status (only
    `scripts/status-page-stub.ts` references it). Delete both, or move the
    stub note into the SPA docs.

17. **Routes tab breaks in the compiled binary.**
    `#/routes` iframes `/dag`, which `readFileSync`s
    `../docs/dag/training-inference-map.html` (`src/server.ts:1231`) — absent
    outside the repo checkout, so the tab shows a bare 404 string. Either
    embed the artifact like app.html, or hide the tab when `/dag` 404s.

18. **CLI banner vs landing route.** `src/cli.ts:64` says "status page at
    http://localhost:8080/", but `/` lands on `#/chat`. Say "web app" or point
    at `/#/status`.

19. **Curves nav tab never highlights.** It's a full-page `href="/curves"`
    (`app.html:520`), outside the hash router, so the active-tab logic
    (`app.html:1390`) can't mark it. Cosmetic; acceptable, but a
    `aria-current` on the curve page's back-link side would be tidier.

20. **Library "too big" rows hide the useful number.** `app.html:2665-2666`
    shows max context/decode only when `a.fits` (fit solved at 8192); a model
    that fits at a smaller context shows `—`. Show `max_safe_context`
    whenever it's > 0.

21. **Downloads visibility is per-process.** `/downloads` reads a
    process-local tracker (`src/download.ts:276-279`) — a `mlx-bun get` in
    another terminal is invisible to the nav pill/status card. Note in the UI
    copy or leave; fixing needs a shared store.

---

## Suggested landing order

1. Bugs #1–#6 (one UI-only PR; no server changes).
2. #7 sft_scope + #15 adapter refresh (small, independent).
3. The queued server wiring (#11–#13) as its own PR: `listCanonical` +
   `visionCapable` + `tier` in `/library` and `/v1/models`, then the
   one-line UI badge.
4. #8 min_p end-to-end, #9 gc endpoint + Library affordance.
5. Cleanup: #16 dead files, #17 routes tab, #14 genDefaults surfacing.
