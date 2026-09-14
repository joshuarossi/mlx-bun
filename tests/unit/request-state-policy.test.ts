import { expect, test } from "bun:test";
import { bindPagedRequestState } from "../../src/backends/mlx/request-state-policy";
import { bindMlxGateway } from "../../src/backends/mlx/gateway-binding";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime-config";
import { KVCache } from "../../src/model/gemma4-base";
import { PagedKVCache } from "../../src/lab/paged-kv/paged-kv";
import type { RuntimeModel } from "../../src/model/factory";
import type { ResolvedExecution } from "../../src/contracts/execution";
import type { RowPromptCache } from "../../src/backends/mlx/batch-group";

test("paged policy retains one namespace and kernel choice across deferred cache operations", async () => {
  const on = createRuntimeConfig({ MLX_BUN_PAGED_ATTN: "1" });
  const off = createRuntimeConfig({ MLX_BUN_PAGED_ATTN: "0" });
  const model = { makeCache: () => [new KVCache()] } as unknown as RuntimeModel;
  const namespaces: string[] = [];
  const cache: RowPromptCache = {
    take(_tokens, ns) { namespaces.push(ns!); return null; },
    put(_tokens, _state, ns) { namespaces.push(ns!); },
    async prefetch(_tokens, ns) { namespaces.push(ns!); return () => {}; },
  };
  const options = { maxTokens: 2, pagedKv: { blockSize: 16 }, kvBits: 4, kvGroupSize: 64 };
  const policy = withRuntimeConfig(on, () => bindPagedRequestState(model, options, 128, cache)!);
  options.pagedKv.blockSize = 32;
  options.kvBits = 8;
  await withRuntimeConfig(off, async () => {
    await Promise.resolve();
    const rows = policy.create();
    try {
      expect(rows[0]).toBeInstanceOf(PagedKVCache);
      expect((rows[0] as PagedKVCache).direct).toBe(true);
      expect((rows[0] as PagedKVCache).blockSize).toBe(16);
      expect((rows[0] as PagedKVCache).quantization).toEqual({ bits: 4, groupSize: 64 });
      const release = await policy.promptCache!.prefetch!([1]);
      release();
      policy.promptCache!.take([1]);
      policy.promptCache!.put([1], []);
      expect(namespaces).toEqual([policy.key, policy.key, policy.key]);
      expect(JSON.parse(policy.key)[4]).toBe(true);
    } finally { rows.forEach(row => row.dispose()); }
  });
});

test("gateway uses its captured paged policy when host settings change before request planning", () => {
  const on = createRuntimeConfig({ MLX_BUN_PAGED_ATTN: "1" });
  const off = createRuntimeConfig({ MLX_BUN_PAGED_ATTN: "0" });
  const model = { config: {}, makeCache: () => [new KVCache()] } as unknown as RuntimeModel;
  const gateway = withRuntimeConfig(on, () => bindMlxGateway(model));
  const options = { maxTokens: 2, pagedKv: { blockSize: 16 } };
  const execution = { pagedKv: true } as ResolvedExecution;
  withRuntimeConfig(off, () => {
    const policy = gateway.statePolicy!(execution, options, 128)!;
    expect(gateway.prefixNamespace!(execution, options, "")).toBe(policy.key);
    expect(JSON.parse(policy.key)[4]).toBe(true);
    const rows = policy.create();
    try { expect((rows[0] as PagedKVCache).direct).toBe(true); }
    finally { rows.forEach(row => row.dispose()); }
  });
});
