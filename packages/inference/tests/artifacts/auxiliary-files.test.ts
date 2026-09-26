import { afterEach, expect, test } from "bun:test";
import { mkdtemp, readdir, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { copyAuxFiles } from "../../src/artifacts/auxiliary-files";

const KNOWN = [
  "tokenizer.json", "tokenizer_config.json", "tokenizer.model", "spiece.model", "chat_template.jinja",
  "generation_config.json", "special_tokens_map.json", "added_tokens.json", "vocab.json", "merges.txt",
  "README.md", "kv_config.json",
];

const scratch: string[] = [];
afterEach(async () => { for (const dir of scratch.splice(0)) await rm(dir, { recursive: true, force: true }); });
async function tempDir(): Promise<string> {
  const dir = await mkdtemp(join(tmpdir(), "mlx-aux-files-"));
  scratch.push(dir);
  return dir;
}

test("copies exactly the known aux files and extra *.model sidecars, byte for byte", async () => {
  const src = await tempDir(), out = await tempDir();
  for (const name of [...KNOWN, "custom.model", "config.json", "model.safetensors", "notes.txt"])
    await writeFile(join(src, name), `contents of ${name}`);
  await copyAuxFiles(src, out);
  const copied = (await readdir(out)).toSorted();
  expect(copied).toEqual([...KNOWN, "custom.model"].toSorted());
  for (const name of copied) expect(await readFile(join(out, name), "utf8")).toBe(`contents of ${name}`);
});

test("absent aux files are skipped and an unreadable source is not an error", async () => {
  const src = await tempDir(), out = await tempDir();
  await writeFile(join(src, "tokenizer.json"), "{}");
  await copyAuxFiles(src, out);
  expect(await readdir(out)).toEqual(["tokenizer.json"]);
  await copyAuxFiles(join(src, "missing"), out);
  expect(await readdir(out)).toEqual(["tokenizer.json"]);
});

test("known-file write errors propagate; the extra *.model sweep is best-effort", async () => {
  const src = await tempDir(), dir = await tempDir();
  const notADirectory = join(dir, "file");
  await writeFile(notADirectory, "");
  await writeFile(join(src, "custom.model"), "sidecar");
  await copyAuxFiles(src, notADirectory);
  await writeFile(join(src, "tokenizer.json"), "{}");
  await expect(copyAuxFiles(src, notADirectory)).rejects.toThrow();
});

// With the native override pointed at nothing, MLX cannot load; the helper's
// subpath still imports, while the artifacts barrel (native weights) does not.
async function importsWithoutMlx(specifier: string): Promise<number> {
  const child = Bun.spawn([process.execPath, "-e", `await import(${JSON.stringify(specifier)})`], {
    cwd: join(import.meta.dir, "../.."), env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" },
    stdout: "ignore", stderr: "pipe",
  });
  await new Response(child.stderr).text();
  return child.exited;
}

test("the auxiliary-files entry imports without loading MLX", async () => {
  expect(await importsWithoutMlx("@mlx-bun/inference/artifacts/auxiliary-files")).toBe(0);
  expect(await importsWithoutMlx("@mlx-bun/inference/artifacts")).not.toBe(0);
});
