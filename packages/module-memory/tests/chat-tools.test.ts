// The real Pi SDK must advertise and execute memory tools in a read-only chat, rather than merely accepting injected
// definitions that never reach the model. Memory reaches the chat only through the registry: its module registers the
// tools (`chat.tool`) and the hint and skill (`chat.guidance`), and the chat module's surface is built from them.
import * as chatPolicy from "../../../../packages/module-chat/src/policy";
import { expect, spyOn, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createPiBackend, type ServerMessage } from "@mlx-bun/module-chat";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "../src/tools";
import { memorySurface } from "../support/memory-surface";

async function bounded<T>(work: Promise<T>): Promise<T> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    return await Promise.race([work, new Promise<T>((_, reject) => {
      timer = setTimeout(() => reject(new Error("Pi loopback smoke timed out")), 3_000);
    })]);
  } finally { if (timer) clearTimeout(timer); }
}

test("Pi read-only chat executes the memory tools contributed through the registry and loads only the bundled skill", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-pi-memory-"));
  const cwd = join(root, "cwd"), vault = join(root, "vault"), skills = join(root, "skills");
  mkdirSync(cwd); mkdirSync(join(vault, "articles"), { recursive: true });
  writeFileSync(join(vault, "articles", "Travel.md"), "# Travel\n\nTravel preferences.\n\n## Preference\n\nTake the early train.\n");
  const requests: Record<string, unknown>[] = [], frames: ServerMessage[] = [];
  const server = Bun.serve({ hostname: "127.0.0.1", port: 0, async fetch(request) {
    requests.push(await request.json() as Record<string, unknown>);
    const chunk = (delta: Record<string, unknown>, finish_reason: string | null) => ({
      id: "memory-test", object: "chat.completion.chunk", created: 1, model: "local", choices: [{ index: 0, delta, finish_reason }],
    });
    const first = requests.length === 1;
    return new Response([
      `data: ${JSON.stringify(chunk(first ? { role: "assistant", tool_calls: [{ index: 0, id: "memory-call", type: "function",
        function: { name: "memory_section", arguments: JSON.stringify({ stem: "Travel", anchor: "preference" }) } }] }
        : { role: "assistant", content: "Take the early train." }, null))}\n\n`,
      `data: ${JSON.stringify(chunk({}, first ? "tool_calls" : "stop"))}\n\n`, "data: [DONE]\n\n",
    ].join(""), { headers: { "content-type": "text/event-stream" } });
  } });
  const classification = spyOn(chatPolicy, "toolApprovalClass");
  // Memory registers its tools and guidance; the chat reads them back from the registry when the session is built.
  const contributed = await memorySurface({ vault, skills });
  const backend = createPiBackend({ port: server.port!, readOnly: true,
    paths: { cwd, agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") },
    memory: contributed.surface,
  })(frame => frames.push(frame));
  try {
    await backend.handle({ type: "set_coding_tools", enabled: true });
    await bounded(backend.start());
    await bounded(backend.handle({ type: "prompt", text: "What train do I prefer?" }));
    expect(requests).toHaveLength(2);
    const tools = (requests[0]!.tools as { function: { name: string } }[]).map(tool => tool.function.name);
    for (const name of [...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES]) expect(tools).toContain(name);
    for (const name of ["bash", "edit", "write"]) expect(tools).not.toContain(name);
    const prompt = JSON.stringify(requests[0]!.messages);
    expect(prompt).toContain("personal memory is on (1 article)");
    expect(prompt).toContain(join(skills, "memory", "SKILL.md"));
    const results = requests[1]!.messages as { role: string; content: unknown }[];
    expect(JSON.stringify(results.filter(message => message.role === "tool"))).toContain("Take the early train.");
    const memoryCall = classification.mock.calls.findIndex(([tool]) => tool === "memory_section");
    expect(memoryCall).toBeGreaterThanOrEqual(0);
    expect(classification.mock.calls[memoryCall]![1].has("memory_section")).toBe(true);
    expect(classification.mock.results[memoryCall]?.value).toBe("read-only");
    expect(frames.some(frame => frame.type === "tool_approval_request")).toBe(false);
    expect(frames.some(frame => frame.type === "error")).toBe(false);
    expect(readFileSync(join(vault, "articles", "Travel.md"), "utf8")).toContain("Take the early train.");
    expect(existsSync(join(root, "approvals.json"))).toBe(false);
  } finally {
    classification.mockRestore();
    await bounded(Promise.resolve(backend.dispose())); await server.stop(true); await contributed.stop();
    rmSync(root, { recursive: true, force: true });
  }
}, 15_000);
