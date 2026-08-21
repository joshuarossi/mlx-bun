import { describe, expect, test } from "bun:test";
import {
  cacheHeadersTrimmable,
  type CacheHeaderEntry,
  type CacheKind,
} from "../src/kv-store";
import {
  KVCache,
  QuantizedKVCache,
  RotatingKVCache,
  RotatingQuantizedKVCache,
  TurboQuantKVCache,
} from "../src/model/gemma4-base";
import { MLACache } from "../src/model/glm52-cache";
import { SSMCache } from "../src/model/qwen3-delta";

const header = (
  kind: CacheKind,
  overrides: Partial<CacheHeaderEntry> = {},
): CacheHeaderEntry => ({ kind, offset: 1, tensors: [], ...overrides });

describe("cache persistence registry", () => {
  test("every persisted kind has one trimmability policy", () => {
    const alwaysTrimmable: CacheKind[] = [
      "kv", "qkv", "turboquant", "mla", "mla-dsa", "mtp-mla",
    ];
    expect(cacheHeadersTrimmable(alwaysTrimmable.map((kind) => header(kind)))).toBe(true);
    expect(cacheHeadersTrimmable([header("ssm")])).toBe(false);
    expect(cacheHeadersTrimmable([
      header("rotating", { offset: 7, maxSize: 8 }),
      header("rotating-qkv", { offset: 7, maxSize: 8 }),
    ])).toBe(true);
    expect(cacheHeadersTrimmable([
      header("rotating", { offset: 8, maxSize: 8 }),
    ])).toBe(false);
  });

  test("serving cache signatures identify their storage schemes", () => {
    expect(new KVCache().signature()).toBe("kv:plain");
    expect(new QuantizedKVCache(64, 4).signature()).toBe("kv:quant:4:64");
    expect(new RotatingKVCache(1024).signature()).toBe("kv:rotating-plain");
    expect(new RotatingQuantizedKVCache(1024, 64, 4).signature())
      .toBe("kv:rotating-quant:4:64");
    expect(new TurboQuantKVCache(2, 4).signature()).toBe("kv:turboquant:2:4");
    expect(new SSMCache().signature()).toBe("ssm");
    expect(new MLACache({ kvLoraRank: 512, ropeHeadDim: 64 }).signature())
      .toBe("kv:mla:target");
    expect(new MLACache({
      kvLoraRank: 512, ropeHeadDim: 64, dsa: { headDim: 32 },
    }).signature()).toBe("kv:mla:target:dsa");
    expect(new MLACache({
      kvLoraRank: 512, ropeHeadDim: 64, role: "mtp",
    }).signature()).toBe("kv:mla:mtp");
  });

  test("per-token accounting is representation-owned", () => {
    expect(new SSMCache().bytesPerToken()).toBe(0);
    expect(new MLACache({ kvLoraRank: 512, ropeHeadDim: 64 }).bytesPerToken())
      .toBe((512 + 64) * 4);
    expect(new MLACache({
      kvLoraRank: 512, ropeHeadDim: 64, dsa: { headDim: 32 },
    }).bytesPerToken()).toBe((512 + 64 + 32) * 4);
  });
});
