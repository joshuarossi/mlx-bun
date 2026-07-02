# pi integration review — internal embeds + `harness pi` (2026-07-01)

Read-only audit of the pi surface: `mlx-bun pi` (src/pi-terminal.ts, in-process
InteractiveMode), the shared provider wiring (src/pi-provider.ts), the web
embed (src/pi-web.ts), `mlx-bun harness pi` (src/harness-pi.ts), and the docs
that describe them. Every claim below was verified in the current source
(post-8ee691d, working tree of 2026-07-01); the localhost/loopback behavior was
verified empirically with Bun on this machine.

Stale-memory corrections first (priors that are NO LONGER true):
- `harness pi` does **not** write `~/.pi/agent/models.json` — it generates a
  self-contained extension at `~/.pi/agent/extensions/mlx-bun-provider.ts`
  that calls `pi.registerProvider()` with live `/v1/models` discovery.
- Tool-call parsing is **not** Gemma-only anymore: src/tool-call.ts also parses
  OpenAI-JSON `<tool_call>`, Qwen `<function=name><parameter=…>`, and MiniCPM5
  `<function name=…><param name=…>` from decoded text (buffered-text mode).
- The old `by_bits`/bitsMap and double-BOS issues are fixed and stayed fixed.

## Ranked fix list

### 1. HIGH — Web chat advertises memory tools it filtered out
`src/pi-web.ts:568` passes `tools: [...WELCOME_TOOLS]` (= `["read","web_search"]`,
line 68) to `createAgentSessionFromServices`, but `src/pi-web.ts:534` appends
`surface.memoryHint` to the system prompt and `surface.skillPaths` includes the
bundled `memory` skill (surface built at :528 with memory auto-detect). pi
treats the `tools` list as an allowlist, so when a vault exists the prompt and
skill instruct the model to call `memory_resolve` / `memory_read` /
`memory_section` — tools pi filtered out of the session. Every such call fails.
The intent that they be reachable is visible at `src/pi-web.ts:57`
(`READ_ONLY_TOOLS` already auto-allows `MEMORY_TOOL_NAMES`/`REFERENCE_TOOL_NAMES`,
imported at :47). The terminal embed does this correctly
(`src/pi-terminal.ts:157` uses `surface.tools`).
**Fix (pi-web.ts:568):**
`tools: [...WELCOME_TOOLS, ...(surface.memoryEnabled ? [...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES] : [])]`
— or, if the 1B welcome assistant must stay two-tool, build the surface with
`memory: "off"` so the hint and skill disappear too. Add a pi-web test either
way (tests/pi-web.test.ts has no memory coverage today).

### 2. HIGH — `harness pi` maps EVERY /v1/models row to id `"local"` (duplicate models)
`/v1/models` now returns the served model FIRST **plus every other servable
registry model** (src/server.ts:1479–1499). Both consumers still assume the old
single-entry shape:
- `src/harness-pi.ts:76–81` (`fetchServerModels`) maps all rows;
- the generated extension (`renderPiExtension`, src/harness-pi.ts:116–125) and
  the baked fallback (`modelEntry`, :140–151) register one pi model per row,
  **all with id `local`** — N duplicate ids, N−1 of which name models the
  single-model server is not actually serving.
Side effects: `installPiExtension`'s `bakedModels` and the CLI's
"server live · …" line print the whole registry; `src/cli.ts:1615`
("reusing running server at … (…)") lists every downloaded model as if served.
`tests/harness-pi.test.ts` stubs a single-row /v1/models, so this is untested.
**Fix:** in `fetchServerModels`, keep only the served entry — the first row is
the served model and is the only one carrying the capability extras
(`context_window`, `reasoning`); e.g. `body.data?.[0]` (or filter rows that
have `context_window`). Same filter inside the generated extension's live
fetch. Update cli.ts:1615/1668 to label `models[0]` as served. Extend the
harness test with a multi-row stub.

### 3. HIGH — Tier-0 generics (and plain Qwen3 chat) get Gemma's token sentinels
`toolStreamMode` (src/server.ts:1175–1183) returns `"gemma-sentinel"` for every
model that isn't MiniCPM5/Qwen3.5 — including the new universal-dense generics
(llama, qwen2, qwen3, gemma1/2, phi3, olmo2, glm4, granite, starcoder2,
smollm3 — src/model/universal/archs.ts, served via src/model/factory.ts:42–45)
and plain Qwen3. In that mode `ToolAwareStream.push` (src/server.ts:500–509)
unconditionally interprets token ids 48/49/100/101 as tool/channel sentinels.
Those ids are Gemma-4 special tokens (src/tool-call.ts:9–23); on any other
tokenizer they're ordinary low-id vocab entries, so a generic model emitting
one silently reroutes all subsequent output into a phantom tool segment or
"reasoning". It also means generics never reach `parseGeneratedToolCalls`
(buffered-text), so tool calling is broken for them — and pi always sends
tools, and `mlx-bun pi -q <generic>` is a supported path now.
**Fix (src/server.ts:1180–1182):** make gemma-sentinel the *family-gated*
branch, not the default:
```ts
if (ctx.model.config.modelType.startsWith("gemma4")) return "gemma-sentinel";
return tools?.length ? "buffered-text" : "plain";
```
(`ctx.template.thinkingFormat === "gemma-channel"` is an alternative key, but
DiffusionGemma forces it null while still being gemma-family, so prefer
modelType.) Buffered-text already handles the OpenAI-JSON `<tool_call>` shape
most generic templates emit; models whose format isn't covered fail soft
(markup stays in content) instead of corrupting the stream.

### 4. MEDIUM — vision capability never reaches the pi terminal or external pi
`/v1/models` doesn't advertise vision (src/server.ts:1479–1485: only
`context_window` + `reasoning`), `RunEmbeddedPiOptions` has no `vision` field
and `src/cli.ts:1670` passes none, so `mlx-bun pi` on gemma-4-e4b — the
*default* model, vision-capable — registers `input: ["text"]`
(src/pi-provider.ts:100) and images are unusable in the TUI. The harness
extension is hardcoded `input: ["text"]` too (src/harness-pi.ts:121, :146).
Only pi-web wires it (src/pi-web.ts:491–495, from `ctx.vision || ctx.loadVision`
via createServer). The `input` flag MUST match the real model (pi-ai
content-parts vs string serialization — pi-provider.ts:44–49), so this needs
the real signal, not a default.
**Fix:** add `vision: !!(ctx.vision || ctx.loadVision)` to the served entry in
/v1/models; carry it through `ServerModel`/`fetchServerModels`,
`renderPiExtension`/`modelEntry` (`input: m.vision ? ["text","image"] : ["text"]`),
`RunEmbeddedPiOptions`, and the cli `pi` case.

### 5. MEDIUM — harness extension drifted from buildPiProvider on compat flags
The internal provider sets `compat: { supportsDeveloperRole: false, … }`
(src/pi-provider.ts:89–92); the generated extension sets only `thinkingFormat`
for reasoning models (src/harness-pi.ts:120, :145). Currently masked because
the server remaps `developer` → `system` (src/server.ts:743–760), but the two
paths are documented as "kept aligned" (pi-provider.ts:20–22, harness-pi.ts
header) and have drifted. **Fix:** emit the same
`supportsDeveloperRole: false` block in `renderPiExtension`/`modelEntry`.

### 6. MEDIUM — `memory_status` tells the built-in agent synthesis doesn't exist
`src/memory/tools.ts:571–572` hardcodes
`"last synthesis: not available yet (M1 synthesis is stubbed)"` and
`"synthesis: M1 stub (manual/nightly writes are not implemented yet)"`.
Synthesis is live: `mlx-bun memory synthesize` runs the full DAG
(src/cli.ts:2508ff) and the nightly launchd job runs it
(src/memory/schedule.ts:66–72). The pi session will confidently tell the user
the feature doesn't exist. **Fix:** drop the stub lines; report real state
(e.g. last synthesis run from the synthesis DB / vault git log, and
"run: mlx-bun memory synthesize").

### 7. MEDIUM — docs/reference/memory.md contradicts itself
Line 9: "Synthesis is scaffolded but still a no-op M1 stub" vs line 41
("**`memory synthesize` writes to your vault.** It runs the full local
synthesis DAG …") and line 77 ("Synthesis is live today"). Fix line 9 (and the
line-53 "last-synthesis placeholder" wording once #6 lands).

### 8. LOW — server-api.md pi section omits `harness pi`
docs/reference/server-api.md:462–477 documents only the manual
`~/.pi/agent/models.json` route (which also bakes a concrete model id — the
staleness problem the `local` id exists to solve). Add: the supported
one-command path is `mlx-bun harness pi` (extension + live discovery +
`--remove` undo), manual models.json as the fallback.

### 9. LOW — three base-URL spellings for one loopback server
pi-web uses `http://127.0.0.1:${port}/v1` (src/pi-web.ts:487); the cli `pi`
probe/provider uses `http://localhost:${port}/v1` (src/cli.ts:1610, also the
serve preflight at :1215); harness `DEFAULT_BASE_URL` is
`http://localhost:8080/v1` (src/harness-pi.ts:25). Functionally coherent today
— verified empirically: Bun's fetch to `localhost` reaches both a
127.0.0.1-bound and a ::1-bound server — and the port sweep from 8ee691d is
clean (no live `8090` outside historical artifacts). But the harness extension
runs under the *user's pi* (node/jiti, not Bun), so standardize on
`127.0.0.1` (the actual default bind) everywhere to be resolver-proof.

### 10. LOW — `mlx-bun pi` arg edges (flag-strip itself is clean)
Verified complete: `OURS_VAL`/`OURS_BOOL` (src/cli.ts:1575–1582) cover every
flag read by `serverRuntimeFlags`/`applyDecodeRoute`/`mountStartupAdapter`/
`resolveModelAuto` (cross-checked flag-by-flag); `opt()` only supports
space-separated values repo-wide so there's no `--flag=value` bypass; the
"ignoring …" notice on server reuse works; `harness pi` passes nothing through
to pi (no leak path). Two edges remain:
- `parsePiArgs` (src/pi-terminal.ts:237–242) drops an unknown flag but keeps
  its **value** as message text: `mlx-bun pi --resume abc123` starts a chat
  with the message "abc123". Either swallow the next token for unknown
  `--flags` or warn that the flag was ignored.
- `RunEmbeddedPiOptions.verbose` (src/pi-terminal.ts:97) is never settable —
  parsePiArgs doesn't recognize `--verbose`. Wire it or delete it.

## Verified-good (no action)
- **Compat flags per model**: `buildPiProvider` derives `reasoning` →
  `thinkingFormat: "qwen-chat-template"` from `ctx.template.supportsThinking`,
  which is detected generically from the template source (`enable_thinking` +
  `<think>`/`<|channel>`, src/chat-template.ts:143–159) — covers Gemma,
  MiniCPM5, Qwen3.5, and Tier-0 generics with think-tag templates alike; the
  server honors `chat_template_kwargs.enable_thinking` and `reasoning_effort`
  with one precedence function (src/server.ts:1101–1108).
- **Wire contract**: pi's OpenAI `tool_calls` shape is produced for both the
  sentinel and buffered-text parsers (src/server.ts:548–575, 1916–1923,
  1989–2003), `finish_reason: "tool_calls"` included; `developer` role remapped.
- **Isolation**: both embeds use in-memory auth/registry (no ~/.pi cross-talk),
  own agent dirs (`~/.mlx-bun/pi`, `~/.mlx-bun/pi-sessions`), `noExtensions/
  noSkills/noPromptTemplates/noThemes`, curated skills only.
- **Server ownership**: `pi`-started servers are `owner: "pi-session"` and the
  reuse path warns when attaching to another session's server (cli.ts:1624–1631).
- **Memory read tools vs current vault code**: all imports
  (vault/query/article/schedule) exist and match; terminal surface exposes them
  correctly; FIND→READ contract intact. Only the status text (#6) is stale.
- **contextWindow fallbacks**: missing `max_position_embeddings` degrades to
  32768 at every consumer (`?? 32768` / `?? DEFAULT_CONTEXT_WINDOW`).
