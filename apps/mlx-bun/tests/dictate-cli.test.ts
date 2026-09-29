// The spawned CLI answers the module's `dictate` verb: help and argument errors
// with native MLX blocked. The live loop over a fake capture source is the
// module's (`packages/module-transcription/tests/dictate.test.ts`).
import { expect, test } from "bun:test";
import { resolve } from "node:path";

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");

async function cli(...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", entry, ...args], {
    env: { ...process.env, HF_HUB_CACHE: "/nonexistent/hub", HF_HUB_OFFLINE: "1", NO_COLOR: "1", MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" },
    stdout: "pipe", stderr: "pipe",
  });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

test("the spawned CLI answers dictate help and argument errors with native MLX blocked", async () => {
  const helpRun = await cli("dictate", "--help");
  expect(helpRun.code).toBe(0); expect(helpRun.err).toBe("");
  expect(helpRun.out).toContain("Usage: mlx-bun dictate [query] [options]");
  for (const flag of ["--server", "--hotkey", "--copy", "--type", "--idle-unload", "--no-vad"]) expect(helpRun.out).toContain(flag);
  const unknown = await cli("dictate", "--hotkey", "--bogus");
  expect(unknown.code).toBe(1); expect(unknown.out).toBe(""); expect(unknown.err).toContain("Unknown option '--bogus'");
  const invalid = await cli("dictate", "--idle-unload", "x");
  expect(invalid).toEqual({ out: "", err: "invalid --idle-unload: x\n", code: 1 });
});
