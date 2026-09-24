import { expect, test } from "bun:test";
import { CompiledFunction, MlxArray, ops } from "@mlx-bun/mlx";

test("compiled operations replay with new values and shapes", () => {
  const graph = new CompiledFunction(([x]) => [ops.mulScalar(x!, 2)]);
  try {
    for (const values of [[1, 2], [3, 4], [-1, 0, 5]]) {
      using input = MlxArray.fromFloat32(new Float32Array(values), [values.length]);
      const [output] = graph.apply([input]);
      try {
        expect([...output!.toFloat32()]).toEqual(values.map((value) => value * 2));
      } finally {
        output!.dispose();
      }
    }
    expect(graph.traceCount).toBe(1);
  } finally {
    graph.dispose();
  }
});
