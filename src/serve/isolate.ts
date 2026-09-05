import { ExecutionCoordinator } from "../engine/execution-coordinator";
import { AdmissionPool, AdmissionRejected } from "../engine/admission";
import { acquireReservation } from "./preparation";
import { createParentApplication } from "./parent-application";
import type { DisposableResource } from "../contracts/resources";
import { retainResponseLease } from "./response-lease";
import type { EngineHost } from "../contracts/host";
// Runtime isolation — the parent half (docs/reference/server-config.md).
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
  /** Parent-owned activity lease; covers startup and complete response bodies. */
  acquire?: (signal: AbortSignal) => Promise<DisposableResource>;
  argv: string[];
  socketPath: string;
  /** Max ms to wait for the child's /health after spawn (weights load —
   *  large models take a while). Default 15 min. */
  readyTimeoutMs?: number;
  /** Bound automatic restarts in a rolling window, including startup failure. */
  maxRestarts?: number;
  restartWindowMs?: number;
  restartDelayMs?: number;
}

const HOP_BY_HOP = new Set([
  "connection", "keep-alive", "proxy-authenticate", "proxy-authorization",
  "te", "trailer", "transfer-encoding", "upgrade",
]);

export function defaultSocketPath(): string {
  return join(tmpdir(), `mlx-bun-engine-${process.pid}.sock`);
}

/** The persistent engine child: spawn, health-gate, respawn-on-crash. */
export class EngineChild implements EngineHost<Request, Response> {
  readonly spec: EngineSpec;
  #proc: ReturnType<typeof Bun.spawn> | null = null;
  #ready: Promise<void>;
  #stopping = false;
  #lifetime = new AbortController();
  restarts = 0;
  #lastSpawnAt = 0;
  #restartTimes: number[] = [];
  #backoff: ReturnType<typeof setTimeout> | undefined;
  #wakeBackoff: (() => void) | undefined;
  #startups = new Set<Promise<void>>();

  constructor(spec: EngineSpec) {
    this.spec = Object.freeze({ ...spec, argv: [...spec.argv] });
    this.#ready = this.#spawn();
    void this.#ready.catch(() => {}); // failures remain observable through ready/forward
  }

  get ready(): Promise<void> {
    return this.#ready;
  }

  get pid(): number | null {
    return this.#proc?.pid ?? null;
  }

  #spawn(): Promise<void> {
    const work = this.#start();
    this.#startups.add(work);
    void work.finally(() => this.#startups.delete(work)).catch(() => {});
    return work;
  }

  async #start(): Promise<void> {
    if (this.#stopping) throw new Error("engine host is closed");
    const lease = await this.spec.acquire?.(this.#lifetime.signal);
    let starting: ReturnType<typeof Bun.spawn> | undefined;
    let healthy = false;
    try {
      if (this.#stopping) throw new Error("engine host is closed");
      this.#lastSpawnAt = Date.now();
      try { unlinkSync(this.spec.socketPath); } catch {}
      const proc = Bun.spawn(this.spec.argv, {
        stdio: ["ignore", "inherit", "inherit"], // load progress → user's terminal
        env: process.env,
      });
      this.#proc = proc;
      starting = proc;
      void proc.exited.then((code) => {
        if (this.#stopping || this.#proc !== proc) return;
        const now = Date.now();
        const window = this.spec.restartWindowMs ?? 60_000;
        this.#restartTimes = this.#restartTimes.filter((time) => now - time < window);
        if (this.#restartTimes.length >= (this.spec.maxRestarts ?? 3)) {
          this.#ready = Promise.reject(new Error(`engine restart limit reached after exit ${code}`));
          void this.#ready.catch(() => {});
          return;
        }
        this.#restartTimes.push(now);
        console.error(`[isolate] engine exited (code ${code}) — respawning`);
        this.restarts++;
        // Crash-loop backoff: an engine that dies within 10 s of spawning
        // (bad flags, OOM on load) waits 5 s before the retry.
        const delay = this.spec.restartDelayMs ?? (Date.now() - this.#lastSpawnAt < 10_000 ? 5_000 : 0);
        this.#ready = new Promise<void>((resolve) => {
          this.#wakeBackoff = resolve;
          this.#backoff = setTimeout(resolve, delay);
        }).then(() => {
          this.#backoff = undefined; this.#wakeBackoff = undefined;
          return this.#spawn();
        });
        void this.#ready.catch(() => {});
      });
      // Health-gate: poll the child's /health over the socket until it
      // answers — model load happens behind this.
      const deadline = Date.now() + (this.spec.readyTimeoutMs ?? 15 * 60_000);
      while (Date.now() < deadline) {
        if (this.#stopping || proc.killed || proc.exitCode !== null || this.#proc !== proc)
          throw new Error("engine died during startup");
        try {
          const r = await fetch("http://engine/health", {
            unix: this.spec.socketPath,
            signal: AbortSignal.timeout(2_000),
          } as RequestInit & { unix: string });
          if (r.ok) { healthy = true; return; }
        } catch { /* not up yet */ }
        await new Promise((r) => setTimeout(r, 250));
      }
      proc.kill();
      throw new Error("engine did not become healthy in time");
    } finally {
      if (!healthy && starting && starting.exitCode === null) {
        starting.kill();
        const force = setTimeout(() => { if (starting!.exitCode === null) starting!.kill("SIGKILL"); }, 3000);
        try { await starting.exited; } finally { clearTimeout(force); }
      }
      lease?.dispose();
    }
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
    if (this.#stopping) throw new Error("engine host is closed");
    request.signal.throwIfAborted();
    await new Promise<void>((resolve, reject) => {
      const abort = () => { request.signal.removeEventListener("abort", abort); reject(request.signal.reason); };
      request.signal.addEventListener("abort", abort, { once: true });
      this.#ready.then(() => { request.signal.removeEventListener("abort", abort); resolve(); },
        (error) => { request.signal.removeEventListener("abort", abort); reject(error); });
    });
    if (this.#stopping) throw new Error("engine host is closed");
    request.signal.throwIfAborted();
    const signal = AbortSignal.any([request.signal, this.#lifetime.signal]);
    const lease = await this.spec.acquire?.(signal);
    try {
      signal.throwIfAborted();
      const headers = new Headers();
      request.headers.forEach((v, k) => {
        if (!HOP_BY_HOP.has(k.toLowerCase())) headers.set(k, v);
      });
      const proxied = await fetch(request.url, {
        method: request.method,
        headers,
        body: request.body,
        signal, // client abort → child sees the disconnect
        redirect: "manual",
        unix: this.spec.socketPath,
        // Streaming request bodies need half-duplex; buffered bodies ignore it.
        duplex: "half",
      } as RequestInit & { unix: string; duplex: string });
      const outHeaders = new Headers();
      proxied.headers.forEach((v, k) => {
        if (!HOP_BY_HOP.has(k.toLowerCase())) outHeaders.set(k, v);
      });
      const response = new Response(proxied.body, { status: proxied.status, headers: outHeaders });
      return lease ? retainResponseLease(response, lease) : response;
    } catch (error) { lease?.dispose(); throw error; }
  }

  /** A live UDS response owns the worker's native lease. Disconnect releases it
   * even if the parent crashes. External cancellation applies to acquisition;
   * the returned owner alone releases an admitted lease after job death. */
  async reserveExecution(signal: AbortSignal): Promise<DisposableResource> {
    if (!this.#proc || this.#proc.exitCode !== null) return { dispose() {} };
    const abort = new AbortController();
    const cancel = () => abort.abort(signal.reason);
    signal.throwIfAborted();
    signal.addEventListener("abort", cancel, { once: true });
    try {
      const response = await fetch("http://engine/admin/lease", {
        method: "POST", unix: this.spec.socketPath, signal: abort.signal,
      } as RequestInit & { unix: string });
      if (!response.ok) { await response.body?.cancel(); throw new Error(`worker lease failed (${response.status})`); }
      return { dispose() { abort.abort(); void response.body?.cancel().catch(() => {}); } };
    } catch (error) { abort.abort(); throw error; }
    finally { signal.removeEventListener("abort", cancel); }
  }

  stop(): void {
    this.#stopping = true;
    this.#lifetime.abort(new Error("engine host is closed"));
    clearTimeout(this.#backoff);
    this.#wakeBackoff?.();
    this.#proc?.kill();
    try { unlinkSync(this.spec.socketPath); } catch {}
  }

  async close(): Promise<void> {
    this.stop();
    const process = this.#proc;
    const force = process ? setTimeout(() => { if (process.exitCode === null) process.kill("SIGKILL"); }, 3000) : undefined;
    try {
      // Startup owns an admission lease even before a child exists. Earlier
      // crashed attempts can still be unwinding after #ready switches to a retry.
      await Promise.allSettled([this.#ready, ...this.#startups, ...(process ? [process.exited] : [])]);
    } finally { if (force) clearTimeout(force); }
  }
}

/** Model resolution the parent injects (Registry-backed in production;
 *  a plain map in tests). Returns null for unknown names — those keep the
 *  drop-in ignore semantics (served by the default model, like mlx-lm). */
export type ModelResolver = (query: string) => { repoId: string; path: string } | null;

/** Child-per-model pool (P2, docs/reference/server-config.md): LRU residency over
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
  #coldStarts = new AdmissionPool(1);
  #starting = new Set<EngineChild>();
  #stopping = false;
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
    if (this.#stopping) throw new Error("model pool is closed");
    modelField ||= this.defaultKey;
    // Already resident under this exact id?
    if (this.#children.has(modelField)) return this.#use(modelField);
    const rec = (() => {
      try { return this.opts.resolve(modelField); } catch { return null; }
    })();
    if (!rec && modelField !== this.defaultKey) return this.childFor(this.defaultKey);
    const resolved = rec ?? { repoId: this.defaultKey, path: "" };
    if (this.#children.has(resolved.repoId)) return this.#use(resolved.repoId);
    const inflight = this.#spawning.get(resolved.repoId);
    if (inflight) return inflight.then(() => this.#use(resolved.repoId));
    const spawnP = (async () => {
      const admission = await this.#coldStarts.acquire();
      try {
      if (this.#stopping) throw new Error("model pool is closed");
      const sock = this.#socketFor(resolved.repoId);
      const child = new EngineChild(resolved.repoId === this.defaultKey ? this.opts.defaultChild.spec : {
        argv: [...this.opts.selfArgv, ...engineArgvForModel(this.opts.rawArgs, sock, resolved.path)],
        socketPath: sock,
        acquire: this.opts.defaultChild.spec.acquire,
      });
      this.#starting.add(child);
      try {
        await child.ready;
        if (this.#stopping) throw new Error("model pool is closed");
        this.#children.set(resolved.repoId, child);
        this.#lru.push(resolved.repoId);
        await this.#evictOverCap();
        return child;
      } catch (error) {
        await child.close();
        throw error;
      } finally { this.#starting.delete(child); }
      } finally { admission.dispose(); }
    })();
    this.#spawning.set(resolved.repoId, spawnP);
    try {
      return await spawnP;
    } finally {
      this.#spawning.delete(resolved.repoId);
    }
  }

  #use(key: string): EngineChild {
    this.#bump(key);
    const child = this.#children.get(key);
    if (!child) throw new Error(`model ${key} is no longer resident`);
    return child;
  }

  /** Evict least-recently-used children over the cap: drain + demote (the
   *  child's caches spill to its SSD fingerprint dir), then stop. */
  async #evictOverCap(): Promise<void> {
    while (this.#children.size > Math.max(1, this.opts.poolMax)) {
      const victim = this.#lru.find((k) => this.#children.has(k));
      if (!victim || this.#children.size <= 1) return;
      const child = this.#children.get(victim)!;
      const lease = await child.spec.acquire?.(AbortSignal.timeout(120_000));
      try {
        // Another overlapping eviction may have completed while we waited.
        if (this.#children.get(victim) !== child) continue;
        this.#children.delete(victim);
        this.#lru = this.#lru.filter((k) => k !== victim);
        try {
          const response = await fetch("http://engine/admin/drain", {
            method: "POST", unix: child.spec.socketPath,
            signal: AbortSignal.timeout(120_000),
          } as RequestInit & { unix: string });
          await response.arrayBuffer();
        } catch { /* best-effort — state also persists via evict-spill */ }
        await child.close();
        console.log(`[isolate] evicted engine ${victim} (pool cap ${this.opts.poolMax})`);
      } finally { lease?.dispose(); }
    }
  }

  stopAll(): void {
    this.#stopping = true;
    this.#coldStarts.close();
    for (const child of new Set([...this.#children.values(), ...this.#starting])) child.stop();
    this.#children.clear();
    this.#lru = [];
  }

  async close(): Promise<void> {
    const children = new Set([...this.#children.values(), ...this.#starting]);
    this.stopAll();
    await Promise.all([...children].map((child) => child.close()));
    await Promise.allSettled(this.#spawning.values());
  }
}

/** Generation endpoints whose JSON body carries the routing `model` field. */
const MODEL_ROUTED = new Set([
  "/v1/chat/completions", "/v1/completions", "/v1/messages",
  "/v1/responses", "/v1/embeddings",
]);

export interface ProxyServerOptions {
  /** Application-store injection for embedded hosts and model-free tests. */
  createJobStore?: () => Promise<import("../jobs/db").JobStore>;
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
  close(): Promise<void>;
} {
  const coordinator = new ExecutionCoordinator();
  const acquire = (mode: "shared" | "exclusive", signal: AbortSignal) =>
    acquireReservation({ acquire: (cancellation) => coordinator.acquire(mode, cancellation) }, signal);
  const engine = new EngineChild({ ...opts.engine, async acquire(signal) {
    const parent = await acquire("shared", signal);
    try {
      const supplied = await opts.engine.acquire?.(signal);
      return { dispose() { try { supplied?.dispose(); } finally { parent.dispose(); } } };
    } catch (error) { parent.dispose(); throw error; }
  } });
  const pool = opts.pool
    ? new ModelPool({ ...opts.pool, defaultChild: engine })
    : null;
  const children = () => pool ? pool.residentKeys.map((key) => pool.child(key)!).filter(Boolean) : [engine];
  const forwardRequest = async (request: Request): Promise<Response> => {
    const url = new URL(request.url);
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
    return await (pool ? await pool.childFor(undefined) : engine).forward(request);
  };
  const application = createParentApplication({
    createJobStore: opts.createJobStore,
    serverPort: () => server.port,
    async acquireGpu(signal) {
      const lease = await acquire("exclusive", signal);
      try {
        // Network cancellation is not a native completion fence. Explicitly
        // drain every resident worker before the subprocess may touch the GPU.
        const results = await Promise.allSettled(children().map((child) => child.reserveExecution(signal)));
        const held = results.filter((result) => result.status === "fulfilled").map((result) => result.value);
        const failed = results.find((result) => result.status === "rejected");
        if (failed) { for (const worker of held) worker.dispose(); throw failed.reason; }
        return { dispose() { for (const worker of held) worker.dispose(); lease.dispose(); } };
      } catch (error) { lease.dispose(); throw error; }
    },
    invalidateLibrary() {
      for (const child of children()) void child.forward(new Request("http://engine/library?refresh=1"))
        .then((response) => response.arrayBuffer()).catch(() => {});
    },
  });
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
      if (url.pathname === "/engine" && request.method === "GET") {
        // A pool may have evicted and recreated the default worker. Inspect
        // current residency without starting a worker merely for diagnostics.
        const current = pool ? pool.child(pool.defaultKey) : engine;
        return Response.json({
          isolated: true,
          response_store: application.responseStats,
          pid: current?.pid ?? null,
          restarts: current?.restarts ?? null,
          socket: current?.spec.socketPath ?? null,
          ...(pool ? { pool: { resident: pool.residentKeys, default: pool.defaultKey } } : {}),
        });
      }
      try {
        const local = await application.handle(request, forwardRequest);
        if (local) return local;
        return await forwardRequest(request);
      } catch (e) {
        if (e instanceof AdmissionRejected) return Response.json(
          { error: { message: e.message, type: "resource_admission", code: "queue_full" } }, { status: 429 });
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
  let closing: Promise<void> | undefined;
  return { server, engine, pool, close: () => closing ??= (async () => {
    await server.stop(true);
    coordinator.close();
    await application.close();
    if (pool) await pool.close(); else await engine.close();
  })() };
}

/** serve's value-taking flags — needed to tell a flag VALUE from the bare
 *  model positional when stripping. Keep in sync with cli.ts serve opts
 *  (a stale entry here mis-classifies one token as a positional). */
const SERVE_VALUE_FLAGS = new Set([
  "--port", "--host", "--model", "--query", "--draft-model",
  "--num-draft-tokens", "--draft-kind", "--ngram-max", "--ngram-min",
  "--batch", "--decode-concurrency", "--kv-quant",
  "--kv-group-size", "--quantized-kv-start", "--kv-budget",
  "--memory-budget", "--prompt-cache", "--ssd-cache", "--ssd-cache-max",
  "--ssd-demote-idle", "--generation-checkpoint", "--adapter", "--max-tokens", "--unix",
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
