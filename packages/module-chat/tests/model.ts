// A scripted model host for the module's tests: the operations a real host leases (`generate` over the OpenAI wire and the
// discovery routes), with each lease counted so a test can prove none is left held.
import type { ModelHost, ModelLease } from "@mlx-bun/app-core";

export interface ScriptedTurn {
  text?: string;
  tool?: { name: string; args: Record<string, unknown> };
  /** The stream stays open after its first frame until this settles (a turn still generating). */
  gate?: Promise<void>;
}

export interface ScriptedModel extends ModelHost {
  /** What each chat completion the model answered was sent, oldest first. */
  readonly requests: { readonly headers: Headers; readonly body: Record<string, unknown> }[];
  /** Leases granted and not yet released. */
  readonly held: number;
  /** The turns still to answer; a test pushes the script for its prompt. */
  readonly script: ScriptedTurn[];
  current: string | undefined;
  /** Replaces the discovery row the model reports for itself. */
  row: Record<string, unknown>;
  /** What `/stats` answers (the enforced context lives under `admission`). */
  serverStats: Record<string, unknown>;
}

const chunk = (delta: Record<string, unknown>, finish: string | null) => ({ id: "scripted", object: "chat.completion.chunk", created: 1, model: "local", choices: [{ index: 0, delta, finish_reason: finish }] });

function stream(turn: ScriptedTurn, signal: AbortSignal): Response {
  const frames = turn.tool
    ? [chunk({ role: "assistant", tool_calls: [{ index: 0, id: "call-1", type: "function", function: { name: turn.tool.name, arguments: JSON.stringify(turn.tool.args) } }] }, null), chunk({}, "tool_calls")]
    : [chunk({ role: "assistant", content: turn.text ?? "" }, null), chunk({}, "stop")];
  const encoder = new TextEncoder();
  const sse = (frame: unknown) => encoder.encode(`data: ${JSON.stringify(frame)}\n\n`);
  const body = new ReadableStream<Uint8Array>({
    async start(controller) {
      controller.enqueue(sse(frames[0]));
      if (turn.gate) {
        // A client that goes away ends the stream, as the engine's does.
        const aborted = new Promise<void>(resolve => signal.addEventListener("abort", () => resolve(), { once: true }));
        await Promise.race([turn.gate, aborted]);
        if (signal.aborted) { controller.close(); return; }
      }
      for (const frame of frames.slice(1)) controller.enqueue(sse(frame));
      controller.enqueue(encoder.encode("data: [DONE]\n\n"));
      controller.close();
    },
  });
  return new Response(body, { headers: { "content-type": "text/event-stream" } });
}

export function scriptedModel(id = "org/scripted"): ScriptedModel {
  let held = 0;
  const model: ScriptedModel = {
    requests: [], script: [], current: id,
    get held() { return held; },
    row: { vision: false, audio: false, reasoning: false, context_window: 4096, gen_defaults: { temperature: 0.7, top_p: 0.9, top_k: null }, capabilities: { transcription: false } },
    serverStats: { admission: { enforced_context_tokens: 2048 } },
    policy: { budgetBytes: 1, pinned: [], idleUnloadSec: 0 },
    async defaultFor() { return model.current; },
    async acquire(requested, options) {
      if (requested !== model.current) throw Object.assign(new Error(`model ${requested} is not the served model`), { code: "does-not-fit" });
      held++;
      let released = false;
      const lease: ModelLease = { model: { id: requested, role: "primary", state: "ready", operations: ["generate"], bytes: 1, pinned: true, leases: held, lastUsedAt: 0 }, loadMs: 0,
        operations: { async generate(request) {
          const url = new URL(request.url);
          if (url.pathname === "/v1/models") return Response.json({ object: "list", data: [{ id: requested, object: "model", current: true, ...model.row }] });
          if (url.pathname === "/stats") return Response.json(model.serverStats);
          if (url.pathname === "/v1/chat/completions") {
            model.requests.push({ headers: request.headers, body: await request.json() as Record<string, unknown> });
            return stream(model.script.shift() ?? { text: "(no script)" }, request.signal);
          }
          return new Response("not found", { status: 404 });
        } },
        release() { if (!released) { released = true; held--; } } };
      void options;
      return lease;
    },
    async plan() { return { fits: true, requiredBytes: 0, freeBytes: 0, evict: [] }; },
    async serve(id) { model.current = id; },
    async unload() {}, pin() {}, unpin() {}, resident: () => [],
    stats: () => ({ resident: true, loads: 1, unloads: 0, lastLoadMs: 0, idleUnloadSec: null }),
  };
  return model;
}
