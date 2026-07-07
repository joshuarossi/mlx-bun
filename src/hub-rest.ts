// Model Hub REST wrappers — thin loopback JSON routes for the web chat's
// Model Hub panel (docs/design/web-chat-redesign.md §9 Phase 3, beat-matrix
// Axis 3 "Hub" row). Same posture as src/memory/rest.ts: pure (request|url)
// => Response handlers with no `ctx` dependency, dispatched from
// src/server.ts by path+method, so they're unit-testable without booting a
// model context (see tests/hub-rest.test.ts).
//
// Three sources, same as optiq Lab's Hub, plus the hardware-fit column optiq
// lacks:
//   - GET /api/hub/local    — registry's canonical downloaded models, each
//     with a /fit-computed verdict (predicted decode tok/s + fits at a
//     default context) — the beat-matrix "real hardware verdict per row".
//   - GET /api/hub/search   — server-side HF model search, filtered to
//     MLX-compatible results, normalized. NEVER auto-downloads.
//   - POST /api/hub/download — kicks off a background download via the
//     existing downloadModel() + process tracker (src/download.ts);
//     progress is already visible via GET /downloads. Refuses a duplicate
//     in-flight download for the same repo.
//   - POST /api/hub/serve   — model-swap investigation (see the doc header
//     above the handler): today this ALWAYS returns
//     { ok:false, restart_required:true, command } — see
//     docs/design/runtime-isolation.md for why no in-process swap seam is
//     reachable from the web chat's serving path today.

import { loadModelConfig } from "./config";
import { fit } from "./fit";
import { downloadModel, hfToken, isDownloadActive, type DownloadOptions } from "./download";
import { Registry, visionCapable, type ModelRecord } from "./registry";
import { supportTier } from "./model/support";

function jsonOk<T extends object>(body: T, init?: ResponseInit): Response {
  return Response.json({ ok: true, ...body }, init);
}

function jsonErr(error: string, status = 400): Response {
  return Response.json({ ok: false, error }, { status });
}

// ---- GET /api/hub/local -------------------------------------------------

/** One row per canonical repo, mirroring /library's shape but scoped to
 *  what the Hub panel needs: size/quant/capabilities + a fit verdict at a
 *  fixed 8k context (the same "typical" context /fit and /library use, so
 *  the three surfaces never disagree). `reg`/`hubDir` are injectable so
 *  tests can point at a synthetic hub dir instead of the real
 *  ~/.cache/huggingface/hub (matching tests/registry-fit.test.ts's pattern);
 *  the live server route omits both and gets the real registry. */
export async function handleHubLocal(
  opts: { reg?: Registry; hubDir?: string } = {},
): Promise<Response> {
  const reg = opts.reg ?? new Registry();
  const ownReg = !opts.reg;
  try {
    await reg.scan(opts.hubDir);
    const rows = [];
    for (const m of reg.listCanonical()) {
      rows.push(await hubLocalRow(m));
    }
    return jsonOk({ models: rows });
  } finally {
    if (ownReg) reg.close();
  }
}

async function hubLocalRow(m: ModelRecord) {
  const tier = supportTier(m.modelType, m.repoId);
  let assessment: {
    fits: boolean;
    max_safe_context: number;
    predicted_decode_tps: number;
  } | null = null;
  try {
    const config = await loadModelConfig(m.path);
    const r = fit(config, m.sizeBytes, 8192, undefined, undefined, m.expertsBytes);
    assessment = {
      fits: r.fits,
      max_safe_context: r.maxSafeContext,
      predicted_decode_tps: r.predictedDecodeTps,
    };
  } catch {
    /* unreadable config — assessment stays null, row still lists */
  }
  return {
    repo_id: m.repoId,
    model_type: m.modelType,
    size_bytes: m.sizeBytes,
    quant_bits: m.quantBits,
    quant_group_size: m.quantGroupSize,
    vision: visionCapable(m),
    supported: tier !== null,
    support_tier: tier,
    assessment,
  };
}

// ---- GET /api/hub/search -------------------------------------------------

export interface HubSearchResult {
  id: string;
  downloads: number;
  likes: number;
  size_estimate: number | null;
}

/** The HF Hub's model-search API, filtered to the `mlx` library tag (the
 *  tag mlx-community and every other MLX-converted repo carries) so results
 *  are MLX-compatible by construction — same convention the download path
 *  already speaks HTTPS against (huggingface.co/api/*). Injectable `fetchFn`
 *  for tests; defaults to the real global fetch. */
export async function searchHub(
  query: string,
  opts: { fetchFn?: typeof fetch; limit?: number; endpoint?: string } = {},
): Promise<
  | { ok: true; offline: false; results: HubSearchResult[] }
  | { ok: false; offline: true; error: string }
> {
  const fetchFn = opts.fetchFn ?? fetch;
  const endpoint = opts.endpoint ?? "https://huggingface.co";
  const limit = opts.limit ?? 30;
  const token = hfToken();
  const url =
    `${endpoint}/api/models?search=${encodeURIComponent(query)}` +
    `&filter=mlx&sort=downloads&direction=-1&limit=${limit}`;
  let res: Response;
  try {
    res = await fetchFn(url, {
      headers: token ? { authorization: `Bearer ${token}` } : {},
      signal: AbortSignal.timeout(10_000),
    });
  } catch (e) {
    // Network unreachable (offline, DNS failure, timeout) — never surface
    // this as a 500; the Hub panel shows an explicit offline state instead.
    return { ok: false, offline: true, error: (e as Error).message };
  }
  if (!res.ok) {
    return { ok: false, offline: true, error: `HF search ${res.status}` };
  }
  let body: unknown;
  try {
    body = await res.json();
  } catch (e) {
    return { ok: false, offline: true, error: `HF search: bad response (${(e as Error).message})` };
  }
  const rows = Array.isArray(body) ? body : [];
  const results: HubSearchResult[] = rows
    // Belt-and-suspenders: the API's filter=mlx already restricts to the
    // tag, but a defensive re-check keeps a future upstream filter change
    // from silently widening results to non-MLX repos.
    .filter((r) => Array.isArray((r as Record<string, unknown>).tags)
      ? ((r as { tags: string[] }).tags).includes("mlx")
      : true)
    .map((r) => {
      const row = r as Record<string, unknown>;
      return {
        id: String(row.id ?? row.modelId ?? ""),
        downloads: typeof row.downloads === "number" ? row.downloads : 0,
        likes: typeof row.likes === "number" ? row.likes : 0,
        // The search endpoint doesn't return file sizes (that's a second
        // per-repo call this v1 skips to keep search fast) — null, not a
        // fabricated number; the frontend's fit badge lands after download.
        size_estimate: null,
      };
    })
    .filter((r) => r.id.length > 0);
  return { ok: true, offline: false, results };
}

export async function handleHubSearch(url: URL): Promise<Response> {
  const q = url.searchParams.get("q")?.trim() ?? "";
  if (!q) return jsonErr("missing ?q=");
  const result = await searchHub(q);
  if (!result.ok) return jsonOk({ offline: true, error: result.error, results: [] });
  return jsonOk({ offline: false, results: result.results });
}

// ---- POST /api/hub/download -----------------------------------------------

// downloadModel()'s own DownloadStatus row (src/download.ts's downloadLog,
// read via isDownloadActive) only exists once listRepoFiles' network round
// trip resolves — a rapid double-submit of this route can both pass that
// check before either row is written. Route-local admission closes that
// window: a repo is marked in-flight synchronously, before the first
// `await`, and cleared in a `finally` once downloadModel settles either way.
const inFlightHubDownloads = new Set<string>();

export async function handleHubDownload(request: Request): Promise<Response> {
  const body = (await request.json().catch(() => ({}))) as { repo?: string };
  const repo = body.repo?.trim();
  if (!repo) return jsonErr("missing \"repo\"");
  if (inFlightHubDownloads.has(repo) || isDownloadActive(repo))
    return jsonErr(`a download for ${repo} is already in progress`, 409);
  inFlightHubDownloads.add(repo);
  // Fire-and-forget, mirroring the CLI's background-download pattern
  // (cli.ts's `downloadModel(recRepo).then(...).catch(...)`) — progress is
  // already visible via GET /downloads (the process-global tracker
  // downloadModel() itself writes to); this route just starts it and
  // returns immediately rather than blocking on a multi-GB transfer.
  const opts: DownloadOptions = {};
  downloadModel(repo, opts)
    .then(async () => {
      try {
        const reg = new Registry();
        try { await reg.scan(); } finally { reg.close(); }
      } catch { /* best-effort refresh; /downloads still shows completion */ }
    })
    .catch(() => { /* status recorded on the tracker; /downloads shows the error */ })
    .finally(() => inFlightHubDownloads.delete(repo));
  return jsonOk({ repo, started: true });
}

// ---- POST /api/hub/serve --------------------------------------------------

/** Model-swap investigation (docs/design/runtime-isolation.md): the web
 *  chat's `/ws/chat` is explicitly NOT proxied even under `--isolate`
 *  (src/serve/isolate.ts serves it a 501 with a pointer back to the direct,
 *  non-isolated server) and `--isolate` itself is opt-in, not the default —
 *  so the process the web chat actually talks to always has exactly one
 *  model loaded in-process with no drop-weights-and-reload seam. The
 *  isolate.ts `ModelPool` (P2, spawn-overlap child-per-model) IS a real,
 *  working live-swap mechanism, but it lives entirely on the `--isolate`
 *  reverse-proxy's `/v1/*` HTTP surface — not reachable from the WebSocket
 *  chat path this Hub panel serves. Faking a swap here (killing/reloading
 *  the in-process model while `/ws/chat` sessions are attached) would leave
 *  the server in a half-state the ground rules forbid ("the AI may crash,
 *  the UI never may" — a self-inflicted crash is not better). Honest
 *  answer: refuse, and hand back the exact restart command. Follow-up:
 *  wire /ws/chat through the isolate proxy (or move session state above the
 *  engine boundary) so ModelPool's spawn-overlap swap is actually reachable
 *  from the web chat — tracked as the Hub's live-swap follow-up. */
export async function handleHubServe(request: Request): Promise<Response> {
  const body = (await request.json().catch(() => ({}))) as { model?: string };
  const model = body.model?.trim();
  if (!model) return jsonErr("missing \"model\"");
  // ok:false is deliberate — this is not an error the caller mishandled, it
  // is the honest capability answer ("no live swap today"), but it is also
  // not success: the frontend must not treat this as "now serving `model`".
  return Response.json({
    ok: false,
    restart_required: true,
    command: `mlx-bun serve ${model}`,
  });
}
