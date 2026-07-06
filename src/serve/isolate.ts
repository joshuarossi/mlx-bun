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

export interface ProxyServerOptions {
  port: number;
  hostname?: string;
  engine: EngineSpec;
}

/** The parent server: UI-facing TCP listener that proxies to the engine
 *  child. Returns the Bun server + the child handle (tests kill/inspect). */
export function startProxyServer(opts: ProxyServerOptions): {
  server: ReturnType<typeof Bun.serve>;
  engine: EngineChild;
} {
  const engine = new EngineChild(opts.engine);
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
        });
      try {
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
  return { server, engine };
}

/** Build the engine child's argv from the parent's raw CLI args: strip the
 *  parent-only flags (--isolate, --port/--host — the child binds the
 *  socket; --open/--no-open — the browser is the parent's business) and
 *  append the socket. Exported for tests. */
export function engineArgv(rawArgs: string[], socketPath: string): string[] {
  const PARENT_FLAGS_WITH_VALUE = new Set(["--port", "--host"]);
  const PARENT_BOOL_FLAGS = new Set(["--isolate", "--open", "--no-open"]);
  const out: string[] = [];
  for (let i = 0; i < rawArgs.length; i++) {
    const a = rawArgs[i]!;
    if (PARENT_BOOL_FLAGS.has(a)) continue;
    if (PARENT_FLAGS_WITH_VALUE.has(a)) { i++; continue; }
    out.push(a);
  }
  out.push("--unix", socketPath);
  return out;
}
