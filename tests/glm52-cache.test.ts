import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import {
  MLACache,
  type MLACompressedState,
} from "../src/model/glm52-cache";

function f32(values: number[], shape: number[]): MlxArray {
  return MlxArray.fromFloat32(new Float32Array(values), shape);
}

function disposeState(state: MLACompressedState): void {
  state.latent.dispose();
  state.rope.dispose();
  state.dsa?.dispose();
}

describe("GLM-5.2 compressed MLA cache", () => {
  test("appends latent, decoupled RoPE, and DSA state without full K/V", () => {
    const cache = new MLACache({
      kvLoraRank: 3,
      ropeHeadDim: 2,
      dsa: { headDim: 2 },
      maxTokens: 5,
    });
    const latent0 = f32([1, 2, 3, 4, 5, 6], [1, 2, 3]);
    const rope0 = f32([10, 11, 12, 13], [1, 2, 2]);
    const dsa0 = f32([20, 21, 22, 23], [1, 2, 2]);
    const latent1 = f32([7, 8, 9], [1, 1, 3]);
    const rope1 = f32([14, 15], [1, 1, 2]);
    const dsa1 = f32([24, 25], [1, 1, 2]);
    try {
      cache.append(latent0, rope0, dsa0);
      expect(cache.offset).toBe(2);
      expect(cache.state().map((array) => array.shape)).toEqual([
        [1, 2, 3],
        [1, 2, 2],
        [1, 2, 2],
      ]);
      // (latent 3 + rope 2 + one shared DSA key of width 2) f32 × B1 × T2.
      expect(cache.byteLength).toBe(1 * 2 * (3 + 2 + 2) * 4);

      const state = cache.appendAndFetch(latent1, rope1, dsa1);
      expect(cache.offset).toBe(3);
      expect(state.latent.toFloat32()).toEqual(
        new Float32Array([1, 2, 3, 4, 5, 6, 7, 8, 9]),
      );
      expect(state.rope.toFloat32()).toEqual(
        new Float32Array([10, 11, 12, 13, 14, 15]),
      );
      expect(state.dsa!.toFloat32()).toEqual(
        new Float32Array([20, 21, 22, 23, 24, 25]),
      );
      disposeState(state);
      expect(cache.byteLength).toBe(1 * 3 * (3 + 2 + 2) * 4);
    } finally {
      for (const array of [latent0, rope0, dsa0, latent1, rope1, dsa1])
        array.dispose();
      cache.dispose();
    }
  });

  test("generic updateAndFetch works only for MLA-only layers", () => {
    const cache = new MLACache({ kvLoraRank: 2, ropeHeadDim: 1 });
    const latent = f32([1, 2, 3, 4], [2, 1, 2]);
    const rope = f32([5, 6], [2, 1, 1]);
    try {
      const [gotLatent, gotRope] = cache.updateAndFetch(latent, rope);
      expect(gotLatent.toFloat32()).toEqual(new Float32Array([1, 2, 3, 4]));
      expect(gotRope.toFloat32()).toEqual(new Float32Array([5, 6]));
      expect(cache.offset).toBe(1);
      expect(cache.byteLength).toBe(2 * 1 * 3 * 4);
      gotLatent.dispose();
      gotRope.dispose();
    } finally {
      latent.dispose();
      rope.dispose();
      cache.dispose();
    }

    const dsaCache = new MLACache({
      kvLoraRank: 2,
      ropeHeadDim: 1,
      dsa: { headDim: 1 },
    });
    const dsaLatent = f32([1, 2], [1, 1, 2]);
    const dsaRope = f32([3], [1, 1, 1]);
    try {
      expect(() => dsaCache.updateAndFetch(dsaLatent, dsaRope))
        .toThrow(/requires appendAndFetch/);
      expect(dsaCache.offset).toBe(0);
    } finally {
      dsaLatent.dispose();
      dsaRope.dispose();
      dsaCache.dispose();
    }
  });

  test("trim keeps all state families aligned and permits a new suffix", () => {
    const cache = new MLACache({
      kvLoraRank: 2,
      ropeHeadDim: 1,
      dsa: { headDim: 2 },
    });
    const latent = f32([1, 2, 3, 4, 5, 6], [1, 3, 2]);
    const rope = f32([10, 11, 12], [1, 3, 1]);
    const dsa = f32([20, 21, 22, 23, 24, 25], [1, 3, 2]);
    const suffixLatent = f32([7, 8], [1, 1, 2]);
    const suffixRope = f32([13], [1, 1, 1]);
    const suffixDsa = f32([26, 27], [1, 1, 2]);
    try {
      cache.append(latent, rope, dsa);
      cache.trim(1);
      expect(cache.offset).toBe(2);
      expect(cache.dsa!.offset).toBe(2);
      expect(cache.state().map((array) => array.shape)).toEqual([
        [1, 2, 2],
        [1, 2, 1],
        [1, 2, 2],
      ]);
      const state = cache.appendAndFetch(
        suffixLatent,
        suffixRope,
        suffixDsa,
      );
      expect(state.latent.toFloat32()).toEqual(
        new Float32Array([1, 2, 3, 4, 7, 8]),
      );
      expect(state.rope.toFloat32()).toEqual(
        new Float32Array([10, 11, 13]),
      );
      expect(state.dsa!.toFloat32()).toEqual(
        new Float32Array([20, 21, 22, 23, 26, 27]),
      );
      disposeState(state);

      cache.trim(3);
      expect(cache.offset).toBe(0);
      expect(cache.byteLength).toBe(0);
      expect(cache.state()).toEqual([]);
    } finally {
      for (const array of [
        latent,
        rope,
        dsa,
        suffixLatent,
        suffixRope,
        suffixDsa,
      ]) {
        array.dispose();
      }
      cache.dispose();
    }
  });

  test("rejects shape, dtype, batch, DSA, offset, and trim drift atomically", () => {
    const cache = new MLACache({
      kvLoraRank: 3,
      ropeHeadDim: 2,
      dsa: { headDim: 2 },
      maxTokens: 2,
    });
    const latent = f32([1, 2, 3], [1, 1, 3]);
    const rope = f32([4, 5], [1, 1, 2]);
    const dsa = f32([6, 7], [1, 1, 2]);
    const wrongLatent = f32([1, 2], [1, 1, 2]);
    const wrongRope = f32([1, 2, 3], [1, 1, 3]);
    const wrongDsa = f32([1], [1, 1, 1]);
    const intLatent = ops.fromInt32([1, 2, 3], [1, 1, 3]);
    const batchLatent = f32([1, 2, 3, 4, 5, 6], [2, 1, 3]);
    const batchRope = f32([1, 2, 3, 4], [2, 1, 2]);
    const batchDsa = f32([1, 2, 3, 4], [2, 1, 2]);
    try {
      expect(() => cache.append(wrongLatent, rope, dsa)).toThrow(/shape/);
      expect(() => cache.append(latent, wrongRope, dsa)).toThrow(/shape/);
      expect(() => cache.append(latent, rope)).toThrow(/requires DSA/);
      expect(() => cache.append(latent, rope, wrongDsa)).toThrow(/shape/);
      expect(() => cache.append(intLatent, rope, dsa)).toThrow(/float32/);
      expect(cache.offset).toBe(0);

      cache.append(latent, rope, dsa);
      expect(() => cache.append(batchLatent, batchRope, batchDsa))
        .toThrow(/batch size/);
      expect(cache.offset).toBe(1);

      const twoLatent = f32([1, 2, 3, 4, 5, 6], [1, 2, 3]);
      const twoRope = f32([1, 2, 3, 4], [1, 2, 2]);
      const twoDsa = f32([1, 2, 3, 4], [1, 2, 2]);
      try {
        expect(() => cache.append(twoLatent, twoRope, twoDsa))
          .toThrow(/exceed maxTokens/);
        expect(cache.offset).toBe(1);
      } finally {
        twoLatent.dispose();
        twoRope.dispose();
        twoDsa.dispose();
      }

      expect(() => cache.trim(-1)).toThrow(/cannot trim/);
      expect(() => cache.trim(2)).toThrow(/cannot trim/);
      expect(cache.offset).toBe(1);
    } finally {
      for (const array of [
        latent,
        rope,
        dsa,
        wrongLatent,
        wrongRope,
        wrongDsa,
        intLatent,
        batchLatent,
        batchRope,
        batchDsa,
      ]) {
        array.dispose();
      }
      cache.dispose();
    }

    const noDsa = new MLACache({ kvLoraRank: 3, ropeHeadDim: 2 });
    const noDsaLatent = f32([1, 2, 3], [1, 1, 3]);
    const noDsaRope = f32([4, 5], [1, 1, 2]);
    const extraDsa = f32([6], [1, 1, 1]);
    try {
      expect(() => noDsa.append(noDsaLatent, noDsaRope, extraDsa))
        .toThrow(/without DSA/);
      expect(noDsa.offset).toBe(0);
    } finally {
      noDsaLatent.dispose();
      noDsaRope.dispose();
      extraDsa.dispose();
      noDsa.dispose();
    }
  });

  test("projects exact f32 bytes and builds causal masks from the prior offset", () => {
    const geometry = {
      kvLoraRank: 512,
      ropeHeadDim: 64,
      dsa: { headDim: 128 },
    };
    expect(MLACache.projectedByteLength(geometry, 2, 7)).toBe(
      2 * 7 * (512 + 64 + 128) * 4,
    );
    expect(MLACache.projectedByteLength(
      { kvLoraRank: 512, ropeHeadDim: 64 },
      1,
      0,
    )).toBe(0);

    const cache = new MLACache({ kvLoraRank: 1, ropeHeadDim: 1 });
    const latent = f32([1, 2], [1, 2, 1]);
    const rope = f32([3, 4], [1, 2, 1]);
    try {
      expect(cache.makeMask(2, null)).toEqual({ mode: "causal", arr: null });
      cache.append(latent, rope);
      expect(cache.makeMask(1, null)).toEqual({ mode: "", arr: null });
      const windowed = cache.makeMask(2, 2);
      expect(windowed.mode).toBe("array");
      expect(windowed.arr!.shape).toEqual([2, 4]);
      windowed.arr!.dispose();
      expect(() => cache.makeMask(0, null)).toThrow(/positive/);
      expect(() => cache.makeMask(1, 0)).toThrow(/positive/);
    } finally {
      latent.dispose();
      rope.dispose();
      cache.dispose();
    }
  });
});
