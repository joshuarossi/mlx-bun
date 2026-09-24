import { expect, test } from "bun:test";
import { join } from "node:path";

// Listing and fitting models reads headers, never tensors. Proof: with the
// native override pointed at nothing, MLX cannot load, and these imports still succeed.
const env = { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" };
const root = join(import.meta.dir, "..");

async function imports(specifier: string): Promise<number> {
  const child = Bun.spawn([process.execPath, "-e", `await import(${JSON.stringify(specifier)})`], {
    cwd: root, env, stdout: "ignore", stderr: "pipe",
  });
  await new Response(child.stderr).text();
  return child.exited;
}

test("registry, fit, and the example import without loading MLX", async () => {
  expect(await imports("./src/registry.ts")).toBe(0);
  expect(await imports("./src/fit.ts")).toBe(0);
  expect(await imports("./examples/fit-models.ts")).toBe(0);
});

test("the override really blocks MLX, so the check above is meaningful", async () => {
  expect(await imports("@mlx-bun/mlx")).not.toBe(0);
});
