import { expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const launcher = resolve(import.meta.dir, "typecheck.ts");

function run(args: string[], compiler?: string, cwd = resolve(import.meta.dir, "..")) {
  const env = { ...process.env };
  delete env.MLX_BUN_TYPECHECK_COMPILER;
  if (compiler !== undefined) env.MLX_BUN_TYPECHECK_COMPILER = compiler;
  const result = Bun.spawnSync([process.execPath, launcher, ...args], {
    cwd, env, stdout: "pipe", stderr: "pipe", timeout: 15_000,
  });
  return { exitCode: result.exitCode, output: result.stdout.toString() + result.stderr.toString() };
}

test("the default launcher uses the pinned official TypeScript compiler", () => {
  const result = run(["--version"]);
  expect(result.exitCode).toBe(0);
  expect(result.output.trim()).toBe("Version 6.0.3");
});

test("an unknown compiler selector fails explicitly", () => {
  const result = run(["--version"], "unknown-compiler");
  expect(result.exitCode).not.toBe(0);
  expect(result.output).toContain("Unknown MLX_BUN_TYPECHECK_COMPILER: unknown-compiler");
});

for (const compiler of [undefined, "tsc-rs"]) {
  test(`${compiler ?? "default TypeScript"} preserves project paths, diagnostics and exit status`, () => {
    const directory = mkdtempSync(join(tmpdir(), "mlx typecheck "));
    try {
      mkdirSync(join(directory, "config files"));
      writeFileSync(join(directory, "config files", "type check.json"), JSON.stringify({
        compilerOptions: { strict: true, noEmit: true, target: "ES2022", types: [], skipLibCheck: true },
        files: ["../input.ts"],
      }));
      const args = ["--project", "config files/type check.json", "--pretty", "false"];
      writeFileSync(join(directory, "input.ts"), "export const answer: number = 'wrong';\n");
      const invalid = run(args, compiler, directory);
      expect(invalid.exitCode).not.toBe(0);
      expect(invalid.output).toContain("TS2322");

      writeFileSync(join(directory, "input.ts"), "export const answer: number = 42;\n");
      const valid = run(args, compiler, directory);
      expect(valid.output).toBe("");
      expect(valid.exitCode).toBe(0);
    } finally {
      rmSync(directory, { recursive: true, force: true });
    }
  }, 30_000);
}
