import { expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { chooseAutoModel, COEXIST_FRACTION, DEFAULT_REPO_ID, largestRecommendedRepoId, STARTER_REPO_ID } from "mlx-bun/selection";

// The public `mlx-bun/selection` entry, imported through the package export map
// as a consumer would. No model, no native library.

const packageRoot = resolve(import.meta.dir, "..");
const GiB = 2 ** 30;

test("the entry imports through the export map without native MLX and exposes only the selection helpers", async () => {
  const child = Bun.spawn([process.execPath, "--no-env-file", "-e",
    'const entry = await import("mlx-bun/selection"); console.log(JSON.stringify(Object.keys(entry).sort()));'], {
    cwd: packageRoot, stdout: "pipe", stderr: "pipe",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/mlx-selection-import-test.dylib" },
  });
  const deadline = setTimeout(() => child.kill("SIGKILL"), 10_000);
  try {
    const [stdout, stderr, code] = await Promise.all([
      new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited,
    ]);
    expect({ code, stderr }).toEqual({ code: 0, stderr: "" });
    expect(JSON.parse(stdout)).toEqual(["COEXIST_FRACTION", "DEFAULT_REPO_ID", "STARTER_REPO_ID", "chooseAutoModel", "largestRecommendedRepoId"]);
  } finally { clearTimeout(deadline); }
  expect(readFileSync(join(packageRoot, "src/cli/model-choice.ts"), "utf8")).not.toMatch(/^\s*import\s+(?!type\s)/m);
});

test("the constants keep main's values", () => {
  expect(DEFAULT_REPO_ID).toBe("mlx-community/gemma-4-e4b-it-OptiQ-4bit");
  expect(STARTER_REPO_ID).toBe("mlx-community/MiniCPM5-1B-OptiQ-4bit");
  expect(COEXIST_FRACTION).toBe(0.6);
  const small = { repoId: "small", sizeBytes: 1 }, large = { repoId: "large", sizeBytes: 2 };
  expect(chooseAutoModel([small, large], DEFAULT_REPO_ID, () => true, candidate => candidate === small)).toBe(small);
});

test("largestRecommendedRepoId uses main's RAM tiers at their exact boundaries", () => {
  expect(largestRecommendedRepoId(24 * GiB - 1)).toBe(DEFAULT_REPO_ID);
  expect(largestRecommendedRepoId(24 * GiB)).toBe("mlx-community/gemma-4-12B-it-OptiQ-4bit");
  expect(largestRecommendedRepoId(48 * GiB - 1)).toBe("mlx-community/gemma-4-12B-it-OptiQ-4bit");
  expect(largestRecommendedRepoId(48 * GiB)).toBe("mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit");
});

test("largestRecommendedRepoId is an explicit opt-in that no application source calls", () => {
  const callers = [...new Bun.Glob("**/*.{ts,tsx}").scanSync(join(packageRoot, "src"))]
    .filter(path => readFileSync(join(packageRoot, "src", path), "utf8").includes("largestRecommendedRepoId"));
  expect(callers).toEqual(["cli/model-choice.ts"]);
});
