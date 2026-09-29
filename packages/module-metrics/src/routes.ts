// The module's HTTP handlers, declared in `manifest.ts` and mounted by the
// host under `/api/metrics`. They read the store, the history directory and the
// job service; none loads a model or blocks the scheduler.
import type { JobRecord, JobService, RouteHandler, StorageService, Unsubscribe } from "@mlx-bun/app-core";
import { listHistory, listProfiles, readHistory, resolvePlan } from "./bench";
import type { BenchJob } from "./protocol";
import type { MetricsStore } from "./store";

export interface StreamTimers {
  setTimeout(run: () => void, ms: number): unknown;
  clearTimeout(handle: unknown): void;
  setInterval(run: () => void, ms: number): unknown;
  clearInterval(handle: unknown): void;
}

export interface MetricsRoutesOptions {
  store: MetricsStore;
  storage: Pick<StorageService, "path">;
  jobs: JobService;
  /** Calls `listener` after the store changed; how the stream learns to send. */
  onChange(listener: () => void): Unsubscribe;
  /** The panel element's browser module, or undefined where the source is not available. */
  panel?: () => Promise<string | undefined>;
  /** Fewest milliseconds between two snapshots on one stream. Default 500. */
  minIntervalMs?: number;
  /** Milliseconds between comment frames that keep an idle connection open. Default 15 000. */
  keepAliveMs?: number;
  timers?: StreamTimers;
  now?: () => number;
  /** Aborts when the host stops the module; open streams end. */
  signal?: AbortSignal;
}

const realTimers: StreamTimers = {
  setTimeout: (run, ms) => setTimeout(run, ms), clearTimeout: handle => clearTimeout(handle as ReturnType<typeof setTimeout>),
  setInterval: (run, ms) => setInterval(run, ms), clearInterval: handle => clearInterval(handle as ReturnType<typeof setInterval>),
};

const error = (message: string, status: number) => Response.json({ error: { message, type: status >= 500 ? "server_error" : "invalid_request_error" } }, { status });
const job = (record: JobRecord): BenchJob => ({ id: record.id, status: record.status, progress: record.progress, message: record.message, error: record.error,
  startedAt: record.startedAt, endedAt: record.endedAt });
const idOf = (request: Request) => new URL(request.url).pathname.split("/").at(-1) ?? "";

export function createMetricsRoutes(options: MetricsRoutesOptions) {
  const { store, storage, jobs } = options, timers = options.timers ?? realTimers, now = options.now ?? Date.now;
  const minInterval = options.minIntervalMs ?? 500, keepAlive = options.keepAliveMs ?? 15_000;
  const encoder = new TextEncoder();
  const benchJob = async (id: string) => {
    const record = await jobs.get(id);
    return record?.kind === "bench-serve" ? record : undefined;
  };

  const stream: RouteHandler = request => {
    // Set by `start`; `pull` and `cancel` call them once the reader acts.
    let schedule = () => {}, closeStream = () => {};
    const body = new ReadableStream<Uint8Array>({
      start(controller) {
        let sentVersion = -1, sentAt = -Infinity, pending: unknown = null, closed = false, ends: AbortSignal | undefined;
        const send = () => {
          pending = null;
          if (closed || store.version === sentVersion) return;
          // A reader that has not consumed the last frames skips this one; its next pull, or the next change, sends the newer state.
          if ((controller.desiredSize ?? 1) <= 0) return;
          controller.enqueue(encoder.encode(`event: snapshot\ndata: ${JSON.stringify(store.snapshot())}\n\n`));
          sentVersion = store.version; sentAt = now();
        };
        schedule = () => {
          if (closed || pending !== null || store.version === sentVersion) return;
          pending = timers.setTimeout(send, Math.max(0, minInterval - (now() - sentAt)));
        };
        const off = options.onChange(schedule);
        const beat = timers.setInterval(() => { if (!closed && (controller.desiredSize ?? 1) > 0) controller.enqueue(encoder.encode(": keepalive\n\n")); }, keepAlive);
        closeStream = () => {
          if (closed) return;
          closed = true; off(); timers.clearInterval(beat);
          if (pending !== null) timers.clearTimeout(pending);
          ends?.removeEventListener("abort", closeStream);
          try { controller.close(); } catch { /* already closed by the reader */ }
        };
        controller.enqueue(encoder.encode("retry: 1500\n\n"));
        send();
        ends = options.signal ? AbortSignal.any([request.signal, options.signal]) : request.signal;
        ends.addEventListener("abort", closeStream, { once: true });
        if (ends.aborted) closeStream();
      },
      pull() { schedule(); },
      cancel() { closeStream(); },
    }, { highWaterMark: 4 });
    return new Response(body, { headers: { "content-type": "text/event-stream", "cache-control": "no-cache", connection: "keep-alive" } });
  };

  return {
    snapshot: (() => Response.json(store.snapshot())) as RouteHandler,
    stream,
    history: (request => {
      const limit = Number(new URL(request.url).searchParams.get("limit") ?? "50");
      return Response.json({ runs: listHistory(storage, Number.isFinite(limit) ? limit : 50) });
    }) as RouteHandler,
    "history-entry": (request => {
      const entry = readHistory(storage, idOf(request));
      return entry ? Response.json(entry) : error("no such run", 404);
    }) as RouteHandler,
    profiles: (() => Response.json({ profiles: listProfiles(storage) })) as RouteHandler,
    "bench-start": (async request => {
      let body: Record<string, unknown>;
      try { body = await request.json() as Record<string, unknown>; } catch { return error("body must be JSON", 400); }
      if (!body || typeof body !== "object" || Array.isArray(body)) return error("body must be a JSON object", 400);
      // Only a named profile: a plan carries the commands bench-serve starts, so a request never points at an arbitrary file.
      const { profile } = body;
      if (typeof profile !== "string") return error("name a profile (see /bench/profiles)", 400);
      try { resolvePlan(storage, { profile }); }
      catch (failure) { return error(failure instanceof Error ? failure.message : String(failure), 400); }
      try { return Response.json(job(await jobs.submit({ kind: "bench-serve", config: { profile } })), { status: 202 }); }
      catch (failure) { return error(failure instanceof Error ? failure.message : String(failure), 409); }
    }) as RouteHandler,
    "bench-list": (async () => Response.json({ jobs: (await jobs.list({ kind: "bench-serve" })).map(job) })) as RouteHandler,
    "bench-job": (async request => {
      const record = await benchJob(idOf(request));
      return record ? Response.json(job(record)) : error("no such job", 404);
    }) as RouteHandler,
    "bench-cancel": (async request => {
      const record = await benchJob(idOf(request));
      if (!record) return error("no such job", 404);
      await jobs.cancel(record.id);
      return Response.json(job((await jobs.get(record.id)) ?? record));
    }) as RouteHandler,
    panel: (async () => {
      const source = await options.panel?.();
      return source === undefined ? error("the panel source is not available in this build", 404)
        : new Response(source, { headers: { "content-type": "text/javascript; charset=utf-8", "cache-control": "no-cache" } });
    }) as RouteHandler,
  } as const;
}
