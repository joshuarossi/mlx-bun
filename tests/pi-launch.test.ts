// Phase 16 P2: `mlx-bun pi` — invocation building (session-scoped
// extension, scoped model cycling, passthrough ordering) and probe.

import { describe, expect, it, afterAll } from "bun:test";
import { existsSync, readFileSync, rmSync } from "node:fs";
import { join } from "node:path";
import { buildPiInvocation, probeServer } from "../src/pi-launch";
import type { ServerModel } from "../src/harness-pi";

// The server advertises exactly one model at a time (single-model invariant).
const MODELS: ServerModel[] = [
  { id: "mlx-community/gemma-4-12B-it-OptiQ-4bit", contextWindow: 131072, maxTokens: 8192 },
];
const PI = { found: true, binPath: process.execPath }; // any real file works
const cleanups: string[] = [];
afterAll(() => cleanups.forEach((d) => rmSync(d, { recursive: true, force: true })));

function build(passthrough: string[] = []) {
  const inv = buildPiInvocation(PI, "http://localhost:8090/v1", MODELS, passthrough);
  cleanups.push(inv.cleanupDir);
  return inv;
}

describe("buildPiInvocation", () => {
  it("runs pi's cli under the current Bun (node-18 shim hazard)", () => {
    const { argv } = build();
    expect(argv[0]).toBe(process.execPath);
  });

  it("wires the session extension, provider, default model, and scoped cycling", () => {
    const { argv, cleanupDir } = build();
    const extPath = argv[argv.indexOf("-e") + 1]!;
    expect(extPath.startsWith(cleanupDir)).toBe(true);
    expect(existsSync(extPath)).toBe(true);
    expect(readFileSync(extPath, "utf8")).toContain('pi.registerProvider("mlx-bun"');
    expect(argv).toContain("--provider");
    // stable handle so pi addresses "whatever is on 8090", never a stale id
    expect(argv[argv.indexOf("--model") + 1]).toBe("local");
    expect(argv[argv.indexOf("--models") + 1]).toBe("local");
  });

  it("appends user passthrough last so explicit flags override ours", () => {
    const { argv } = build(["--model", "mlx-community/other-model", "-p", "hello"]);
    expect(argv.lastIndexOf("--model")).toBeGreaterThan(argv.indexOf("--models"));
    expect(argv[argv.lastIndexOf("--model") + 1]).toBe("mlx-community/other-model");
    expect(argv.slice(-2)).toEqual(["-p", "hello"]);
  });

  it("bakes the discovered model under the stable local id", () => {
    const { argv } = build();
    const ext = readFileSync(argv[argv.indexOf("-e") + 1]!, "utf8");
    expect(ext).toContain('"id": "local"');
    for (const m of MODELS) expect(ext).toContain(m.id); // real model rides in `name`
  });
});

describe("probeServer", () => {
  it("returns models when a server answers /v1/models", async () => {
    const stub = Bun.serve({
      port: 0,
      fetch: () => Response.json({ data: [{ id: "x/y", context_window: 4096 }] }),
    });
    try {
      const models = await probeServer(`http://localhost:${stub.port}/v1`);
      expect(models).toEqual([{ id: "x/y", contextWindow: 4096, maxTokens: 8192 }]);
    } finally {
      stub.stop(true);
    }
  });

  it("returns null when nothing is listening", async () => {
    expect(await probeServer("http://localhost:1/v1", 300)).toBeNull();
  });
});
