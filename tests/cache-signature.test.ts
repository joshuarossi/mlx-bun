import { describe, expect, test } from "bun:test";
import {
  cacheSignature,
  KVCache,
  QuantizedKVCache,
  RotatingKVCache,
  RotatingQuantizedKVCache,
} from "../src/model/gemma4-base";

describe("cache signatures", () => {
  test("storage identity includes layout and affine parameters", () => {
    expect(cacheSignature(new KVCache())).toBe("kv:plain");
    expect(cacheSignature(new RotatingKVCache(1024))).toBe("kv:rotating-plain");
    expect(cacheSignature(new QuantizedKVCache(64, 4))).toBe("kv:quant:4:64");
    expect(cacheSignature(new QuantizedKVCache(32, 8))).toBe("kv:quant:8:32");
    expect(cacheSignature(new RotatingQuantizedKVCache(1024, 64, 4)))
      .toBe("kv:rotating-quant:4:64");
  });

  test("unknown cache capabilities fail closed", () => {
    expect(cacheSignature(undefined)).toBe("unknown");
    expect(cacheSignature({} as never)).toBe("unknown");
  });
});
