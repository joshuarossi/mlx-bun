// Opt-in with real weights (MLX_BUN_APP_TEST_MODEL, an already-downloaded
// snapshot): the app's real serve composition with the installed metrics
// module. A load and a few requests must show up as events, and the module's
// numbers must equal what the request itself reported (`usage`) and what
// `/stats` reports for the same counters.
import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const modelDir = process.env.MLX_BUN_APP_TEST_MODEL;
// The module's snapshot as JSON; a host never imports a module's types, so the test reads it untyped.
type MetricsSnapshot = any;

test.skipIf(!modelDir)("a real load and requests are published as events and the metrics module's numbers match usage and /stats", async () => {
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const model = await scanSnapshot(modelDir!, "test-model");
  if (!model) throw new Error("Model path has no loadable checkpoint");
  const root = mkdtempSync(join(tmpdir(), "mlx-real-metrics-"));
  const options = parseServeOptions({ values: { port: "0", "max-tokens": "16", "prompt-cache": "0.125", "no-open": true, thinking: "off", batch: "4" }, positionals: [] });
  options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), jobsLogs: join(root, "jobs"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
  options.chatPaths = { cwd: root, agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
  const budget = AbortSignal.timeout(150_000);
  let app: Awaited<ReturnType<typeof startModelServer>> | undefined;
  try {
    app = await startModelServer(model, options);
    const base = `http://127.0.0.1:${app.port}`;
    const get = async (path: string) => (await fetch(base + path, { signal: budget })).json() as Promise<any>;
    const chat = (content: string, extra: object = {}) => fetch(`${base}/v1/chat/completions`, { method: "POST", signal: budget,
      headers: { "content-type": "application/json" }, body: JSON.stringify({ messages: [{ role: "user", content }], max_tokens: 12, temperature: 0, ...extra }) });

    // A repeated prompt (cache hit), two concurrent rows (occupancy), and one cancelled stream.
    const first = await (await chat("Name a color.")).json() as any;
    const repeated = await (await chat("Name a color.")).json() as any;
    const pair = await Promise.all([chat("Name a fruit."), chat("Name an animal.")].map(async response => (await response).json() as Promise<any>));
    const cancelled = await chat("Count to one hundred slowly.", { stream: true, max_tokens: 200 });
    const reader = cancelled.body!.getReader();
    await reader.read();
    await reader.cancel();
    const usages = [first, repeated, ...pair].map(body => body.usage);
    expect(repeated.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(0);

    // Samples arrive on an interval: wait until the metrics show all five finished requests and a reading of the counters /stats holds now.
    let snapshot: MetricsSnapshot, stats: any;
    for (const end = Date.now() + 20_000;;) {
      snapshot = await get("/api/metrics/snapshot"); stats = await get("/stats");
      const prefix = snapshot.caches[0]?.prefix;
      if (snapshot.requests.finished >= 5 && prefix && prefix.hits === stats.prompt_cache.hits && prefix.bytes === stats.prompt_cache.bytes) break;
      if (Date.now() > end) throw new Error(`metrics never caught up: ${JSON.stringify(snapshot.requests)} ${JSON.stringify(prefix)}`);
      await Bun.sleep(200);
    }

    // The load: published by the host with its measured duration and the weights /stats reports.
    expect(snapshot.models).toHaveLength(1);
    expect(snapshot.models[0]).toMatchObject({ state: "resident", loads: 1, weightsBytes: stats.admission.weights_bytes });
    expect(snapshot.models[0]!.lastLoadMs).toBeGreaterThan(0);

    // Each request: tokens equal the response's own usage; timings are present, ordered and consistent.
    const finished = snapshot.requests.recent.filter((request: any) => request.finish !== "cancelled");
    expect(finished.map((request: any) => [request.promptTokens, request.completionTokens, request.cachedPromptTokens]).sort())
      .toEqual(usages.map((usage: any) => [usage.prompt_tokens, usage.completion_tokens, usage.prompt_tokens_details?.cached_tokens ?? 0]).sort());
    for (const request of finished as any[]) {
      expect(request.ttftMs).toBeGreaterThan(0);
      expect(request.totalMs).toBeGreaterThanOrEqual(request.ttftMs!);
      expect(request.queueMs).toBeGreaterThanOrEqual(0);
      expect(request.queueMs!).toBeLessThanOrEqual(request.ttftMs!);
      if (request.completionTokens > 1) expect(request.decodeTokensPerSecond).toBeGreaterThan(0);
    }
    expect(snapshot.requests.byFinish.cancelled).toBeGreaterThanOrEqual(1);
    expect(snapshot.requests.window.ttftMs!.count).toBeGreaterThanOrEqual(4);

    // The scheduler and caches: the same counters /stats reads.
    expect(snapshot.schedulers[0]).toMatchObject({ capacity: stats.batch.configured });
    expect(snapshot.caches[0]!.prefix).toMatchObject({ hits: stats.prompt_cache.hits, misses: stats.prompt_cache.misses, bytes: stats.prompt_cache.bytes, capacityBytes: stats.prompt_cache.max_bytes });
    expect(snapshot.caches[0]!.kv).toMatchObject({ bytes: stats.batch.kv_bytes });
    expect(snapshot.series.length).toBeGreaterThan(0);

    // The stream carries the same snapshot shape; the history route is served.
    const stream = await fetch(`${base}/api/metrics/stream`, { signal: budget });
    const streamReader = stream.body!.getReader(), decoder = new TextDecoder();
    let text = "";
    while (!text.includes("event: snapshot")) text += decoder.decode((await streamReader.read()).value);
    await streamReader.cancel();
    expect(JSON.parse(text.split("data: ")[1]!.split("\n")[0]!).models[0].model).toBe(snapshot.models[0]!.model);
    expect(await get("/api/metrics/history")).toEqual({ runs: [] });
  } finally {
    await app?.close();
    rmSync(root, { recursive: true, force: true });
  }
}, 180_000);
