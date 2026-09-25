// Job log → SSE. `tailJob` is an async generator over a job's NDJSON log
// (offset-seek read, partial-line tolerant, polls while the row is
// non-terminal — port of optiq lab jobs.py `tail`). `streamJobResponse`
// wraps it in a Bun `Response` whose body is an EventSource-compatible SSE
// stream, matching the writer style in src/server.ts.

import type { JobEvent, JobStatus } from "./protocol";
import type { JobStore } from "./db";

const TERMINAL: ReadonlySet<JobStatus> = new Set<JobStatus>(["done", "failed", "zombie"]);

export interface TailOpts {
  /** Keep polling while the job is non-terminal (SSE use case). When false,
   *  yield what's currently logged and stop. */
  follow?: boolean;
  signal?: AbortSignal;
  /** Poll interval in ms while waiting for new lines. */
  pollMs?: number;
}

/** Yield each recorded JobEvent from a job's log in order. Reads from a held
 *  byte offset, buffers a trailing partial line until its newline arrives
 *  (tolerates a writer mid-line), and — when following — polls until the row
 *  is terminal, then drains any final lines and stops. */
export async function* tailJob(
  store: JobStore,
  jobId: string,
  opts: TailOpts = {},
): AsyncIterable<JobEvent> {
  const follow = opts.follow ?? true;
  const pollMs = opts.pollMs ?? 200;

  const row = store.get(jobId);
  if (!row) throw new Error(`job ${jobId} not found`);
  const logPath = row.log_path;

  let offset = 0;
  let buf = "";

  for (;;) {
    if (opts.signal?.aborted) return;
    const file = Bun.file(logPath);
    const size = await file.size;
    if (size > offset) {
      const slice = file.slice(offset, size);
      buf += await slice.text();
      offset = size;

      let nl: number;
      while ((nl = buf.indexOf("\n")) !== -1) {
        const line = buf.slice(0, nl).trim();
        buf = buf.slice(nl + 1);
        if (!line) continue;
        try {
          yield JSON.parse(line) as JobEvent;
        } catch {
          // partial / corrupt line: re-buffer it and wait for more bytes
          buf = line + "\n" + buf;
          break;
        }
      }
    }

    if (!follow || opts.signal?.aborted) return;

    const status = store.get(jobId)?.status;
    if (status && TERMINAL.has(status)) {
      // Drain any bytes written between the last read and the terminal flip.
      const f = Bun.file(logPath);
      const sz = await f.size;
      if (sz > offset) {
        buf += await f.slice(offset, sz).text();
        offset = sz;
      }
      for (const line of buf.split("\n")) {
        const s = line.trim();
        if (!s) continue;
        try { yield JSON.parse(s) as JobEvent; } catch { /* drop trailing partial */ }
      }
      return;
    }

    await new Promise<void>(resolve => {
      const done = () => { clearTimeout(timer); opts.signal?.removeEventListener("abort", done); resolve(); };
      const timer = setTimeout(done, pollMs);
      opts.signal?.addEventListener("abort", done, { once: true });
      if (opts.signal?.aborted) done();
    });
  }
}

/** Build an SSE `Response` streaming a job's events. Writes `retry: 1500`
 *  first (so EventSource fires `onopen`), then one `data:` frame per event,
 *  and finally an `event: end` marker before closing on terminal. */
export function streamJobResponse(store: JobStore, jobId: string, signal?: AbortSignal): Response {
  const cancellation = new AbortController();
  const abort = () => cancellation.abort();
  signal?.addEventListener("abort", abort, { once: true });
  if (signal?.aborted) abort();
  let cancelled = false;
  const stream = new ReadableStream<Uint8Array>({
    async start(controller) {
      const enc = new TextEncoder();
      const send = (text: string) => { if (!cancellation.signal.aborted) controller.enqueue(enc.encode(text)); };
      try {
        send("retry: 1500\n\n");
        for await (const event of tailJob(store, jobId, { signal: cancellation.signal })) {
          send(`data: ${JSON.stringify(event)}\n\n`);
        }
        send("event: end\ndata: {}\n\n");
      } catch (e) {
        const error = e instanceof Error ? e.message : String(e);
        send(`data: ${JSON.stringify({ type: "failed", error, ts: Date.now() })}\n\n`);
        send("event: end\ndata: {}\n\n");
      } finally {
        signal?.removeEventListener("abort", abort);
        if (!cancelled) controller.close();
      }
    },
    cancel() { cancelled = true; abort(); },
  });
  return new Response(stream, { headers: {
    "content-type": "text/event-stream", "cache-control": "no-cache", connection: "keep-alive",
  } });
}
