// Native transform constructors receive initialized, live out-slots. If the
// transform reports failure, the wrapper still owns that slot handle plus its
// source closures and JS callbacks. These injected failures account for every
// resource and reject wrong-kind or duplicate frees.

import { describe, expect, test } from "bun:test";
import { ValueAndGrad } from "../../src/mlx/autograd";
import { Checkpoint } from "../../src/mlx/checkpoint";
import { CustomVjp } from "../../src/mlx/custom-vjp";

type ResourceKind = "closure" | "value-and-grad" | "custom-closure";

function resourceTracker() {
  let next = 100n;
  const live = new Map<bigint, ResourceKind>();
  const alloc = (kind: ResourceKind): bigint => {
    const handle = next++;
    live.set(handle, kind);
    return handle;
  };
  const free = (kind: ResourceKind, handle: bigint): void => {
    const actual = live.get(handle);
    if (actual === undefined) throw new Error(`double/unknown free of ${handle}`);
    if (actual !== kind)
      throw new Error(`wrong free for ${handle}: expected ${actual}, got ${kind}`);
    live.delete(handle);
  };
  return { live, alloc, free };
}

function callbackTracker() {
  let nextPtr = 1;
  let live = 0;
  const callback = () => {
    live++;
    let closed = false;
    return {
      ptr: nextPtr++ as never,
      close: () => {
        if (closed) throw new Error("callback closed twice");
        closed = true;
        live--;
      },
    };
  };
  return { callback, live: () => live };
}

describe("native transform constructor failure ownership", () => {
  test("ValueAndGrad frees its initialized result slot, source closure, and callback", () => {
    const resources = resourceTracker();
    const callbacks = callbackTracker();

    for (let i = 0; i < 4; i++) {
      expect(() => new ValueAndGrad(
        () => { throw new Error("unused"); },
        [0],
        {
          callback: callbacks.callback,
          closureNew: () => resources.alloc("closure"),
          transformedNew: () => resources.alloc("value-and-grad"),
          transform: () => 1,
          transformedFree: (handle) => {
            resources.free("value-and-grad", BigInt(handle));
            return 0;
          },
          closureFree: (handle) => {
            resources.free("closure", BigInt(handle));
            return 0;
          },
        },
      )).toThrow("mlx_value_and_grad failed");
      expect(resources.live.size).toBe(0);
      expect(callbacks.live()).toBe(0);
    }
  });

  test("Checkpoint frees its initialized result slot, source closure, and callback", () => {
    const resources = resourceTracker();
    const callbacks = callbackTracker();

    for (let i = 0; i < 4; i++) {
      expect(() => new Checkpoint(
        () => [],
        {
          callback: callbacks.callback,
          closureNew: () => resources.alloc("closure"),
          transformedNew: () => resources.alloc("closure"),
          transform: () => 1,
          closureFree: (handle) => {
            resources.free("closure", BigInt(handle));
            return 0;
          },
        },
      )).toThrow("mlx_checkpoint failed");
      expect(resources.live.size).toBe(0);
      expect(callbacks.live()).toBe(0);
    }
  });

  test("CustomVjp frees its result slot, both source closures, and both callbacks", () => {
    const resources = resourceTracker();
    const callbacks = callbackTracker();

    for (let i = 0; i < 4; i++) {
      expect(() => new CustomVjp(
        () => [],
        () => [],
        {
          callback: callbacks.callback,
          forwardClosureNew: () => resources.alloc("closure"),
          vjpClosureNew: () => resources.alloc("custom-closure"),
          transformedNew: () => resources.alloc("closure"),
          transform: () => 1,
          closureFree: (handle) => {
            resources.free("closure", BigInt(handle));
            return 0;
          },
          customClosureFree: (handle) => {
            resources.free("custom-closure", BigInt(handle));
            return 0;
          },
        },
      )).toThrow("mlx_custom_vjp failed");
      expect(resources.live.size).toBe(0);
      expect(callbacks.live()).toBe(0);
    }
  });

  test("CustomVjp closes the forward callback when the VJP callback allocation throws", () => {
    let callbackCalls = 0;
    let forwardCloses = 0;

    expect(() => new CustomVjp(
      () => [],
      () => [],
      {
        callback: () => {
          callbackCalls++;
          if (callbackCalls === 2) throw new Error("VJP callback allocation failed");
          let closed = false;
          return {
            ptr: 1 as never,
            close: () => {
              if (closed) throw new Error("forward callback closed twice");
              closed = true;
              forwardCloses++;
            },
          };
        },
      },
    )).toThrow("VJP callback allocation failed");

    expect(callbackCalls).toBe(2);
    expect(forwardCloses).toBe(1);
  });
});

describe("native transform constructor success lifecycle", () => {
  test("Checkpoint and CustomVjp still construct and dispose idempotently", () => {
    const checkpoint = new Checkpoint((inputs) => inputs);
    checkpoint.dispose();
    checkpoint.dispose();

    const custom = new CustomVjp(
      (inputs) => inputs,
      (primals) => primals,
    );
    custom.dispose();
    custom.dispose();
  });
});
