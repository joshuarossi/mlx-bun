import { expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

const launcher = resolve(import.meta.dir, "../bin/mlx-bun.mjs");
const manifest = JSON.parse(readFileSync(resolve(import.meta.dir, "../package.json"), "utf8"));
const minimum = manifest.engines.bun.slice(2);

async function run(command: string[]) {
  const child = Bun.spawn(command, { stdout: "pipe", stderr: "pipe",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" } });
  const [out, err, code] = await Promise.all([
    new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited,
  ]);
  return { out, err, code };
}

test("launcher help and exact package version work without native MLX", async () => {
  expect(manifest.engines.bun).toMatch(/^>=\d+\.\d+\.\d+$/);
  expect(await run([process.execPath, "--no-env-file", launcher, "--version"]))
    .toEqual({ out: `mlx-bun ${manifest.version}\n`, err: "", code: 0 });
  const help = await run([process.execPath, "--no-env-file", launcher, "--help"]);
  expect(help.code).toBe(0); expect(help.err).toBe(""); expect(help.out).toContain("Usage: mlx-bun");
});

// Node is optional for contributors using only Bun. When present, exercise the
// actual incompatible runtime: it must never reach the application's Bun imports.
const node = Bun.which("node");
test.skipIf(!node)("Node receives the Bun installation hint before application imports", async () => {
  const result = await run([node!, launcher, "--help"]);
  expect(result.code).toBe(1);
  expect(result.err).toContain(`requires Bun >= ${minimum}`);
  expect(result.err).toContain("bunx mlx-bun");
  expect(result.err).not.toContain("bun:");
});

test.skipIf(!node)("launcher rejects old Bun and unsupported platforms before app imports", async () => {
  const entry = JSON.stringify(pathToFileURL(launcher).href);
  const old = await run([node!, "--input-type=module", "-e", `globalThis.Bun = { version: "0.0.1" }; await import(${entry});`]);
  expect(old.code).toBe(1); expect(old.err).toContain("Run: bun upgrade");
  for (const [platform, arch] of [["linux", "arm64"], ["darwin", "x64"]]) {
    const unsupported = await run([node!, "--input-type=module", "-e", `
      globalThis.Bun = { version: ${JSON.stringify(minimum)} };
      Object.defineProperty(process, "platform", { value: ${JSON.stringify(platform)} });
      Object.defineProperty(process, "arch", { value: ${JSON.stringify(arch)} });
      await import(${entry});
    `]);
    expect(unsupported.code).toBe(1); expect(unsupported.err).toContain("Apple Silicon Macs only");
    expect(unsupported.err).not.toContain("bun:");
  }
});
