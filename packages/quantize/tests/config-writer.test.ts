import { afterEach, expect, test } from "bun:test";
import { mkdtemp, readdir, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { copyAuxFiles as owner } from "@mlx-bun/inference/artifacts/auxiliary-files";
import { copyAuxFiles, writeQuantizedConfig } from "../src/config-writer";

const scratch: string[] = [];
afterEach(async () => { for (const dir of scratch.splice(0)) await rm(dir, { recursive: true, force: true }); });
async function tempDir(): Promise<string> {
  const dir = await mkdtemp(join(tmpdir(), "mlx-config-writer-"));
  scratch.push(dir);
  return dir;
}

test("config-writer keeps copyAuxFiles as a re-export of the inference owner", () => {
  expect(copyAuxFiles).toBe(owner);
});

test("writeQuantizedConfig still copies aux files from srcDir", async () => {
  const src = await tempDir(), out = await tempDir();
  for (const name of ["tokenizer.json", "chat_template.jinja", "custom.model", "model.safetensors"])
    await writeFile(join(src, name), name);
  const block = { group_size: 64, bits: 4, mode: "affine" };
  await writeQuantizedConfig({ model_type: "qwen3" }, out, block, { srcDir: src });
  expect((await readdir(out)).toSorted()).toEqual(["chat_template.jinja", "config.json", "custom.model", "tokenizer.json"]);
  const config = JSON.parse(await readFile(join(out, "config.json"), "utf8"));
  expect(config).toEqual({ model_type: "qwen3", quantization: block, quantization_config: block });
});
