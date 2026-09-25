import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import { expect, test } from "bun:test";
import { EventEmitter } from "node:events";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import { parseCommand } from "../src/cli/args";
import { browserUrl, installShutdownHandlers, parseServeOptions, runServe, type ServeDependencies, type ServeOptions } from "../src/cli/serve";

const parse = (...args: string[]) => parseServeOptions(parseCommand("serve", args));
const model = { repoId: "example/model", path: "/model" } as ModelRecord;
const tick = () => new Promise(resolve => setImmediate(resolve));

test("serving defaults to continuous capacity eight; capacity one uses the same engine options", () => {
  expect(parse()).toMatchObject({ query: null, capacity: 8, port: 8080, hostname: "127.0.0.1", contextLimit: null, cache: { kvQuant: "off" }, request: {} });
  expect(parse("--batch", "1").capacity).toBe(1);
  expect(() => parse("--serial")).toThrow();
  expect(() => parse("--compiled-decode", "on")).toThrow();
});

test("serving forwards explicit sampling, context, and cache choices with their original units", () => {
  expect(parse("fallback", "--model", "chosen", "--query", "ignored", "--ctx", "8192", "--port", "0",
    "--temp", "0.7", "--thinking", "off", "--top-p", "0.9", "--top-k", "20", "--max-tokens", "7.9",
    "--prompt-cache", "2", "--ssd-cache", "/cache", "--ssd-cache-max", "0", "--ssd-cache-verify",
    "--ssd-demote-idle", "0", "--generation-checkpoint", "128", "--kv-quant", "4", "--kv-budget", "3",
    "--read-only", "--no-open")).toMatchObject({
      query: "chosen", port: 0, contextLimit: 8192, defaultGeneratedTokens: 7, kvBudgetBytes: 3e9,
      readOnly: true, noOpen: true,
      request: { defaultTemperature: 0.7, defaultThinking: false, defaultTopP: 0.9, defaultTopK: 20 },
      cache: { promptCacheBytes: 2 * 2 ** 30, ssdCacheDir: "/cache", ssdCacheMaxBytes: Infinity,
        ssdCacheVerify: true, ssdDemoteIdleSec: 0, generationCheckpointTokens: 128, kvQuant: 4 },
    });
  expect(parse("--temp", "1", "--temperature", "0").request.defaultTemperature).toBe(0);
  expect(parse("positional", "--query", "fallback").query).toBe("positional");
});

test("the existing runtime context cap is validated and explicit CLI context takes precedence", () => {
  const restore = configureRuntime({ MLX_BUN_RD_CONTEXT_LIMIT: "2048" });
  try {
    expect(parse().contextLimit).toBe(2048);
    expect(parse("--ctx", "4096").contextLimit).toBe(4096);
  } finally { restore(); }
  for (const raw of ["", "0", "-1", "1.5", "NaN"]) {
    const restore = configureRuntime({ MLX_BUN_RD_CONTEXT_LIMIT: raw });
    try { expect(() => parse()).toThrow("MLX_BUN_RD_CONTEXT_LIMIT must be a positive integer"); }
    finally { restore(); }
  }
});

test("invalid serving input fails before model selection", async () => {
  for (const args of [["--batch", "0"], ["--batch", "1.5"], ["--port", "65536"], ["--ctx", "NaN"],
    ["--temp", "6"], ["--top-p", "2"], ["--thinking", "maybe"], ["--kv-quant", "3"],
    ["--ssd-cache-verify"], ["--generation-checkpoint", "128"], ["--ssd-cache", "/cache", "--prompt-cache", "0"]]) {
    let selected = false;
    await expect(runServe(parseCommand("serve", args), { resolve: async () => { selected = true; throw new Error("must not select"); } })).rejects.toThrow();
    expect(selected).toBe(false);
  }
});

function runtime(interactive = true) {
  const signals = new EventEmitter(), opens: string[] = [], exits: number[] = [], errors: unknown[] = [], starts: ServeOptions[] = [];
  let closes = 0;
  const dependencies: ServeDependencies = {
    resolve: async () => ({ m: model, picked: true }),
    start: async (m, options) => { expect(m).toBe(model); starts.push(options); return { port: 4321, close: async () => { closes++; } }; },
    interactive, open: url => { opens.push(url); }, log() {}, signals,
    exit: code => { exits.push(code); }, error: error => { errors.push(error); },
  };
  return { dependencies, signals, opens, exits, errors, starts, closes: () => closes };
}

test("interactive startup opens the bound port and graceful shutdown drains exactly once", async () => {
  const run = runtime();
  const app = await runServe(parseCommand("serve", ["--batch", "1", "--port", "0", "--host", "0.0.0.0"]), run.dependencies);
  expect(run.starts[0]?.capacity).toBe(1);
  expect(run.opens).toEqual(["http://localhost:4321/#/chat"]);
  run.signals.emit("SIGINT"); run.signals.emit("SIGTERM");
  await tick(); await app.close();
  expect(run.closes()).toBe(1); expect(run.exits).toEqual([0]);
  expect(run.signals.listenerCount("SIGINT")).toBe(0);
  expect(run.signals.listenerCount("SIGTERM")).toBe(0);
});

test("noninteractive startup and no-open leave the browser closed; programmatic close removes listeners", async () => {
  for (const [interactive, args] of [[false, []], [true, ["--no-open"]]] as const) {
    const run = runtime(interactive);
    const app = await runServe(parseCommand("serve", [...args]), run.dependencies);
    expect(run.opens).toEqual([]); await app.close(); await app.close();
    expect(run.closes()).toBe(1); expect(run.exits).toEqual([]);
    expect(run.signals.listenerCount("SIGTERM")).toBe(0);
  }
});

test("browser failure does not abandon a running server", async () => {
  const run = runtime(), failure = new Error("open failed");
  const app = await runServe(parseCommand("serve", []), { ...run.dependencies, open: () => { throw failure; } });
  expect(run.errors).toEqual([failure]); expect(run.closes()).toBe(0); await app.close();
});

test("startup failure installs no signal handlers and opens no browser", async () => {
  const run = runtime();
  await expect(runServe(parseCommand("serve", []), { ...run.dependencies, start: async () => { throw new Error("bind failed"); } })).rejects.toThrow("bind failed");
  expect(run.signals.listenerCount("SIGINT")).toBe(0); expect(run.opens).toEqual([]);
});

test("signals wait for teardown and report cleanup failures with a nonzero exit", async () => {
  const run = runtime(), failure = new Error("flush failed");
  let reject!: (error: Error) => void, calls = 0;
  installShutdownHandlers(() => { calls++; return new Promise<void>((_, fail) => { reject = fail; }); }, {
    signals: run.signals, exit: run.dependencies.exit, error: run.dependencies.error,
  });
  run.signals.emit("SIGTERM"); run.signals.emit("SIGINT");
  expect(calls).toBe(1); expect(run.exits).toEqual([]);
  expect(run.signals.listenerCount("SIGINT")).toBe(1);
  reject(failure); await tick();
  expect(run.errors).toEqual([failure]); expect(run.exits).toEqual([1]);
  expect(run.signals.listenerCount("SIGINT")).toBe(0);
});

test("browser addresses support IPv6 and wildcard listeners", () => {
  expect(browserUrl("::", 8080)).toBe("http://localhost:8080/#/chat");
  expect(browserUrl("::1", 8080)).toBe("http://[::1]:8080/#/chat");
});


test("the process owner bounds shutdown without releasing live resources or exiting twice", async () => {
  const run = runtime();
  const pending = Promise.withResolvers<void>();
  const exited = Promise.withResolvers<void>();
  let releases = 0;
  installShutdownHandlers(async () => { await pending.promise; releases++; }, {
    signals: run.signals, timeoutMs: 5, error: run.dependencies.error,
    exit(code) { run.exits.push(code); exited.resolve(); },
  });
  run.signals.emit("SIGTERM");
  await exited.promise;
  expect(run.exits).toEqual([1]);
  expect((run.errors[0] as Error).message).toContain("persistence may be incomplete");
  expect(releases).toBe(0);
  pending.resolve(); await tick();
  expect(releases).toBe(1); expect(run.exits).toEqual([1]);
  expect(run.signals.listenerCount("SIGTERM")).toBe(0);
});
