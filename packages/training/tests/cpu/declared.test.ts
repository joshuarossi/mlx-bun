import { describe, expect, test } from "bun:test";
import { declaredTraining, declaredTrainingOrNull, lmHeadOf, trainableOf } from "../../src/declared";

// A stand-in graph that declares only a head and a flash refusal: the trainer's
// view of a graph is these declarations, never its class.
const head = { w: {}, scales: {}, biases: null, spec: {}, softcap: 30 };
const graph = {
  trainable: {
    lmHead: () => head,
    flashAttention: { supported: false, reason: "crashes at long sequences" },
  },
} as never;

describe("a graph's declared training operations", () => {
  test("returns what the graph declares", () => {
    expect(lmHeadOf(graph)).toBe(head as never);
    expect(declaredTraining(graph, "flashAttention", "flash")).toEqual({ supported: false, reason: "crashes at long sequences" });
  });

  test("names the declaration a graph lacks", () => {
    expect(() => declaredTraining(graph, "segmented", "segmented backward")).toThrow("the graph does not declare segmented backward");
    expect(() => declaredTraining(graph, "prefixShared", "prefix-shared training")).toThrow("does not declare prefix-shared training");
    expect(() => lmHeadOf({ trainable: {} })).toThrow("does not declare a quantized LM head");
    expect(() => trainableOf({})).toThrow("does not declare training operations");
  });

  test("an optional part is null when undeclared", () => {
    expect(declaredTrainingOrNull(graph, "gradCheckpoint")).toBeNull();
    const checkpoint = { enable: () => ({}) };
    expect(declaredTrainingOrNull({ trainable: { gradCheckpoint: checkpoint } }, "gradCheckpoint")).toBe(checkpoint as never);
    expect(declaredTrainingOrNull({}, "gradCheckpoint")).toBeNull();
  });
});
