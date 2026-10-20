// A deterministic, model-free stand-in for the server the browser app talks to: every JSON route the
// app reads, the chat WebSocket with a scripted streamed reply, the job and metrics event streams.
// It serves the fixtures in `fixtures.ts` and never loads a model, so the UI can be developed and
// tested on any machine. `scripts/web-preview.ts` mounts it behind the real static web handler;
// tests reach it over a real listener where they need streams, or stub `fetch` from the fixtures.
//
// Scenarios: `default` (a served model, a download in flight, saved chats, a memory vault);
// `empty` (a fresh install: nothing downloaded, no chats, no vault); `failing` (the Hub is
// offline, jobs fail, the chat answers with an error mid-reply).
import * as fixtures from "./fixtures";

export type Scenario = "default" | "empty" | "failing";

export interface FakeBackendOptions {
  scenario?: Scenario;
  /** Milliseconds between streamed chat deltas and job events; 0 streams everything at once. */
  paceMs?: number;
}

type ChatSocket = { send(data: string): void; readyState?: number; data: { turn: AbortController | null; session: string | null; context?: PageContext | null } };

/** What the browser last told the agent about its page (the chat's `context` frame), as the app-aware tools read it. */
export type PageContext = { route?: string; view?: string; step?: { index: number; count: number; label: string }; snapshot?: { elements?: { label?: string }[] } };

const json = (body: unknown, status = 200) => Response.json(body, { status });
const sleep = (ms: number, signal?: AbortSignal) => new Promise<void>((resolve) => {
  if (ms <= 0) return resolve();
  const timer = setTimeout(resolve, ms);
  signal?.addEventListener("abort", () => { clearTimeout(timer); resolve(); }, { once: true });
});

/** Splits a reply into word-sized deltas, keeping whitespace with the word before it. */
export function deltas(text: string): string[] {
  return text.match(/\S+\s*|\s+/g) ?? [];
}

const WIZARD_START: Record<string, { label: string; target: string }> = {
  quantize: { label: "Quantize", target: "quantize-source" }, finetune: { label: "Fine-tune", target: "finetune-base" }, dataset: { label: "Build Dataset", target: "" }, status: { label: "Status", target: "" },
};

/** The app-aware agent's answer to a prompt about the page, or null for an ordinary prompt: the frames to send first
 * (`ui_navigate`, `ui_spotlight`) and the text that follows. Mirrors what the real agent's navigate_app, spotlight_ui
 * and get_current_app_context tools produce, without a model. */
export function agentReply(text: string, context: PageContext | null): { frames: object[]; text: string } | null {
  const go = text.match(/\b(?:take me to|go to|open|show me)\b.*?\b(quantize|fine-?tune|finetune|dataset|status)\b/i);
  if (go) {
    const route = go[1]!.toLowerCase().replace("fine-tune", "finetune");
    const page = WIZARD_START[route]!;
    const frames: object[] = [{ type: "ui_navigate", route }];
    if (page.target) frames.push({ type: "ui_spotlight", route, target: page.target, message: "Start here." });
    return { frames, text: `Opened **${page.label}**${page.target ? " and highlighted where to start: the model field." : "."}` };
  }
  if (/\b(highlight|point (?:at|to)|where is)\b/i.test(text)) {
    return { frames: [{ type: "ui_spotlight", target: "hub-browse", message: "The served model. Click it for the Models page." }], text: "Highlighted the served model in the rail: click it to open the Models page." };
  }
  if (/what am i looking at|what(?:'s| is) on (?:my |the )?screen|describe (?:this|the) (?:page|screen)/i.test(text)) {
    if (!context) return { frames: [], text: "I have not received the page's context yet." };
    const labels = (context.snapshot?.elements ?? []).map((element) => element.label).filter((label): label is string => !!label);
    const where = context.view === "memory-panel" ? "the memory drawer, open over the " : "";
    const step = context.step ? ` at step ${context.step.index + 1} of ${context.step.count} (${context.step.label})` : "";
    const controls = labels.length ? ` I can see ${labels.length} controls, such as ${labels.slice(0, 4).join(", ")}.` : "";
    return { frames: [], text: `You are looking at ${where}**${context.route ?? "chat"}** page${step}.${controls}` };
  }
  return null;
}

/** An SSE body that writes each event with the given pacing and ends with `event: end`. */
function eventStream(events: readonly object[], paceMs: number, options: { event?: string; keepAliveMs?: number; failAfter?: number; endEvent?: boolean } = {}): Response {
  const encoder = new TextEncoder();
  let closed = false;
  const stream = new ReadableStream<Uint8Array>({
    async start(controller) {
      const send = (text: string) => { if (!closed) controller.enqueue(encoder.encode(text)); };
      send("retry: 1500\n\n");
      let index = 0;
      for (const event of events) {
        if (closed) return;
        if (options.failAfter !== undefined && index === options.failAfter) {
          send(`data: ${JSON.stringify({ type: "failed", error: "the worker exited with code 137 (out of memory)", ts: Date.now() })}\n\n`);
          break;
        }
        send((options.event ? `event: ${options.event}\n` : "") + `data: ${JSON.stringify(event)}\n\n`);
        index++;
        if (options.keepAliveMs && index % 5 === 0) send(": keep-alive\n\n");
        await sleep(paceMs);
      }
      if (options.endEvent !== false && !closed) send("event: end\ndata: {}\n\n");
      if (!closed) { closed = true; controller.close(); }
    },
    cancel() { closed = true; },
  });
  return new Response(stream, { headers: { "content-type": "text/event-stream", "cache-control": "no-cache", connection: "keep-alive" } });
}

/** A metrics stream that stays open: one snapshot on connect, then one every `paceMs * 40` (or 2 s), with keep-alive comments between. */
function metricsStream(paceMs: number): Response {
  const encoder = new TextEncoder();
  let closed = false;
  let timer: ReturnType<typeof setInterval> | undefined;
  const stream = new ReadableStream<Uint8Array>({
    start(controller) {
      const send = (text: string) => { if (!closed) controller.enqueue(encoder.encode(text)); };
      send("retry: 1500\n\n");
      send(`event: snapshot\ndata: ${JSON.stringify(fixtures.metricsSnapshot())}\n\n`);
      let beat = 0;
      timer = setInterval(() => {
        if (closed) return;
        beat++;
        if (beat % 2 === 0) send(`event: snapshot\ndata: ${JSON.stringify(fixtures.metricsSnapshot())}\n\n`);
        else send(": keepalive\n\n");
      }, Math.max(250, paceMs * 40 || 2_000));
    },
    cancel() { closed = true; if (timer) clearInterval(timer); },
  });
  return new Response(stream, { headers: { "content-type": "text/event-stream", "cache-control": "no-cache", connection: "keep-alive" } });
}

export function createFakeBackend(options: FakeBackendOptions = {}) {
  const scenario = options.scenario ?? "default";
  const paceMs = options.paceMs ?? 24;
  const empty = scenario === "empty";
  const failing = scenario === "failing";
  let hasToken = false;
  let jobs = 0;
  const alwaysAllow = empty ? [] : ["read", "web_search"];
  const vault = { enabled: !empty };

  const served = () => empty ? { object: "list", data: [] } : fixtures.models;

  /** The streamed answer to a prompt; `abort` cancels it, `failing` ends it with the protocol's error frame. */
  async function reply(socket: ChatSocket, text: string): Promise<void> {
    const turn = new AbortController();
    socket.data.turn = turn;
    const signal = turn.signal;
    const send = (frame: object) => { if (!signal.aborted) socket.send(JSON.stringify(frame)); };
    const finish = () => {
      socket.data.turn = null;
      socket.send(JSON.stringify({ type: "turn_end" }));
      socket.send(JSON.stringify({ type: "siblings", entryId: "e-live", index: 0, count: 1, siblingIds: ["e-live"] }));
      socket.send(JSON.stringify({ type: "context", tokens: 1_842, contextWindow: 32_768, percent: 5.6 }));
    };
    send({ type: "turn_start" });
    // The app-aware agent: a request to go somewhere navigates and highlights where to start, a request to point
    // highlights the rail's model button, and a question about the screen is answered from the page's last context.
    const agentic = agentReply(text, socket.data.context ?? null);
    if (agentic) {
      for (const frame of agentic.frames) { send(frame); await sleep(paceMs * 4, signal); if (signal.aborted) return finish(); }
      for (const delta of deltas(agentic.text)) { send({ type: "text_delta", delta }); await sleep(paceMs, signal); if (signal.aborted) return finish(); }
      return finish();
    }
    const script = fixtures.scriptedReply;
    const long = /\/slow\b/.test(text);
    for (const piece of script.thinking) { send({ type: "thinking_delta", delta: piece }); await sleep(paceMs * 4, signal); if (signal.aborted) return finish(); }
    if (vault.enabled) {
      send({ type: "tool_start", callId: script.memoryTool.callId, tool: script.memoryTool.tool, args: script.memoryTool.args });
      await sleep(paceMs * 8, signal); if (signal.aborted) return finish();
      send({ type: "tool_end", callId: script.memoryTool.callId, ok: true, result: script.memoryTool.result });
    }
    if (/\bapprov/i.test(text)) {
      send({ type: "tool_approval_request", callId: "a1", tool: "bash", args: { command: "rm -rf ~/.mlx-bun/kv" } });
      await sleep(paceMs * 8, signal); if (signal.aborted) return finish();
    }
    send({ type: "tool_start", callId: script.shellTool.callId, tool: script.shellTool.tool, args: script.shellTool.args });
    await sleep(paceMs * 6, signal); if (signal.aborted) return finish();
    send({ type: "tool_update", callId: script.shellTool.callId, chunk: script.shellTool.result.slice(0, 20) });
    await sleep(paceMs * 6, signal); if (signal.aborted) return finish();
    send({ type: "tool_end", callId: script.shellTool.callId, ok: true, result: script.shellTool.result });
    const words = deltas(long ? script.text.repeat(6) : script.text);
    let count = 0;
    for (const delta of words) {
      send({ type: "text_delta", delta });
      count++;
      if ((failing || /\/fail\b/.test(text)) && count === 12) {
        socket.data.turn = null;
        socket.send(JSON.stringify({ type: "error", message: "the model worker stopped answering (connection reset by peer)" }));
        return;
      }
      await sleep(paceMs, signal);
      if (signal.aborted) return finish();
    }
    finish();
  }

  const websocket = {
    open(socket: ChatSocket) {
      socket.data = { turn: null, session: null };
      const ready = { type: "ready", model: empty ? "" : fixtures.SERVED_MODEL, vision: false, audio: false, thinking: !empty, transcription: false, genDefaults: { temperature: 0.7, topP: 0.9, topK: 40 } };
      socket.send(JSON.stringify(ready));
      socket.send(JSON.stringify({ type: "coding_tools", active: false, pending: false }));
      socket.send(JSON.stringify({ type: "tool_approvals", alwaysAllow }));
      // The default scenario resumes the latest saved chat so the thread has content to look at; `empty` starts blank.
      const resumed = empty ? undefined : fixtures.sessions[0]!.path;
      socket.data.session = resumed ?? null;
      socket.send(JSON.stringify({ type: "sessions", items: empty ? [] : fixtures.sessions, activePath: resumed }));
      socket.send(JSON.stringify({ type: "history", items: resumed ? fixtures.history : [] }));
      socket.send(JSON.stringify({ type: "siblings", ...(resumed ? { entryId: "e2", index: 0, count: 1, siblingIds: ["e2"] } : { index: 0, count: 0, siblingIds: [] }) }));
      socket.send(JSON.stringify({ type: "context", tokens: resumed ? 1_204 : null, contextWindow: 32_768, percent: resumed ? 3.7 : null }));
    },
    message(socket: ChatSocket, raw: string | Buffer) {
      let frame: { type?: string; text?: string; path?: string; enabled?: boolean };
      try { frame = JSON.parse(String(raw)); } catch { return; }
      switch (frame.type) {
        case "prompt":
          if (socket.data.turn) return;
          if (empty) { socket.send(JSON.stringify({ type: "error", message: "no model is loaded: pick one on the Models page" })); return; }
          void reply(socket, frame.text ?? "");
          break;
        case "regenerate": case "edit_resend":
          if (!socket.data.turn) void reply(socket, frame.text ?? "");
          break;
        case "abort":
          socket.data.turn?.abort();
          break;
        case "new_session":
          socket.data.session = null;
          socket.send(JSON.stringify({ type: "history", items: [] }));
          socket.send(JSON.stringify({ type: "sessions", items: empty ? [] : fixtures.sessions, activePath: undefined }));
          break;
        case "open_session": case "fork_session":
          socket.data.session = frame.path ?? null;
          socket.send(JSON.stringify({ type: "history", items: fixtures.history }));
          socket.send(JSON.stringify({ type: "sessions", items: fixtures.sessions, activePath: frame.path }));
          socket.send(JSON.stringify({ type: "siblings", entryId: "e2", index: 0, count: 1, siblingIds: ["e2"] }));
          socket.send(JSON.stringify({ type: "context", tokens: 1_204, contextWindow: 32_768, percent: 3.7 }));
          break;
        case "delete_session":
          socket.send(JSON.stringify({ type: "sessions", items: fixtures.sessions.filter(s => s.path !== frame.path), activePath: socket.data.session ?? undefined }));
          break;
        case "set_coding_tools":
          socket.send(JSON.stringify({ type: "coding_tools", active: false, pending: !!frame.enabled }));
          break;
        case "list_sessions":
          socket.send(JSON.stringify({ type: "sessions", items: empty ? [] : fixtures.sessions, activePath: socket.data.session ?? undefined }));
          break;
        case "context":
          socket.data.context = (frame as { context?: PageContext }).context ?? null;
          break;
        default: break; // set_thinking, set_sampling, set_system_prompt, set_adapter, approval, switch_sibling: accepted silently
      }
    },
    close(socket: ChatSocket) { socket.data.turn?.abort(); },
  };

  /** Answers one request, or null when the path is not the backend's (static files are the web handler's). */
  async function fetch(request: Request, server?: { upgrade(request: Request, options?: { data: unknown }): boolean }): Promise<Response | null> {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;
    const body = async () => (method === "GET" || method === "HEAD" ? {} : await request.json().catch(() => ({}))) as Record<string, unknown>;
    if (path === "/ws/chat") {
      if (server?.upgrade(request, { data: { turn: null, session: null, context: null } })) return new Response(null);
      return new Response("expected a WebSocket upgrade", { status: 426 });
    }
    if (path === "/dag") return new Response("not found", { status: 404 });
    if (path === "/health") return json({ status: "ready" });
    if (path === "/v1/models") return json(served());
    if (path === "/downloads") return json(empty ? { downloads: [] } : fixtures.downloads);
    if (path === "/stats") return json(empty ? { server: fixtures.stats.server, admission: {}, prompt_cache: {}, response_store: {}, kv_quant: {} } : fixtures.stats);
    if (path === "/fit") return json(empty ? { report: {}, machine: fixtures.fit.machine, sku_matrix: [] } : fixtures.fit);
    if (path === "/library") return json(empty ? { models: [] } : fixtures.library);
    if (path === "/api/hub/local") return json(empty ? { ok: true, models: [] } : fixtures.hubLocal);
    if (path === "/api/hub/search") {
      if (failing) return json({ ok: true, offline: true, results: [] });
      const query = (url.searchParams.get("q") ?? "").toLowerCase();
      return json({ ...fixtures.hubSearch, results: fixtures.hubSearch.results.filter(row => row.id.toLowerCase().includes(query)) });
    }
    if (path === "/api/hub/download") return failing ? json({ ok: false, error: "Hugging Face is unreachable (ENOTFOUND huggingface.co)" }, 502) : json({ ok: true });
    if (path === "/api/hub/serve") {
      const { model } = await body();
      return failing ? json({ ok: false, error: `${String(model)} does not fit beside the running models` }, 409) : json({ ok: true, model });
    }
    if (path === "/v1/adapters/available") return json(empty ? { adapters: [] } : fixtures.adaptersAvailable);
    if (path === "/v1/adapters" && method === "GET") return json(empty ? { adapters: [] } : fixtures.adaptersMounted);
    if (path === "/v1/adapters" && method === "POST") return failing ? json({ ok: false, error: "adapter targets q_proj, which this graph does not expose" }, 400) : json({ ok: true });
    if (path.startsWith("/v1/adapters/") && method === "DELETE") return json({ ok: true });
    if (path === "/api/settings/hf-token") {
      if (method === "POST") { hasToken = true; return json({ ok: true }); }
      return json({ ok: true, hasToken });
    }
    if (path === "/api/settings/tool-approvals" && method === "DELETE") {
      const { tool } = await body();
      const index = alwaysAllow.indexOf(String(tool));
      if (index >= 0) alwaysAllow.splice(index, 1);
      return json({ ok: true, alwaysAllow });
    }
    if (path === "/api/sessions/search") return json(empty ? { ok: true, results: [] } : fixtures.sessionSearch);
    if (path === "/api/sessions/export") return json({ ok: true, title: "chat", entries: fixtures.history.map(item => ({ type: "message", message: { role: item.role, content: item.text } })) });
    if (path === "/api/memory/status") return json(vault.enabled ? fixtures.memoryStatus : { ok: true, enabled: false, root: fixtures.memoryStatus.root });
    if (path === "/api/memory/init") { vault.enabled = true; return json({ ok: true, result: { root: fixtures.memoryStatus.root, gitInitialized: true }, status: fixtures.memoryStatus.status }); }
    if (!vault.enabled && path.startsWith("/api/memory/")) return json({ ok: false, enabled: false, error: "no memory vault yet" }, 404);
    if (path === "/api/memory/list") return json(fixtures.memoryList);
    if (path === "/api/memory/search") {
      const query = (url.searchParams.get("q") ?? "").toLowerCase();
      const hits = fixtures.memoryList.articles.filter(name => name.toLowerCase().includes(query));
      return json({ ok: true, summaries: hits.map(article => ({ article, occurrences: 2 })), hits: hits.map(article => ({ article, anchor: null, line: 3, excerpt: `…${query}…` })) });
    }
    if (path === "/api/memory/article") {
      const name = url.searchParams.get("name") ?? "";
      const content = fixtures.memoryArticles[name] ?? `# ${name.replace(/_/g, " ")}\n\nNothing written here yet.\n`;
      return json({ ok: true, name, path: `${fixtures.memoryStatus.root}/${name}.md`, content, infobox: null, lead: null });
    }
    if (path === "/api/memory/links") return json(fixtures.memoryLinks);
    if (path === "/api/memory/history") return json(fixtures.memoryHistory);
    if (path === "/api/memory/diff") return json(fixtures.memoryDiff);
    if (path === "/api/quantize/inspect") {
      const { model_id } = await body();
      return failing ? json({ ok: false, error: `config.json not found under ${String(model_id)}` }, 404)
        : json({ ok: true, model_id, arch: "qwen3", size_gb: 54.3, support: true });
    }
    if (path === "/api/quantize/resolve-folder" || path === "/api/model/resolve-folder") {
      const { folder_name } = await body();
      return json({ ok: true, path: `/Users/josh/.cache/huggingface/hub/models--${String(folder_name)}/snapshots/abc123` });
    }
    if (path === "/api/quantize/submit") return json({ ok: true, job_id: `quantize-${++jobs}`, output_dir: "/Users/josh/.mlx-bun/models/Qwen3-27B-4bit-g64" });
    if (path === "/api/finetune/inspect-dataset") return failing ? json({ ok: false, error: "train.jsonl has no rows" }, 400) : json({ ok: true, n_train: 1_840, n_valid: 204, format: "messages" });
    if (path === "/api/finetune/submit") return json({ ok: true, job_id: `finetune-${++jobs}`, adapter_path: "/Users/josh/.mlx-bun/adapters/run-2026-10-20" });
    if (path === "/api/finetune/merge") return json({ ok: true, merged_path: "/Users/josh/.mlx-bun/adapters/merged-2026-10-20", stats: { layers: 32, params: "4.1M" } });
    if (path === "/api/finetune/export") return json({ ok: true, export_path: "/Users/josh/.mlx-bun/exports/Qwen3-27B-support-tone" });
    if (path === "/api/dataset/templates") return json(fixtures.datasetTemplates);
    if (path === "/api/dataset/submit") return json({ ok: true, job_id: `dataset-${++jobs}`, output_dir: "/Users/josh/.mlx-bun/datasets/job-2026-10-20" });
    if (/^\/api\/(quantize|finetune|dataset)\/push$/.test(path)) {
      const { repo_id } = await body();
      return failing ? json({ ok: false, error: "the Hub refused the token (401)" }, 401) : json({ ok: true, url: `https://huggingface.co/${String(repo_id)}` });
    }
    const job = path.match(/^\/api\/jobs\/([^/]+)\/stream$/);
    if (job) return eventStream(fixtures.jobEvents(decodeURIComponent(job[1]!)), paceMs * 3, { keepAliveMs: 1, ...(failing ? { failAfter: 7 } : {}) });
    if (path === "/api/metrics/stream") return metricsStream(paceMs);
    if (path === "/api/metrics/snapshot") return json(fixtures.metricsSnapshot());
    if (path === "/api/metrics/history") return json(empty ? { runs: [] } : fixtures.benchHistory);
    if (path === "/api/metrics/bench/profiles") return json(empty ? { profiles: [] } : fixtures.benchProfiles);
    if (path === "/api/metrics/bench" && method === "GET") return json(fixtures.benchJobs);
    if (path === "/api/metrics/bench" && method === "POST") return failing ? json({ error: { message: "a training job holds the GPU" } }, 409) : json({ ok: true, id: `bench-${++jobs}` });
    if (path === "/api/benchmarks/tasks") return json(fixtures.benchmarkTasks);
    if (path === "/api/benchmarks/runs" && method === "GET") return json(empty ? { runs: [] } : fixtures.benchmarkRuns);
    if (path === "/api/benchmarks/runs" && method === "POST") return failing ? json({ error: { message: "the smoke dataset is missing" } }, 400) : json({ ok: true, id: `eval-${++jobs}` });
    if (path === "/api/benchmarks/jobs") return json(fixtures.benchmarkJobs);
    if (path === "/api/benchmarks/compare") return json(fixtures.benchmarkComparison);
    if (path.startsWith("/v1/audio/")) return json({ error: { message: "no transcription model is configured" } }, 404);
    if (path.startsWith("/api/") || path.startsWith("/v1/")) return json({ error: { message: `the fake backend has no fixture for ${method} ${path}` } }, 404);
    return null;
  }

  return { fetch, websocket, scenario };
}

/** Runs the fake backend behind a static web handler on a real listener; returns the URL and a `stop`. */
export function startFakeBackend(options: FakeBackendOptions & { port?: number; hostname?: string; web?: (request: Request) => Response | null } = {}) {
  const backend = createFakeBackend(options);
  const server = Bun.serve<{ turn: AbortController | null; session: string | null; context: PageContext | null }>({
    hostname: options.hostname ?? "127.0.0.1",
    port: options.port ?? 0,
    idleTimeout: 0,
    async fetch(request, listener) {
      const answer = await backend.fetch(request, listener);
      if (answer) return answer;
      return options.web?.(request) ?? new Response("not found", { status: 404 });
    },
    websocket: backend.websocket,
  });
  return { url: server.url.href.replace(/\/$/, ""), port: server.port, scenario: backend.scenario, stop: () => server.stop(true) };
}
