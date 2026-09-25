import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { readFileSync, existsSync, mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");
function cache() {
  const home = mkdtempSync(join(tmpdir(), "mlx-cli-")), hub = join(home, "hub");
  const repo = join(hub, "models--example--tiny-qwen3-4bit");
  for (const revision of ["old", "current"]) {
    const snapshot = join(repo, "snapshots", revision);
    mkdirSync(snapshot, { recursive: true });
    writeFileSync(join(snapshot, "config.json"), JSON.stringify({
      model_type: "qwen3", hidden_size: 64, num_hidden_layers: 1, num_attention_heads: 2,
      num_key_value_heads: 1, head_dim: 32, intermediate_size: 64, vocab_size: 64,
      rms_norm_eps: 1e-6, max_position_embeddings: 128, tie_word_embeddings: true,
      quantization: { group_size: 64, bits: 4 },
    }));
    mkdirSync(join(repo, "blobs"), { recursive: true });
    writeFileSync(join(repo, "blobs", revision), new Uint8Array(4096));
    symlinkSync(`../../blobs/${revision}`, join(snapshot, "model.safetensors"));
    writeFileSync(join(snapshot, "model.safetensors.index.json"), JSON.stringify({ metadata: { total_parameters: 4096 }, weight_map: {} }));
  }
  mkdirSync(join(repo, "refs")); writeFileSync(join(repo, "refs/main"), "current");
  return { home, hub, repo };
}
async function cli(home: string, hub: string, ...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", ...(existsSync(join(home, "fetch.ts")) ? ["--preload", join(home, "fetch.ts")] : []), entry, ...args], {
    env: { ...process.env, HOME: home, HF_HUB_CACHE: hub, NO_COLOR: "1", MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" },
    stdout: "pipe", stderr: "pipe",
  });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

test("scan, canonical listing, filters, and fit work with native MLX blocked", async () => {
  const { home, hub } = cache();
  try {
    expect(await cli(home, hub, "scan")).toMatchObject({ code: 0, err: "" });
    const listed = await cli(home, hub, "ls");
    expect(listed.code).toBe(0); expect(listed.out).toContain("1 model(s)");
    expect(listed.out).toContain("example/tiny-qwen3-4bit");
    const all = await cli(home, hub, "ls", "--all-revisions", "tiny");
    expect(all.code).toBe(0); expect(all.out).toContain("2 snapshot(s)"); expect(all.out).toContain("current *");
    expect((await cli(home, hub, "ls", "--vision", "tiny")).out).toContain("no models match");
    expect((await cli(home, hub, "ls", "tiny", "--max-size", "0MB")).out).toContain("no models match");
    const fitted = await cli(home, hub, "fit", "tiny", "--ctx", "128", "--kv-quant", "4", "--skus");
    expect(fitted.code).toBe(0); expect(fitted.err).toBe(""); expect(fitted.out).toContain("FITS");
    expect(fitted.out).toContain("kv-quant 4-bit"); expect(fitted.out).toContain("APPLE SILICON MATRIX");
    expect((await cli(home, hub, "fit", "tiny", "--kv-quant", "config")).code).toBe(1);
  } finally { rmSync(home, { recursive: true, force: true }); }
});

test("gc previews by default, dry-run beats yes, and confirmed deletion updates the registry", async () => {
  const { home, hub, repo } = cache();
  try {
    await cli(home, hub, "scan");
    const old = join(repo, "snapshots/old");
    expect((await cli(home, hub, "gc")).out).toContain("nothing deleted"); expect(existsSync(old)).toBe(true);
    expect((await cli(home, hub, "gc", "--yes", "--dry-run")).out).toContain("nothing deleted"); expect(existsSync(old)).toBe(true);
    expect((await cli(home, hub, "gc", "--yes")).out).toContain("deleted 1 snapshot(s)");
    expect(existsSync(old)).toBe(false); expect(existsSync(join(repo, "snapshots/current"))).toBe(true);
    expect((await cli(home, hub, "ls", "--all-revisions")).out).toContain("1 snapshot(s)");
  } finally { rmSync(home, { recursive: true, force: true }); }
});

test("help and invalid input do not open a registry or fetch a model", async () => {
  const home = mkdtempSync(join(tmpdir(), "mlx-cli-empty-")), hub = join(home, "absent");
  try {
    for (const command of ["get", "scan", "ls", "gc", "fit", "serve"]) {
      expect((await cli(home, hub, command, "--help")).out).toContain(`Usage: mlx-bun ${command}`);
    }
    for (const args of [["get"], ["get", "org/repo", "--unknown"], ["fit"], ["fit", "x", "--ctx", "-1"], ["ls", "--max-size"], ["unknown"], ["serve", "--batch", "0"], ["serve", "--serial"], ["serve", "--compiled-decode", "on"]]) {
      expect((await cli(home, hub, ...args)).code).toBe(1);
    }
    expect((await cli(home, hub, "--version")).out).toBe("mlx-bun 0.0.0\n");
    expect(existsSync(join(home, ".cache/mlx-bun/registry.sqlite"))).toBe(false);
  } finally { rmSync(home, { recursive: true, force: true }); }
});

test("get forwards revisions, verifies bytes, updates the registry, and resolves cached substrings without live network", async () => {
  const home = mkdtempSync(join(tmpdir(), "mlx-cli-get-")), hub = join(home, "hub");
  const files = {
    "config.json": Buffer.from(JSON.stringify({ model_type: "qwen3", hidden_size: 64, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 1, head_dim: 32, intermediate_size: 64, vocab_size: 64 })),
    "model.safetensors": Buffer.alloc(4096),
  };
  const siblings = Object.entries(files).map(([rfilename, data]) => ({ rfilename, size: data.length,
    blobId: createHash("sha1").update(`blob ${data.length}\0`).update(data).digest("hex") }));
  const log = join(home, "requests.jsonl");
  writeFileSync(join(home, "fetch.ts"), `
import { appendFileSync } from "node:fs";
const files = ${JSON.stringify(Object.fromEntries(Object.entries(files).map(([name, bytes]) => [name, bytes.toString("base64")]))) };
globalThis.fetch = async input => {
  const url = String(input);
  appendFileSync(${JSON.stringify(log)}, url + "\\n");
  if (url.includes("/api/models/example/tiny/revision/")) return Response.json(${JSON.stringify({ sha: "current", siblings })});
  const name = url.split("/resolve/current/")[1];
  if (name && files[name]) return new Response(Buffer.from(files[name], "base64"));
  throw new Error("Unexpected network request: " + url);
};`);
  try {
    const fetched = await cli(home, hub, "get", "example/tiny", "--revision", "test-revision");
    expect(fetched.code).toBe(0); expect(fetched.err).toBe(""); expect(fetched.out).toContain("downloaded · verified");
    expect(readFileSync(log, "utf8")).toContain("/revision/test-revision");
    expect((await cli(home, hub, "ls", "tiny")).out).toContain("example/tiny");
    const refreshed = await cli(home, hub, "get", "tiny");
    expect(refreshed.code).toBe(0); expect(readFileSync(log, "utf8")).toContain("/revision/main");
    writeFileSync(join(home, "fetch.ts"), 'globalThis.fetch = async () => { throw new Error("offline test"); };');
    const failed = await cli(home, hub, "get", "example/tiny");
    expect(failed.code).toBe(1); expect(failed.err).toContain("offline test"); expect(failed.out).toContain("download failed");
  } finally { rmSync(home, { recursive: true, force: true }); }
});
