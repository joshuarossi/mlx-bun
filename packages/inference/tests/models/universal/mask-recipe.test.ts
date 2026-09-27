import { expect, test } from "bun:test";
import { universalCacheWindows, universalMaskRecipe, type UniversalArgs } from "../../../src/models/universal/archs";

// The recipe is bound from descriptor facts alone; no native library loads.
const args = (layerTypes: string[] | null, extra: Partial<UniversalArgs> = {}) =>
  ({ numHiddenLayers: layerTypes?.length ?? 4, layerTypes, slidingWindow: layerTypes ? 8 : null, maskArray: false, ...extra }) as UniversalArgs;
const F = "full_attention", S = "sliding_attention";

test("each attention group reads its mask from its own first cache", () => {
  expect(universalMaskRecipe(args(null))).toEqual({ full: 0, sliding: null, window: null, array: false,
    slidingLayers: [false, false, false, false] });
  expect(universalMaskRecipe(args([F, S, F, S]))).toEqual({ full: 0, sliding: 1, window: 8, array: false,
    slidingLayers: [false, true, false, true] });
  expect(universalMaskRecipe(args([S, F, S, F]))).toEqual({ full: 1, sliding: 0, window: 8, array: false,
    slidingLayers: [true, false, true, false] });
  // Without a full layer the full mask still comes from cache 0 and serves no layer.
  expect(universalMaskRecipe(args([S, S]))).toMatchObject({ full: 0, sliding: 0, slidingLayers: [true, true] });
  expect(universalMaskRecipe(args([F, F]))).toMatchObject({ full: 0, sliding: null, slidingLayers: [false, false] });
});

test("explicit-mask graphs keep the same groups and only change the spelling", () => {
  // Gemma2: no layer types, every layer full, cache 0 (main's selection).
  expect(universalMaskRecipe(args(null, { maskArray: true }))).toEqual({ full: 0, sliding: null, window: null, array: true,
    slidingLayers: [false, false, false, false] });
  // A mixed explicit-mask graph no longer takes cache 0's mask for every layer.
  for (const types of [[F, S, F, S], [S, F, S, F]]) {
    const recipe = universalMaskRecipe(args(types, { maskArray: true }));
    expect(recipe.array).toBe(true);
    expect(recipe.slidingLayers).toEqual(types.map(type => type === S));
    expect(types[recipe.full]).toBe(F);
    expect(types[recipe.sliding!]).toBe(S);
  }
});

test("the cache layout comes from the same descriptor facts", () => {
  expect(universalCacheWindows(args([F, S, F, S]))).toEqual([null, 8, null, 8]);
  expect(universalCacheWindows(args([S, F]))).toEqual([8, null]);
  expect(universalCacheWindows(args(null))).toEqual([null, null, null, null]);
  // A sliding type without a window keeps plain KV, as before.
  expect(universalCacheWindows(args([S, F], { slidingWindow: null }))).toEqual([null, null]);
  const descriptor = args([S, F]), windows = universalCacheWindows(descriptor);
  descriptor.layerTypes!.reverse(); descriptor.slidingWindow = 99;
  expect(windows).toEqual([8, null]);
  expect(Object.isFrozen(windows)).toBe(true);
});

test("the recipe is frozen at construction", () => {
  const descriptor = args([F, S]);
  const recipe = universalMaskRecipe(descriptor);
  descriptor.layerTypes!.reverse();
  expect(recipe.slidingLayers).toEqual([false, true]);
  expect(Object.isFrozen(recipe) && Object.isFrozen(recipe.slidingLayers)).toBe(true);
});
