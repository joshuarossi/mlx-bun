// Runtime isolation — the parent half (docs/design/runtime-isolation.md).
//
// ARCHITECTURE (decision 2026-07-05, deviating from the doc's original
// structured-IPC sketch — recorded there): the inference ENGINE is the
// ENTIRE existing server, spawned as a child process listening on a unix
// domain socket; this module is the parent — a thin reverse proxy that
// binds the TCP port, forwards everything to the child, and NEVER touches
// MLX. Rationale: the gateway-as-IPC-client cut would have to serialize
// grammar controllers (WASM), vision embeddings (GPU arrays), sampler
// closures, and prompt-cache hooks across a message protocol — weeks of
// re-plumbing; HTTP-over-UDS reuses the whole serving stack verbatim,
// streams SSE for free, and turns cancellation into plain abort
// propagation (client disconnect → proxied fetch aborts → the child's
// existing disconnect handling fires).
//
// Isolation properties delivered:
// - The parent event loop only proxies (fully async) — UI/API stay
//   instant no matter what the GPU is doing.
// - A child crash (uncatchable Metal OOM/SIGTRAP) 502s in-flight requests
//   and RESPAWNS the engine; the parent — and the user's session — never
//   go down. "The AI may crash, the UI never may."
// - P2 (multi-model): one child per model, each on its own socket; the
//   parent routes by the request's `model` field and switches by
//   spawn-overlap (new child loads while the old one keeps serving).
//
// Not proxied in v1: /ws/chat (WebSocket upgrade) — answered 501 with a
// pointer; the pi-based chat UI runs against the direct (non-isolated)
// server until WS proxying lands.

import { unlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

/** How to (re)start the engine child. `argv[0]` is the executable. */
export interface EngineSpec {
  argv: string[];
  socketPath: string;
  /** Max ms to wait for the child's /health after spawn (weights load —
   *  large models take a while). Default 15 min. */
  readyTimeoutMs?: number;
}

const HOP_BY_HOP = new Set([
  "connection", "keep-alive", "proxy-authenticate", "proxy-authorization",
  "te", "trailer", "transfer-encoding", "upgrade",
]);

export function defaultSocketPath(): string {
  return join(tmpdir(), `mlx-bun-engine-${process.pid}.sock`);
}

/** The persistent engine child: spawn, health-gate, respawn-on-crash. */
export class EngineChild {
  readonly spec: EngineSpec;
  #proc: ReturnType<typeof Bun.spawn> | null = null;
  #ready: Promise<void>;
  #stopping = false;
  restarts = 0;
  #lastSpawnAt = 0;

  constructor(spec: EngineSpec) {
    this.spec = spec;
    this.#ready = this.#spawn();
  }

  get ready(): Promise<void> {
    return this.#ready;
  }

  get pid(): number | null {
    return this.#proc?.pid ?? null;
  }

  async #spawn(): Promise<void> {
    this.#lastSpawnAt = Date.now();
    try { unlinkSync(this.spec.socketPath); } catch {}
    const proc = Bun.spawn(this.spec.argv, {
      stdio: ["ignore", "inherit", "inherit"], // load progress → user's terminal
      env: process.env,
    });
    this.#proc = proc;
    void proc.exited.then((code) => {
      if (this.#stopping || this.#proc !== proc) return;
      console.error(`[isolate] engine exited (code ${code}) — respawning`);
      this.restarts++;
      // Crash-loop backoff: an engine that dies within 10 s of spawning
      // (bad flags, OOM on load) waits 5 s before the retry.
      const delay = Date.now() - this.#lastSpawnAt < 10_000 ? 5_000 : 0;
      this.#ready = new Promise((r) => setTimeout(r, delay)).then(() => this.#spawn());
    });
    // Health-gate: poll the child's /health over the socket until it
    // answers — model load happens behind this.
    const deadline = Date.now() + (this.spec.readyTimeoutMs ?? 15 * 60_000);
    while (Date.now() < deadline) {
      if (proc.killed || this.#proc !== proc) throw new Error("engine died during startup");
      try {
        const r = await fetch("http://engine/health", {
          unix: this.spec.socketPath,
          signal: AbortSignal.timeout(2_000),
        } as RequestInit & { unix: string });
        if (r.ok) return;
      } catch { /* not up yet */ }
      await new Promise((r) => setTimeout(r, 250));
    }
    throw new Error("engine did not become healthy in time");
  }

  /** Forward one request to the child; the response streams through.
   *  Bodyless requests (GET/HEAD) retry ONCE after a respawn completes —
   *  a request that races an engine crash waits out the reload instead of
   *  502ing; requests with consumed stream bodies cannot be replayed and
   *  502 by design (the doc's "fail in-flight cleanly"). */
  async forward(request: Request): Promise<Response> {
    try {
      return await this.#forwardOnce(request);
    } catch (e) {
      const retriable = (request.method === "GET" || request.method === "HEAD") &&
        !request.signal.aborted;
      if (!retriable) throw e;
      // The exited-handler may not have swapped #ready yet — give it a beat.
      await new Promise((r) => setTimeout(r, 250));
      return await this.#forwardOnce(request);
    }
  }

  async #forwardOnce(request: Request): Promise<Response> {
    await this.#ready;
    const headers = new Headers();
    request.headers.forEach((v, k) => {
      if (!HOP_BY_HOP.has(k.toLowerCase())) headers.set(k, v);
    });
    const proxied = await fetch(request.url, {
      method: request.method,
      headers,
      body: request.body,
      signal: request.signal, // client abort → child sees the disconnect
      redirect: "manual",
      unix: this.spec.socketPath,
      // Streaming request bodies need half-duplex; buffered bodies ignore it.
      duplex: "half",
    } as RequestInit & { unix: string; duplex: string });
    const outHeaders = new Headers();
    proxied.headers.forEach((v, k) => {
      if (!HOP_BY_HOP.has(k.toLowerCase())) outHeaders.set(k, v);
    });
    return new Response(proxied.body, { status: proxied.status, headers: outHeaders });
  }

  stop(): void {
    this.#stopping = true;
    this.#proc?.kill();
    try { unlinkSync(this.spec.socketPath); } catch {}
  }
}

/** Model resolution the parent injects (Registry-backed in production;
 *  a plain map in tests). Returns null for unknown names — those keep the
 *  drop-in ignore semantics (served by the default model, like mlx-lm). */
export type ModelResolver = (query: string) => { repoId: string; path: string } | null;

/** Child-per-model pool (P2, runtime-isolation.md): LRU residency over
 *  engine children. Eviction is graceful and lossless — POST /admin/drain
 *  (gateway quiesce + demote the prompt cache to the SSD tier, keyed by
 *  that model's own fingerprint dir) and only then stop the child; the
 *  evicted model's whole state survives on disk, so bringing it back is a
 *  spawn + mmap fault-in + zero-copy KV restore, not a re-prefill. A
 *  SWITCH is spawn-overlap: the new child health-gates while the old one
 *  keeps serving — nobody's session is interrupted. */
export class ModelPool {
  #children = new Map<string, EngineChild>(); // repoId → child
  #lru: string[] = []; // most-recent last
  #spawning = new Map<string, Promise<EngineChild>>();
  readonly defaultKey: string;

  constructor(
    private readonly opts: {
      rawArgs: string[];
      selfArgv: string[]; // how to re-exec this CLI
      poolMax: number; // resident children cap (≥1)
      resolve: ModelResolver;
      defaultKey: string;
      defaultChild: EngineChild;
      socketFor?: (repoId: string) => string;
    },
  ) {
    this.defaultKey = opts.defaultKey;
    this.#children.set(opts.defaultKey, opts.defaultChild);
    this.#lru.push(opts.defaultKey);
  }

  get residentKeys(): string[] {
    return [...this.#children.keys()];
  }

  child(key: string): EngineChild | undefined {
    return this.#children.get(key);
  }

  #bump(key: string): void {
    this.#lru = this.#lru.filter((k) => k !== key);
    this.#lru.push(key);
  }

  #socketFor(repoId: string): string {
    if (this.opts.socketFor) return this.opts.socketFor(repoId);
    const slug = repoId.replace(/[^a-zA-Z0-9.-]+/g, "_").slice(-60);
    return join(tmpdir(), `mlx-bun-engine-${process.pid}-${slug}.sock`);
  }

  /** Route a request's `model` field to a child, spawning on first use.
   *  undefined/empty/unknown → the default child (drop-in semantics). */
  async childFor(modelField: string | undefined | null): Promise<EngineChild> {
    if (!modelField) return this.#use(this.defaultKey);
    // Already resident under this exact id?
    if (this.#children.has(modelField)) return this.#use(modelField);
    const rec = (() => {
      try { return this.opts.resolve(modelField); } catch { return null; }
    })();
    if (!rec) return this.#use(this.defaultKey); // unknown → ignore, like mlx-lm
    if (this.#children.has(rec.repoId)) return this.#use(rec.repoId);
    const inflight = this.#spawning.get(rec.repoId);
    if (inflight) return inflight.then(() => this.#use(rec.repoId));
    const spawnP = (async () => {
      const sock = this.#socketFor(rec.repoId);
      const child = new EngineChild({
        argv: [...this.opts.selfArgv, ...engineArgvForModel(this.opts.rawArgs, sock, rec.path)],
        socketPath: sock,
      });
      // SPAWN-OVERLAP: the old model keeps serving while this loads.
      await child.ready;
      this.#children.set(rec.repoId, child);
      this.#lru.push(rec.repoId);
      await this.#evictOverCap();
      return child;
    })();
    this.#spawning.set(rec.repoId, spawnP);
    try {
      return await spawnP;
    } finally {
      this.#spawning.delete(rec.repoId);
    }
  }

  #use(key: string): EngineChild {
    this.#bump(key);
    return this.#children.get(key)!;
  }

  /** Evict least-recently-used children over the cap: drain + demote (the
   *  child's caches spill to its SSD fingerprint dir), then stop. */
  async #evictOverCap(): Promise<void> {
    while (this.#children.size > Math.max(1, this.opts.poolMax)) {
      const victim = this.#lru.find((k) => this.#children.has(k));
      if (!victim || this.#children.size <= 1) return;
      const child = this.#children.get(victim)!;
      this.#children.delete(victim);
      this.#lru = this.#lru.filter((k) => k !== victim);
      try {
        await fetch("http://engine/admin/drain", {
          method: "POST",
          unix: child.spec.socketPath,
          signal: AbortSignal.timeout(120_000),
        } as RequestInit & { unix: string });
      } catch { /* best-effort — state also persists via evict-spill */ }
      child.stop();
      console.log(`[isolate] evicted engine ${victim} (pool cap ${this.opts.poolMax})`);
    }
  }

  stopAll(): void {
    for (const c of this.#children.values()) c.stop();
    this.#children.clear();
  }
}

/** Generation endpoints whose JSON body carries the routing `model` field. */
const MODEL_ROUTED = new Set([
  "/v1/chat/completions", "/v1/completions", "/v1/messages",
  "/v1/responses", "/v1/embeddings",
]);

export interface ProxyServerOptions {
  port: number;
  hostname?: string;
  engine: EngineSpec;
  /** Multi-model pool (P2). Omitted = single-engine P1 behavior. */
  pool?: {
    rawArgs: string[];
    selfArgv: string[];
    poolMax: number;
    resolve: ModelResolver;
    defaultKey: string;
    socketFor?: (repoId: string) => string;
  };
}

/** The parent server: UI-facing TCP listener that proxies to the engine
 *  child (or, with `pool`, to the request's model's child — P2 routing).
 *  Returns the Bun server + handles (tests kill/inspect). */
export function startProxyServer(opts: ProxyServerOptions): {
  server: ReturnType<typeof Bun.serve>;
  engine: EngineChild;
  pool: ModelPool | null;
} {
  const engine = new EngineChild(opts.engine);
  const pool = opts.pool
    ? new ModelPool({ ...opts.pool, defaultChild: engine })
    : null;
  const server = Bun.serve({
    port: opts.port,
    ...(opts.hostname ? { hostname: opts.hostname } : {}),
    idleTimeout: 0,
    async fetch(request) {
      const url = new URL(request.url);
      if (url.pathname === "/ws/chat")
        return Response.json(
          { error: { message: "WebSocket chat is not proxied under --isolate yet; run without --isolate for the web chat UI" } },
          { status: 501 },
        );
      if (url.pathname === "/engine" && request.method === "GET")
        return Response.json({
          isolated: true,
          pid: engine.pid,
          restarts: engine.restarts,
          socket: engine.spec.socketPath,
          ...(pool ? { pool: { resident: pool.residentKeys, default: pool.defaultKey } } : {}),
        });
      try {
        // P2 routing: generation endpoints carry `model` in the JSON body —
        // buffer it (small), pick/spawn that model's child, forward the
        // buffered body. Everything else rides the default engine.
        if (pool && request.method === "POST" && MODEL_ROUTED.has(url.pathname)) {
          const raw = await request.text();
          let modelField: string | undefined;
          try { modelField = (JSON.parse(raw) as { model?: string }).model; } catch { /* malformed → default child answers with its own 400 */ }
          const target = await pool.childFor(modelField);
          return await target.forward(new Request(request.url, {
            method: request.method,
            headers: request.headers,
            body: raw,
            signal: request.signal,
          }));
        }
        return await engine.forward(request);
      } catch (e) {
        if (request.signal.aborted) return new Response(null, { status: 499 });
        return Response.json(
          {
            error: {
              message: `inference engine unavailable (${(e as Error).message}) — respawning; retry shortly`,
              type: "engine_unavailable",
            },
          },
          { status: 502 },
        );
      }
    },
  });
  return { server, engine, pool };
}

/** serve's value-taking flags — needed to tell a flag VALUE from the bare
 *  model positional when stripping. Keep in sync with cli.ts serve opts
 *  (a stale entry here mis-classifies one token as a positional). */
const SERVE_VALUE_FLAGS = new Set([
  "--port", "--host", "--model", "--query", "--draft-model",
  "--num-draft-tokens", "--batch", "--decode-concurrency", "--kv-quant",
  "--kv-group-size", "--quantized-kv-start", "--kv-budget",
  "--memory-budget", "--prompt-cache", "--ssd-cache", "--ssd-cache-max",
  "--ssd-demote-idle", "--adapter", "--max-tokens", "--unix",
  "--model-pool", "--compiled-decode", "--compiled-activations",
  "--fused-sdpa", "--thinking",
]);
const PARENT_BOOL_FLAGS = new Set(["--isolate", "--open", "--no-open"]);
const PARENT_VALUE_FLAGS = new Set(["--port", "--host", "--model-pool"]);

/** Build the engine child's argv from the parent's raw CLI args: strip the
 *  parent-only flags (--isolate, --port/--host — the child binds the
 *  socket; --open/--no-open — the browser is the parent's business;
 *  --model-pool — pool policy is the parent's) and append the socket.
 *  Exported for tests. */
export function engineArgv(rawArgs: string[], socketPath: string): string[] {
  const out: string[] = [];
  for (let i = 0; i < rawArgs.length; i++) {
    const a = rawArgs[i]!;
    if (PARENT_BOOL_FLAGS.has(a)) continue;
    if (PARENT_VALUE_FLAGS.has(a)) { i++; continue; }
    out.push(a);
  }
  out.push("--unix", socketPath);
  return out;
}

/** engineArgv for a SPECIFIC model (the pool's per-model children): also
 *  strip every model selector — --model/--query values AND the bare
 *  positional query after `serve` — then pin `--model <path>`. */
export function engineArgvForModel(
  rawArgs: string[], socketPath: string, modelPath: string,
): string[] {
  const stripped: string[] = [];
  let positionalSkipped = false;
  for (let i = 0; i < rawArgs.length; i++) {
    const a = rawArgs[i]!;
    if (PARENT_BOOL_FLAGS.has(a)) continue;
    if (a === "--model" || a === "--query") { i++; continue; }
    if (PARENT_VALUE_FLAGS.has(a)) { i++; continue; }
    if (SERVE_VALUE_FLAGS.has(a)) { stripped.push(a, rawArgs[++i]!); continue; }
    if (!a.startsWith("-") && a !== "serve" && !positionalSkipped) {
      positionalSkipped = true; // the bare model query
      continue;
    }
    stripped.push(a);
  }
  if (stripped[0] !== "serve") stripped.unshift("serve");
  return [...stripped, "--model", modelPath, "--unix", socketPath];
}
