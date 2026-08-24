// Model Hub REST wrappers (src/hub-rest.ts) — fast tier, no model context,
// no network by default. Handlers are called directly (plain functions with
// no `ctx` dependency), matching src/server.ts's dispatch exactly — no need
// to boot a Bun.serve or load model weights. HF search is exercised against
// an injected fetch (never the real network); the offline-degrade path is
// tested with a rejecting fetch instead of skipping.

import { afterEach, describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Registry } from "../../src/registry";
import {
  handleHubLocal, handleHubSearch, handleHubDownload, handleHubServe, searchHub,
} from "../../src/hub-rest";

function makeHub(): string {
  const hub = mkdtempSync(join(tmpdir(), "mlx-bun-hub-rest-"));
  // A flat (non-nested-text_config) llama-shaped config: loadModelConfig
  // derives real head_dim/kv_heads/layer_types from these fields (unlike a
  // minimal gemma4-style text_config, which needs many more fields before
  // its arch-specific defaulting kicks in) — this is what makes the fit()
  // assessment come out as real numbers instead of NaN.
  const snap = join(hub, "models--test--tiny-4bit", "snapshots", "abc123");
  mkdirSync(snap, { recursive: true });
  writeFileSync(join(snap, "config.json"), JSON.stringify({
    model_type: "llama",
    quantization: { bits: 4, group_size: 64, mode: "affine" },
    num_hidden_layers: 4, hidden_size: 256, vocab_size: 1000,
    num_attention_heads: 8, num_key_value_heads: 8, head_dim: 32,
    max_position_embeddings: 8192,
  }));
  writeFileSync(join(snap, "model.safetensors"), new Uint8Array(1024));
  writeFileSync(join(snap, "model.safetensors.index.json"), JSON.stringify({
    metadata: { total_parameters: 123456789 },
    weight_map: {},
  }));

  // An unsupported/unknown model_type so we can assert supported:false rows.
  const snap2 = join(hub, "models--test--exotic", "snapshots", "def456");
  mkdirSync(snap2, { recursive: true });
  writeFileSync(join(snap2, "config.json"), JSON.stringify({
    model_type: "some_unrecognized_arch",
    num_hidden_layers: 2, hidden_size: 64, vocab_size: 100,
  }));
  writeFileSync(join(snap2, "model.safetensors"), new Uint8Array(4096));
  return hub;
}

describe("GET /api/hub/local", () => {
  let hub = "";
  afterEach(() => {
    if (hub) rmSync(hub, { recursive: true, force: true });
    hub = "";
  });

  test("lists registry models with a fit assessment per row", async () => {
    hub = makeHub();
    const reg = new Registry(":memory:");
    const res = await handleHubLocal({ reg, hubDir: hub });
    expect(res.status).toBe(200);
    const body = (await res.json()) as {
      ok: boolean;
      models: Array<{
        repo_id: string; supported: boolean; support_tier: string | null;
        assessment: { fits: boolean; predicted_decode_tps: number } | null;
      }>;
    };
    expect(body.ok).toBe(true);
    expect(body.models).toHaveLength(2);

    const tiny = body.models.find((m) => m.repo_id === "test/tiny-4bit")!;
    expect(tiny.supported).toBe(true);
    expect(tiny.assessment).not.toBeNull();
    expect(Number.isFinite(tiny.assessment!.predicted_decode_tps)).toBe(true);
    expect(tiny.assessment!.predicted_decode_tps).toBeGreaterThan(0);

    const exotic = body.models.find((m) => m.repo_id === "test/exotic")!;
    expect(exotic.supported).toBe(false);
    expect(exotic.support_tier).toBeNull();
    reg.close();
  });

  test("empty hub dir yields an empty (not erroring) list", async () => {
    hub = mkdtempSync(join(tmpdir(), "mlx-bun-hub-rest-empty-"));
    const reg = new Registry(":memory:");
    const res = await handleHubLocal({ reg, hubDir: hub });
    const body = (await res.json()) as { ok: boolean; models: unknown[] };
    expect(body.ok).toBe(true);
    expect(body.models).toEqual([]);
    reg.close();
  });
});

describe("GET /api/hub/search", () => {
  test("normalizes HF search results and re-filters to the mlx tag", async () => {
    const fetchFn = (async (url: string | URL) => {
      const u = new URL(String(url));
      expect(u.pathname).toBe("/api/models");
      expect(u.searchParams.get("filter")).toBe("mlx");
      expect(u.searchParams.get("search")).toBe("gemma");
      return Response.json([
        { id: "mlx-community/gemma-3-1b-it-4bit", downloads: 5000, likes: 42, tags: ["mlx", "gemma3"] },
        { id: "someorg/gemma-not-mlx", downloads: 100, likes: 1, tags: ["pytorch"] },
        { id: "mlx-community/gemma-no-counts", tags: ["mlx"] },
      ]);
    }) as unknown as typeof fetch;

    const result = await searchHub("gemma", { fetchFn });
    expect(result.ok).toBe(true);
    if (!result.ok) throw new Error("unreachable");
    expect(result.results).toHaveLength(2); // the non-mlx row is dropped
    const ids = result.results.map((r) => r.id);
    expect(ids).toContain("mlx-community/gemma-3-1b-it-4bit");
    expect(ids).toContain("mlx-community/gemma-no-counts");
    const first = result.results.find((r) => r.id === "mlx-community/gemma-3-1b-it-4bit")!;
    expect(first.downloads).toBe(5000);
    expect(first.likes).toBe(42);
    expect(first.size_estimate).toBeNull();
  });

  test("handler 400s on a missing query", async () => {
    const res = await handleHubSearch(new URL("http://x/api/hub/search"));
    expect(res.status).toBe(400);
  });

  test("handler degrades to {offline:true} on a network failure, never throws or 500s", async () => {
    const fetchFn = (async () => {
      throw new Error("getaddrinfo ENOTFOUND huggingface.co");
    }) as unknown as typeof fetch;
    const result = await searchHub("gemma", { fetchFn });
    expect(result.ok).toBe(false);
    if (result.ok) throw new Error("unreachable");
    expect(result.offline).toBe(true);
    expect(result.error).toContain("ENOTFOUND");
  });

  test("handler surfaces offline via the HTTP route too (still 200, ok:false)", async () => {
    const origFetch = globalThis.fetch;
    globalThis.fetch = (async () => {
      throw new Error("network unreachable");
    }) as unknown as typeof fetch;
    try {
      const res = await handleHubSearch(new URL("http://x/api/hub/search?q=gemma"));
      expect(res.status).toBe(200);
      const body = (await res.json()) as { ok: boolean; offline: boolean; results: unknown[] };
      expect(body.ok).toBe(true); // the wrapper envelope succeeded...
      expect(body.offline).toBe(true); // ...but the search itself is offline
      expect(body.results).toEqual([]);
    } finally {
      globalThis.fetch = origFetch;
    }
  });

  test("non-ok HTTP status from HF is also treated as offline, not a throw", async () => {
    const fetchFn = (async () => new Response("rate limited", { status: 429 })) as unknown as typeof fetch;
    const result = await searchHub("gemma", { fetchFn });
    expect(result.ok).toBe(false);
  });
});

describe("POST /api/hub/download", () => {
  test("missing repo 400s", async () => {
    const res = await handleHubDownload(new Request("http://x", { method: "POST", body: "{}" }));
    expect(res.status).toBe(400);
  });

  test("starts a download and returns immediately (started:true)", async () => {
    // repoId that will fail fast against the real HF API (no network
    // mocking here since downloadModel isn't fetch-injectable) — we only
    // assert the route returns immediately with started:true; the actual
    // transfer's pass/fail is downloadModel's own concern (tested in
    // tests/download.test.ts) and surfaces later via GET /downloads.
    const repo = `test-org/hub-rest-fake-${Date.now()}`;
    const res = await handleHubDownload(
      new Request("http://x", { method: "POST", body: JSON.stringify({ repo }) }),
    );
    expect(res.status).toBe(200);
    const body = (await res.json()) as { ok: boolean; repo: string; started: boolean };
    expect(body.ok).toBe(true);
    expect(body.repo).toBe(repo);
    expect(body.started).toBe(true);
  });

  test("refuses a duplicate in-flight download for the same repo", async () => {
    const repo = `test-org/hub-rest-dup-${Date.now()}`;
    const first = await handleHubDownload(
      new Request("http://x", { method: "POST", body: JSON.stringify({ repo }) }),
    );
    expect(first.status).toBe(200);
    const second = await handleHubDownload(
      new Request("http://x", { method: "POST", body: JSON.stringify({ repo }) }),
    );
    expect(second.status).toBe(409);
    const body = (await second.json()) as { ok: boolean; error: string };
    expect(body.ok).toBe(false);
    expect(body.error).toContain(repo);
  });
});

describe("POST /api/hub/serve", () => {
  test("missing model 400s", async () => {
    const res = await handleHubServe(new Request("http://x", { method: "POST", body: "{}" }));
    expect(res.status).toBe(400);
  });

  test("always answers restart_required with the exact restart command (no fake in-process swap)", async () => {
    const res = await handleHubServe(
      new Request("http://x", { method: "POST", body: JSON.stringify({ model: "mlx-community/gemma-4-e4b-it-OptiQ-4bit" }) }),
    );
    expect(res.status).toBe(200);
    const body = (await res.json()) as { ok: boolean; restart_required: boolean; command: string };
    expect(body.ok).toBe(false);
    expect(body.restart_required).toBe(true);
    expect(body.command).toBe("mlx-bun serve mlx-community/gemma-4-e4b-it-OptiQ-4bit");
  });
});
