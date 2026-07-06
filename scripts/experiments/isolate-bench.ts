// Isolation exit criterion (runtime-isolation.md): does the proxy cost
// throughput or TTFT? ONE engine child on a UDS; the same streamed
// generation measured (a) DIRECTLY over the socket and (b) through the
// parent proxy — paired, interleaved, best-of-2 per arm.
//   bun scripts/experiments/isolate-bench.ts [--model <query>] [--tokens 128]
import { join } from "node:path";
import { tmpdir } from "node:os";
import { startProxyServer, engineArgv } from "../../src/serve/isolate";
import { SNAPSHOT_MINICPM5 } from "../../tests/paths";

const arg = (n: string, d: string) => {
  const i = process.argv.indexOf(n);
  return i > -1 ? process.argv[i + 1]! : d;
};
const TOKENS = Number(arg("--tokens", "128"));
const MODEL = arg("--model", SNAPSHOT_MINICPM5);
const CLI = new URL("../../src/cli.ts", import.meta.url).pathname;

const sock = join(tmpdir(), `mlxbun-isobench-${process.pid}.sock`);
const { server, engine } = startProxyServer({
  port: 0,
  engine: {
    argv: [process.execPath, "run", CLI, ...engineArgv(["serve", MODEL, "--no-open"], sock)],
    socketPath: sock,
    readyTimeoutMs: 600_000,
  },
});
await engine.ready;

const body = JSON.stringify({
  messages: [{ role: "user", content: "Write a detailed essay about the history of computing." }],
  max_tokens: TOKENS,
  stream: true,
});

async function run(direct: boolean): Promise<{ tps: number; ttftMs: number }> {
  const t0 = performance.now();
  const r = await fetch(
    direct ? "http://engine/v1/chat/completions" : `http://localhost:${server.port}/v1/chat/completions`,
    {
      method: "POST",
      headers: { "content-type": "application/json" },
      body,
      ...(direct ? { unix: sock } : {}),
    } as RequestInit,
  );
  const reader = r.body!.getReader();
  let first = 0;
  let chunks = 0;
  let last = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    const now = performance.now();
    if (!first && value!.length > 0) first = now;
    last = now;
    chunks++;
  }
  // decode tok/s ≈ (chunks-2) / (last-first): chunk count ~ tokens+2 framing
  return { tps: ((chunks - 2) * 1000) / (last - first), ttftMs: first - t0 };
}

await run(true); // warmup
await run(false);
const rows: string[] = [];
for (let i = 0; i < 2; i++) {
  const d = await run(true);
  const p = await run(false);
  rows.push(`direct ${d.tps.toFixed(1)} tok/s ttft ${d.ttftMs.toFixed(0)}ms · proxied ${p.tps.toFixed(1)} tok/s ttft ${p.ttftMs.toFixed(0)}ms`);
}
console.log(rows.join("\n"));
engine.stop();
server.stop(true);
