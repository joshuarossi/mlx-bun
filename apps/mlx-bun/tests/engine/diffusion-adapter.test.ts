// Opt-in with real weights: DiffusionGemma serves a saved LoRA adapter through
// the app, as main's denoising generation applied mounted adapters per request.
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_APP_TEST_DIFFUSION_MODEL=<DiffusionGemma snapshot> \
//   MLX_BUN_APP_TEST_DIFFUSION_ADAPTER=<adapter directory> bun test tests/engine/diffusion-adapter.test.ts
// The adapter is one `trainDiffusionLora` saved in the mountable layout, for
// example the training package's DiffusionGemma LoRA check run with
// MLX_BUN_TRAINING_DIFFUSION_ADAPTER_OUT. It is copied to a temporary
// directory; MLX_BUN_APP_TEST_DIFFUSION_ADAPTER_SCALE=<number> rewrites the
// copy's recorded scale when the adapter as trained leaves this seeded
// generation unchanged, because every isolation check below would then be
// vacuous and the test fails instead. Checks: hot mount and unmount over HTTP,
// seeded greedy output per selection (adapter, "none", no field), an adapter
// row and a base row released together each equal to their solo run, an
// unknown adapter refused after unmount, and `--adapter` at startup as the
// default for requests without an adapter field. This is app consistency and
// isolation, not parity against main.
import { expect, test } from "bun:test";
import { cpSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { RunningApp } from "../../src/cli/serve";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_APP_TEST_DIFFUSION_MODEL;
const adapterDir = process.env.MLX_BUN_APP_TEST_DIFFUSION_ADAPTER;
const scaleOverride = process.env.MLX_BUN_APP_TEST_DIFFUSION_ADAPTER_SCALE;
const ADAPTER_ID = "diffusion-lora";

/** Adapted modules in a safetensors adapter, read from its header without loading tensors. */
function loraModules(file: string): number {
  const bytes = readFileSync(file);
  const length = Number(bytes.readBigUInt64LE(0));
  const header = JSON.parse(bytes.subarray(8, 8 + length).toString("utf8")) as Record<string, unknown>;
  return Object.keys(header).filter(name => /\.lora_a$/i.test(name)).length;
}

test.skipIf(!native || !modelDir || !adapterDir)("DiffusionGemma applies a mounted adapter per request, interleaved and as the startup default", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-diffusion-adapter-")), adapter = join(root, ADAPTER_ID);
  cpSync(adapterDir!, adapter, { recursive: true });
  if (scaleOverride !== undefined) {
    const scale = Number(scaleOverride);
    if (!Number.isFinite(scale) || scale <= 0) throw new Error(`MLX_BUN_APP_TEST_DIFFUSION_ADAPTER_SCALE must be a positive number: ${scaleOverride}`);
    const file = join(adapter, "optiq_lora_config.json");
    const config = JSON.parse(readFileSync(file, "utf8")) as { scale?: number; lora_parameters?: { scale?: number } };
    writeFileSync(file, JSON.stringify({ ...config, scale, lora_parameters: { ...config.lora_parameters, scale } }, null, 2) + "\n");
  }
  const modules = loraModules(join(adapter, "adapters.safetensors"));
  expect(modules).toBeGreaterThan(0);
  let app: RunningApp | undefined;
  try {
    const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
    const { scanSnapshot } = await import("@mlx-bun/hub/registry");
    const model = await scanSnapshot(modelDir!, "test-diffusion");
    if (!model) throw new Error("Model path has no loadable checkpoint");
    const start = async (values: Record<string, string | boolean>) => {
      const options = parseServeOptions({ values: { port: "0", "max-tokens": "32", "no-open": true, thinking: "off", ...values }, positionals: [] });
      options.readOnly = true;
      options.chatPaths = { cwd: join(root, "project"), agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
      options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
      mkdirSync(options.chatPaths.cwd!, { recursive: true });
      app = await startModelServer(model, options);
      return new URL(`http://127.0.0.1:${app.port}`);
    };
    let base = await start({});
    const ask = async (body: Record<string, unknown>) => {
      const response = await fetch(new URL("/v1/chat/completions", base), { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ messages: [{ role: "user", content: "Write a haiku about Apple Silicon." }], max_tokens: 32, temperature: 0, seed: 7, ...body }) });
      const text = await response.text();
      expect(response.status, text).toBe(200);
      const completion = JSON.parse(text);
      const message = completion.choices[0].message;
      return { content: message.content ?? "", reasoning: message.reasoning ?? "", finish: completion.choices[0].finish_reason,
        tokens: completion.usage.completion_tokens as number };
    };

    const plain = await ask({});
    expect(plain.tokens).toBeGreaterThan(0);
    expect(await ask({ adapter: "none" })).toEqual(plain);

    const mounted = await fetch(new URL("/v1/adapters", base), { method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ id: ADAPTER_ID, path: adapter }) });
    expect(mounted.status).toBe(200);
    expect((await mounted.json()).mounted_layers).toBe(modules);
    const adapted = await ask({ adapter: ADAPTER_ID });
    expect(adapted, "the adapter leaves this seeded generation unchanged; set MLX_BUN_APP_TEST_DIFFUSION_ADAPTER_SCALE").not.toEqual(plain);
    expect(await ask({ adapter: ADAPTER_ID })).toEqual(adapted);
    // Mounting does not make an adapter the default.
    expect(await ask({})).toEqual(plain);
    expect(await ask({ adapter: "none" })).toEqual(plain);
    // An adapter row and a base row released together: each keeps its own scope.
    const [together, beside] = await Promise.all([ask({ adapter: ADAPTER_ID }), ask({})]);
    expect(together).toEqual(adapted);
    expect(beside).toEqual(plain);

    const removed = await fetch(new URL(`/v1/adapters/${ADAPTER_ID}`, base), { method: "DELETE" });
    expect(await removed.json()).toEqual({ id: ADAPTER_ID, removed_layers: modules });
    expect(await ask({})).toEqual(plain);
    const unknown = await fetch(new URL("/v1/chat/completions", base), { method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: [{ role: "user", content: "Hi" }], max_tokens: 4, adapter: ADAPTER_ID }) });
    expect(unknown.status).toBeGreaterThanOrEqual(400);
    await unknown.body?.cancel();
    await app!.close(); app = undefined;

    // --adapter mounts at startup under the directory's basename and becomes the default.
    base = await start({ adapter: adapter });
    const listed = await (await fetch(new URL("/v1/adapters", base))).json();
    expect(listed.adapters).toEqual([expect.objectContaining({ id: ADAPTER_ID, mounted_layers: modules })]);
    expect(await ask({})).toEqual(adapted);
    expect(await ask({ adapter: "none" })).toEqual(plain);
  } finally {
    try { await app?.close(); } finally { rmSync(root, { recursive: true, force: true }); }
  }
}, 1_800_000);
