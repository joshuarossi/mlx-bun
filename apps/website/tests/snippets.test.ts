import { describe, expect, test } from "bun:test";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { exampleBody } from "../src/snippets";

const root = resolve(import.meta.dir, "../../..");
/** The examples the landing page renders. */
const examples = ["packages/mlx/examples/arrays.ts", "packages/inference/examples/qwen3-generate.ts"];

describe("exampleBody", () => {
  test("keeps the example and drops its runner", () => {
    const source = "import { x } from \"y\";\n\nexport const a = x;\n\nif (import.meta.main) console.log(a);\n";
    expect(exampleBody(source, "a.ts")).toBe("import { x } from \"y\";\n\nexport const a = x;\n");
  });
  test("refuses a source without a runner, naming the file", () => {
    expect(() => exampleBody("export const a = 1;\n", "a.ts")).toThrow("a.ts");
  });
  test("the landing page's examples trim to their bodies", async () => {
    for (const path of examples) {
      const body = exampleBody(await readFile(resolve(root, path), "utf8"), path);
      expect(body).not.toContain("import.meta.main");
      expect(body).toContain("export");
    }
  });
});
