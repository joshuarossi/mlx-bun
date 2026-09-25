import { expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createPiBackend } from "../src/chat/pi-backend";
import { createSessionRoutes } from "../src/server/session-routes";
import type { AgentSessionRuntime } from "@earendil-works/pi-coding-agent";
import type { ServerMessage } from "../src/chat/protocol";

async function bounded<T>(work: Promise<T>): Promise<T> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    return await Promise.race([work, new Promise<T>((_, reject) => {
      timer = setTimeout(() => reject(new Error("Pi loopback smoke timed out")), 3_000);
    })]);
  } finally { if (timer) clearTimeout(timer); }
}

/** Real Pi SDK runtime and HTTP provider; fixed loopback SSE is the only model. */
test("Pi startup, provider hooks, streamed reply, and transcripts stay in app-supplied paths", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-pi-runtime-"));
  const cwd = join(root, "project"), agentDir = join(root, "agent"), sessionDir = join(root, "sessions");
  const toolApprovalsFile = join(root, "approvals.json");
  mkdirSync(cwd); mkdirSync(agentDir);
  writeFileSync(toolApprovalsFile, JSON.stringify({ version: 1, allows: { "test-tool": true } }));
  // Resource discovery is disabled for the web backend. Even resources in its
  // own isolated agent/project roots must not become extensions or context.
  mkdirSync(join(agentDir, "extensions"));
  writeFileSync(join(agentDir, "extensions", "must-not-run.ts"), 'throw new Error("unexpected discovered extension");');
  writeFileSync(join(cwd, "AGENTS.md"), "DO_NOT_INCLUDE_PROJECT_CONTEXT_SENTINEL");
  const requests: { path: string; body: Record<string, unknown>; headers: Headers }[] = [];
  const frames: ServerMessage[] = [];
  const streaming = Promise.withResolvers<void>();
  const streamClosed = Promise.withResolvers<void>();
  let backend: ReturnType<ReturnType<typeof createPiBackend>> | undefined;
  const sessions = createSessionRoutes(sessionDir);
  const server = Bun.serve({ hostname: "127.0.0.1", port: 0, async fetch(request) {
    const sessionResponse = await sessions.handle(request);
    if (sessionResponse) return sessionResponse;
    const body = await request.json() as Record<string, unknown>;
    requests.push({ path: new URL(request.url).pathname, body, headers: request.headers });
    const chunk = (delta: Record<string, unknown>, finish_reason: string | null) => ({
      id: "local-smoke", object: "chat.completion.chunk", created: 1, model: "local",
      choices: [{ index: 0, delta, finish_reason }],
    });
    if (requests.length === 2) {
      return new Response(new ReadableStream<Uint8Array>({
        start(controller) {
          controller.enqueue(new TextEncoder().encode(`data: ${JSON.stringify(chunk({ role: "assistant", content: "Cancel this reply." }, null))}\n\n`));
        },
        cancel() { streamClosed.resolve(); },
      }), { headers: { "content-type": "text/event-stream" } });
    }
    return new Response([
      `data: ${JSON.stringify(chunk({ role: "assistant", content: "Isolated reply." }, null))}\n\n`,
      `data: ${JSON.stringify(chunk({}, "stop"))}\n\n`, "data: [DONE]\n\n",
    ].join(""), { headers: { "content-type": "text/event-stream" } });
  } });
  try {
    backend = createPiBackend({ port: server.port!, paths: { cwd, agentDir, sessionDir, toolApprovalsFile },
      readOnly: true, modelId: "smoke-model", genDefaults: { temperature: 0.2, topP: 0.9, topK: 20 },
    })(frame => {
      frames.push(frame);
      if (frame.type === "text_delta" && frame.delta.includes("Cancel this reply.")) streaming.resolve();
    });
    await bounded(backend.start());
    const runtime = (backend as unknown as { runtime: AgentSessionRuntime }).runtime;
    expect(runtime.services.cwd).toBe(cwd); expect(runtime.services.agentDir).toBe(agentDir);
    expect(runtime.session.sessionManager.getSessionDir()).toBe(sessionDir);
    expect(frames.find(frame => frame.type === "ready")).toMatchObject({ model: "smoke-model", transcription: false });
    expect(frames.find(frame => frame.type === "tool_approvals")).toMatchObject({ alwaysAllow: ["test-tool"] });
    await backend.handle({ type: "set_sampling", temperature: 0.25, scope: "next_turn" });
    await bounded(backend.handle({ type: "prompt", text: "Say a short greeting without tools." }));
    expect(requests).toHaveLength(1);
    expect(requests[0]!.path).toBe("/v1/chat/completions");
    expect(requests[0]!.body).toMatchObject({ model: "local", stream: true, temperature: 0.25 });
    expect(JSON.stringify(requests[0]!.body)).not.toContain("DO_NOT_INCLUDE_PROJECT_CONTEXT_SENTINEL");
    expect(frames.filter(frame => frame.type === "text_delta").map(frame => frame.delta).join("")).toBe("Isolated reply.");
    expect(frames.some(frame => frame.type === "turn_end")).toBe(true);
    expect(frames.filter(frame => frame.type === "error" || frame.type === "tool_start")).toEqual([]);
    const cancelled = backend.handle({ type: "prompt", text: "This turn will be cancelled." });
    await bounded(streaming.promise);
    await bounded(backend.handle({ type: "abort" }));
    await bounded(cancelled);
    await bounded(streamClosed.promise);
    expect(requests).toHaveLength(2);
    expect(frames.filter(frame => frame.type === "turn_end")).toHaveLength(2);
    expect(frames.filter(frame => frame.type === "tool_start")).toEqual([]);
    await bounded(Promise.resolve(backend.dispose())); backend = undefined;
    const files = readdirSync(sessionDir).filter(file => file.endsWith(".jsonl"));
    expect(files).toHaveLength(1);
    const transcript = readFileSync(join(sessionDir, files[0]!), "utf8");
    expect(transcript).toContain("Isolated reply."); expect(transcript).toContain("Say a short greeting without tools.");
    expect(transcript).toContain(cwd);
    const searched = await fetch(new URL("/api/sessions/search?q=Isolated", server.url));
    const found = await searched.json();
    expect(found.ok).toBe(true); expect(found.results).toHaveLength(1);
    expect(found.results[0].sessionPath).toBe(join(sessionDir, files[0]!));
    const exported = await fetch(new URL(`/api/sessions/export?${new URLSearchParams({ path: found.results[0].sessionPath })}`, server.url));
    const saved = await exported.json();
    expect(saved.ok).toBe(true); expect(JSON.stringify(saved.entries)).toContain("Isolated reply.");
    expect(existsSync(join(agentDir, "auth.json"))).toBe(false); // provider credentials stay in memory
    expect(JSON.parse(readFileSync(toolApprovalsFile, "utf8"))).toEqual({ version: 1, allows: { "test-tool": true } });
  } finally {
    await server.stop(true);
    try { await bounded(Promise.resolve(backend?.dispose())); }
    finally { rmSync(root, { recursive: true, force: true }); }
  }
}, 15_000);
