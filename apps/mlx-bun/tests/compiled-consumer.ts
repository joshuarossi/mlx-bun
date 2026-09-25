// Executed only as a relocated standalone binary by scripts/verify-binary.ts.
import assert from "node:assert/strict";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { Registry } from "@mlx-bun/hub/registry";
import { fit } from "@mlx-bun/hub/fit";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";
import { resolveLibmlxc } from "../../../packages/mlx/src/native";
import { EXPERT_IO_LIBRARY, FRAME_EXTRACT_BINARY, resolveInferenceNative } from "../../../packages/inference/src/runtime/native";
import { createWebHandler } from "../src/web/assets";
import { createMemorySurface } from "../src/memory/surface";
import { JobStore } from "../src/jobs/db";
import { createJobHost } from "../src/jobs/host";
import { resizeImage } from "@earendil-works/pi-coding-agent";

const directory = dirname(process.execPath), temporary = resolve(process.argv[2]!);
assert(import.meta.filename.startsWith("/$bunfs/"));
assert.equal(resolveLibmlxc(), join(directory, "libmlxc.dylib"));
assert.equal(EXPERT_IO_LIBRARY, join(directory, "libmlx_bun_expert_io.dylib"));
assert.equal(FRAME_EXTRACT_BINARY, join(directory, "mlx-bun-frame-extract"));
process.env.MLX_BUN_LIBMLXC = "/explicit/libmlxc.dylib";
assert.equal(resolveLibmlxc(), "/explicit/libmlxc.dylib");
assert.equal(resolveInferenceNative("mlx-bun-frame-extract", "/explicit/extract"), "/explicit/extract");
// No native library may load during the CPU consumer checks or their child.
process.env.MLX_BUN_LIBMLXC = "/nonexistent/libmlxc.dylib";

const web = await createWebHandler();
for (const path of ["/", "/assets/app.js", "/assets/hljs.js", "/assets/hljs.css", "/manifest.webmanifest", "/assets/icon.svg", "/sw.js"]) {
  const response = web(new Request(`http://local${path}`));
  assert.equal(response?.status, 200, path);
  assert((await response!.text()).length > 0, path);
}
const vault = join(temporary, "vault"); await mkdir(join(vault, "articles"), { recursive: true });
const memory = await createMemorySurface(vault, join(temporary, "skills"));
assert(memory); assert(memory.toolNames.includes("memory_section"));
assert((await readFile(join(memory.skillPaths[0]!, "SKILL.md"), "utf8")).includes("name: memory"));

const snapshot = join(temporary, "hub/models--test--tiny/snapshots/test");
await mkdir(snapshot, { recursive: true });
await writeFile(join(snapshot, "config.json"), JSON.stringify({ model_type: "qwen3", hidden_size: 64,
  num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 1, head_dim: 32,
  intermediate_size: 64, vocab_size: 64, rms_norm_eps: 1e-6, max_position_embeddings: 128,
  tie_word_embeddings: true, quantization: { group_size: 64, bits: 4 } }));
await writeFile(join(snapshot, "model.safetensors"), new Uint8Array(4096));
const registry = new Registry(join(temporary, "registry.sqlite"));
try {
  await registry.scan(join(temporary, "hub"));
  const record = registry.resolve("tiny");
  assert.equal(record.path, snapshot);
  assert(fit(await loadModelConfig(snapshot), record.sizeBytes, 128,
    { name: "synthetic", ramBytes: 8 * 2 ** 30, bandwidthGBs: 100 }).fits);
} finally { registry.close(); }

const image = Buffer.from("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==", "base64");
const resized = await resizeImage(image, "image/png", { maxWidth: 1, maxHeight: 1 });
assert(resized && resized.width === 1 && resized.height === 1, "Pi Photon WASM did not initialize");

const store = new JobStore(join(temporary, "jobs.sqlite"), join(temporary, "jobs"));
let leases = 0, spawned = false;
const host = createJobHost({ entry: new URL("../src/cli/job-entry.ts", import.meta.url).pathname,
  createStore: () => store, acquire: async () => { leases++; return { dispose() { leases--; } }; },
  spawn: ((command: string[], options: Parameters<typeof Bun.spawn>[1]) => {
    assert.equal(command[1], "__job"); spawned = true;
    // The managed launcher runs the actual product executable, not this consumer.
    return Bun.spawn([join(directory, "mlx-bun"), ...command.slice(1)], options);
  }) as typeof Bun.spawn,
});
try {
  const job = host.submit("finetune", {}, join(temporary, "adapter"));
  const deadline = Date.now() + 15000;
  while (store.get(job.jobId)?.status !== "failed") {
    assert(Date.now() < deadline, "compiled managed child timed out"); await Bun.sleep(10);
  }
  assert.match(store.get(job.jobId)!.error ?? "", /model_dir/);
  assert(spawned);
} finally { await host.close(); }
assert.equal(leases, 0);
console.log("Relocated bundle: web, memory, fit, native paths, Photon and managed child passed (CPU only).");
