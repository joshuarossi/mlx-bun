// Serve-level bit-parity probe — the bench's two parity probes (raw
// /v1/completions + chat with enable_thinking pinned), run standalone against
// each arm SEQUENTIALLY (one model-loading server at a time; each is killed
// before the next spawns). The reduced form of scripts/bench-serve.ts's
// parity phase for fix verification without the perf legs.
//
//   bun scripts/experiments/serve-parity-probe.ts <cpm5|e4b|12B> [arms]
//     arms: comma list of mlx-bun,mlx-bun-serial,mlx-lm (default: all three)
import { existsSync } from "node:fs";

const HF = `${process.env.HOME}/.cache/huggingface/hub`;
const VENV = `${process.env.HOME}/Code/mlx-lm/.venv/bin`;
const PY = `${VENV}/python`;
const CLI = new URL("../../src/cli.ts", import.meta.url).pathname;
const PORT = 18231;

const MODELS: Record<string, { path: string; needsOptiqRegister?: boolean }> = {
  cpm5: { path: `${HF}/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78` },
  e4b: { path: `${HF}/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/98d7dc6a93ae05583e8a10018c8099459b58aeeb` },
  "12B": {
    path: `${HF}/models--mlx-community--gemma-4-12B-it-OptiQ-4bit/snapshots/5b1101065d2094c8f12aa87fee80e0afa5b292b7`,
    needsOptiqRegister: true,
  },
};

function armCmd(arm: string, path: string, needsOptiq: boolean | undefined): string[] {
  switch (arm) {
    case "mlx-bun":
      return ["bun", CLI, "serve", "--model", path, "--port", String(PORT), "--no-open"];
    case "mlx-bun-serial":
      return ["bun", CLI, "serve", "--model", path, "--port", String(PORT), "--no-open", "--batch", "1"];
    case "mlx-lm":
      if (needsOptiq)
        return [PY, "-c", "from optiq.cli import cli; cli()", "serve", "--model", path, "--port", String(PORT)];
      return [PY, "-m", "mlx_lm.server", "--model", path, "--port", String(PORT)];
    default:
      throw new Error(`unknown arm ${arm}`);
  }
}

async function waitReady(base: string, timeoutMs: number): Promise<void> {
  const t0 = performance.now();
  while (performance.now() - t0 < timeoutMs) {
    try {
      const r = await fetch(`${base}/v1/models`, { signal: AbortSignal.timeout(2000) });
      if (r.ok) return;
    } catch { /* not up yet */ }
    await Bun.sleep(300);
  }
  throw new Error(`server not ready after ${timeoutMs} ms`);
}

interface ProbeOut { text: string; promptTokens: number }

async function completionProbe(base: string, modelId: string): Promise<ProbeOut> {
  const r = await fetch(`${base}/v1/completions`, {
    method: "POST",
    signal: AbortSignal.timeout(300_000),
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      model: modelId, prompt: "The first eight prime numbers are",
      max_tokens: 64, temperature: 0, stream: false,
    }),
  });
  if (!r.ok) throw new Error(`HTTP ${r.status}: ${(await r.text()).slice(0, 300)}`);
  const j = (await r.json()) as { choices?: { text?: string }[]; usage?: { prompt_tokens?: number } };
  return { text: j.choices?.[0]?.text ?? "", promptTokens: j.usage?.prompt_tokens ?? 0 };
}

/** Streamed chat probe — same shape as bench-serve.ts timedRequest (the
 *  non-stream body drops thinking-channel text on some stacks, which made the
 *  comparison vacuous). Accumulates delta.content + delta.reasoning_content. */
async function chatProbe(base: string, modelId: string): Promise<ProbeOut> {
  const r = await fetch(`${base}/v1/chat/completions`, {
    method: "POST",
    signal: AbortSignal.timeout(300_000),
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      model: modelId, stream: true, max_tokens: 64, temperature: 0,
      messages: [{ role: "user", content: "List the first eight prime numbers, then briefly explain what makes a number prime." }],
      stream_options: { include_usage: true },
      chat_template_kwargs: { enable_thinking: true },
    }),
  });
  if (!r.ok) throw new Error(`HTTP ${r.status}: ${(await r.text()).slice(0, 300)}`);
  const dec = new TextDecoder();
  let buf = "";
  let text = "";
  let promptTokens = 0;
  const reader = r.body!.getReader();
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    buf += dec.decode(value, { stream: true });
    let nl: number;
    while ((nl = buf.indexOf("\n")) >= 0) {
      const line = buf.slice(0, nl).trim();
      buf = buf.slice(nl + 1);
      if (!line.startsWith("data:") || line === "data: [DONE]") continue;
      const j = JSON.parse(line.slice(5)) as {
        choices?: { delta?: { content?: string; reasoning?: string; reasoning_content?: string } }[];
        usage?: { prompt_tokens?: number };
      };
      const d = j.choices?.[0]?.delta;
      // bench-serve.ts B2: concatenate content AND reasoning (mlx-lm streams
      // thinking as `reasoning`; some builds use `reasoning_content`).
      text += (d?.content ?? "") + (d?.reasoning ?? d?.reasoning_content ?? "");
      if (j.usage?.prompt_tokens) promptTokens = j.usage.prompt_tokens;
    }
  }
  return { text, promptTokens };
}

const modelKey = process.argv[2] ?? "12B";
const arms = (process.argv[3] ?? "mlx-bun,mlx-bun-serial,mlx-lm").split(",");
const m = MODELS[modelKey];
if (!m || !existsSync(m.path)) throw new Error(`model ${modelKey} missing at ${m?.path}`);

const results: Record<string, { completion: ProbeOut; chat: ProbeOut }> = {};
for (const arm of arms) {
  const cmd = armCmd(arm, m.path, m.needsOptiqRegister);
  console.error(`== ${arm}: ${cmd.join(" ")}`);
  const proc = Bun.spawn(cmd, { stdout: "ignore", stderr: "ignore" });
  try {
    await waitReady(`http://127.0.0.1:${PORT}`, 300_000);
    const completion = await completionProbe(`http://127.0.0.1:${PORT}`, m.path);
    const chat = await chatProbe(`http://127.0.0.1:${PORT}`, m.path);
    results[arm] = { completion, chat };
  } finally {
    proc.kill();
    // escalate if it lingers (python servers can be slow to die)
    const dead = await Promise.race([proc.exited.then(() => true), Bun.sleep(8000).then(() => false)]);
    if (!dead) { proc.kill(9); await proc.exited; }
    await Bun.sleep(1500); // let the port + unified memory settle
  }
}

console.log(JSON.stringify(results, null, 2));
const ref = arms.includes("mlx-lm") ? "mlx-lm" : arms[0]!;
for (const probe of ["completion", "chat"] as const) {
  for (const arm of arms) {
    if (arm === ref) continue;
    const a = results[arm]![probe], b = results[ref]![probe];
    const tokEq = a.promptTokens === b.promptTokens;
    const txtEq = a.text === b.text;
    let firstDiff = -1;
    if (!txtEq) {
      firstDiff = 0;
      while (firstDiff < Math.min(a.text.length, b.text.length) && a.text[firstDiff] === b.text[firstDiff]) firstDiff++;
    }
    console.log(
      `${modelKey} [${probe}] ${arm} vs ${ref}: prompt_tokens ${a.promptTokens}/${b.promptTokens} ${tokEq ? "==" : "DRIFT"}; ` +
      (txtEq ? `text IDENTICAL (${a.text.length} chars)` : `text DIVERGED at char ${firstDiff}`),
    );
  }
}
