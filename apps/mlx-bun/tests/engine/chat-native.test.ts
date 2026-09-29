// Opt-in real-weight check of the web chat: a served model, the browser's WebSocket, a read-only tool call, and the saved
// chat reopened. It exercises the whole path (socket, Pi SDK, the model host's wire, the engine) with greedy sampling, and
// when `MLX_BUN_CHAT_TRANSCRIPT` names a file it writes the transcript's structure there, so two builds of the app can be
// compared byte for byte. Uses an already-downloaded autoregressive model whose chat template supports tools
// (`MLX_BUN_APP_TEST_MODEL=<snapshot directory>`), never downloads one; a supplied invalid path or a missing native
// runtime fails rather than skips.
import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const modelDir = process.env.MLX_BUN_APP_TEST_MODEL, transcriptFile = process.env.MLX_BUN_CHAT_TRANSCRIPT;

type Frame = { type: string; [key: string]: unknown };

test.skipIf(!modelDir)("web chat over a real served model: a greedy prompt makes a read-only memory tool call, and the saved chat reopens with the same transcript", async () => {
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const model = await scanSnapshot(modelDir!, "test-model");
  if (!model) throw new Error("Model path has no loadable checkpoint");
  const root = mkdtempSync(join(tmpdir(), "mlx-chat-native-"));
  const cwd = join(root, "project"), vault = join(root, "vault"), sessions = join(root, "sessions");
  mkdirSync(cwd); mkdirSync(join(vault, "articles"), { recursive: true });
  writeFileSync(join(vault, "articles", "Travel.md"), "# Travel\n\nTravel preferences.\n\n## Preference\n\nTake the early train.\n");
  const options = parseServeOptions({ values: { port: "0", "prompt-cache": "0.125", "no-open": true, thinking: "off", "ssd-cache": join(root, "ssd"), "memory-budget": "12" }, positionals: [] });
  options.contextLimit = 6_000;
  options.readOnly = true;
  options.chatPaths = { cwd, agentDir: join(root, "agent"), sessionDir: sessions, toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault, skills: join(root, "skills") };
  let app: Awaited<ReturnType<typeof startModelServer>> | undefined;
  const budget = AbortSignal.timeout(150_000);
  try {
    app = await startModelServer(model, options);
    const frames: Frame[] = [];
    const socket = new WebSocket(`ws://127.0.0.1:${app.port}/ws/chat`);
    const observers = new Set<() => void>();
    socket.addEventListener("message", event => { frames.push(JSON.parse(String(event.data)) as Frame); for (const observer of [...observers]) observer(); });
    const waitFor = (predicate: () => boolean, what: string) => new Promise<void>((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error(`timed out waiting for ${what}`)), 120_000);
      const check = () => { if (frames.some(frame => frame.type === "error")) { clearTimeout(timer); reject(new Error(`chat error: ${JSON.stringify(frames.find(frame => frame.type === "error"))}`)); }
        else if (predicate()) { clearTimeout(timer); observers.delete(check); resolve(); } };
      observers.add(check); budget.addEventListener("abort", () => reject(new Error("budget exhausted")), { once: true }); check();
    });
    const send = (message: Frame) => socket.send(JSON.stringify(message));
    await waitFor(() => frames.some(frame => frame.type === "ready"), "ready");
    send({ type: "set_thinking", enabled: false });
    send({ type: "set_sampling", temperature: 0 });
    const prompt = 'Use the memory_section tool with stem "Travel" and anchor "Preference", then tell me in one sentence what it says.';
    send({ type: "prompt", text: prompt });
    // The tool round trip: a turn calls the tool, and a later turn answers with its result.
    await waitFor(() => { const end = frames.findIndex(frame => frame.type === "tool_end"); return end >= 0 && frames.slice(end).some(frame => frame.type === "turn_end"); }, "the answer after the tool call");
    const listing = frames.findLast(frame => frame.type === "sessions" && frame.activePath) as Frame | undefined;
    if (!listing?.activePath) throw new Error("no persisted chat path");
    const before = frames.length;
    send({ type: "open_session", path: listing.activePath });
    await waitFor(() => frames.slice(before).some(frame => frame.type === "history"), "the reopened chat");
    socket.close();

    const live = frames.filter(frame => ["turn_start", "tool_start", "tool_end", "tool_approval_request", "turn_end"].includes(frame.type)).map(frame =>
      frame.type === "tool_start" ? { type: frame.type, tool: frame.tool, args: frame.args }
        : frame.type === "tool_end" ? { type: frame.type, ok: frame.ok } : { type: frame.type });
    const text = frames.filter(frame => frame.type === "text_delta").map(frame => frame.delta).join("");
    const history = ((frames.slice(before).find(frame => frame.type === "history") as Frame).items as { role: string; text: string; thinking?: string; tools: { name: string; args: unknown; result: string }[] }[])
      .map(item => ({ role: item.role, text: item.text, thinking: item.thinking ?? null, tools: item.tools.map(tool => ({ name: tool.name, args: tool.args, result: tool.result })) }));
    const ready = frames.find(frame => frame.type === "ready") as Frame;
    const transcript = { ready, prompt, live, text, history };
    if (transcriptFile) writeFileSync(transcriptFile, JSON.stringify(transcript, null, 2) + "\n");

    // A read-only tool ran without an approval card, with arguments the model chose, and its result is in the saved chat.
    expect(live.filter(frame => frame.type === "tool_approval_request")).toEqual([]);
    const called = live.filter(frame => frame.type === "tool_start");
    expect(called.length).toBeGreaterThan(0);
    expect(called[0]).toMatchObject({ tool: "memory_section" });
    expect(history[0]).toMatchObject({ role: "user", text: prompt });
    const calls = history.flatMap(item => item.tools);
    expect(calls.length).toBe(called.length);
    expect(calls[0]!.result).toContain("Take the early train");
    expect(history.at(-1)!.role).toBe("assistant");
    expect(text.trim().length).toBeGreaterThan(0);
    expect(history.filter(item => item.role === "assistant").map(item => item.text).join("").trim()).toBe(text.trim());
  } finally {
    try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); }
  }
}, 170_000);
