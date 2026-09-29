import { expect, test } from "bun:test";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import { SERVER_CONFIG_PAGE, configInventory, configSources, generateServerConfig, renderServerConfig, type ConfigInventory } from "../scripts/generate-server-config";

const root = resolve(import.meta.dir, "../../..");
const sources = await configSources(), baseline = configInventory(sources), revision = "a".repeat(40);
/** The real sources with one exact edit, which must apply. */
function mutate(file: string, from: string, to: string): Map<string, string> {
  const text = sources.get(file)!;
  expect(text).toContain(from);
  return new Map(sources).set(file, text.replace(from, to));
}
/** The 1-based line of the first occurrence of needle in a source file. */
const lineOf = (file: string, needle: string) => sources.get(file)!.split(needle)[0]!.split("\n").length;
const extra = (text: string) => new Map(sources).set("packages/inference/src/extra.ts", text);
/** A key's rendered table rows, links reduced to their text. */
const rows = (inventory: ConfigInventory, key: string) => renderServerConfig(inventory, revision).split("\n")
  .filter(row => row.startsWith(`| \`${key}\``)).map(row => row.replace(/\]\(https:[^)]+\)/g, "]"));

test("serve checks, serve-written keys, and each read site's fallback come from source", () => {
  const serve = new Map(baseline.serve.map(f => [f.flag, f]));
  expect(serve.get("port")).toMatchObject({ fallback: "8080", accepts: "integer in [0, 65535]" });
  expect(serve.get("kv-quant")).toMatchObject({ fallback: "off", accepts: "`off` \\| `config` \\| `4` \\| `8`" });
  expect(serve.get("batch")).toMatchObject({ fallback: "8", accepts: "integer ≥ 1" });
  expect(serve.get("prompt-cache")).toMatchObject({ accepts: "number ≥ 0" });
  expect(serve.get("prompt-cache")!.fallback).toBeUndefined();
  expect(baseline.writes.filter(w => w.flag).map(w => `${w.key} ${w.flag}`))
    .toEqual(["MLX_BUN_NO_FUSED_SDPA fused-sdpa", "MLX_BUN_FORCE_WIRE force-wire", "MLX_BUN_ALLOW_PRIVATE_MEDIA allow-private-media"]);
  // Different contextual fallbacks at different sites are listed, not an error.
  expect(rows(baseline, "MLX_BUN_RD_PREFILL_CHUNK").map(row => row.split(" | ").slice(1, 3).join(" | "))).toEqual(["value | computed", "number | `2048`", "number | computed"]);
  expect(rows(baseline, "MLX_BUN_FLASH_MIN_M")).toEqual(["| `MLX_BUN_FLASH_MIN_M` | value | `1024` | [loss.ts:" + lineOf("packages/training/src/loss.ts", 'runtimeValue("MLX_BUN_FLASH_MIN_M")') + "] |"]);
  expect(rows(baseline, "MLX_BUN_SESSION_CACHE")[0]).toContain("| value | unset (only `0` changes it) |");
  expect(rows(baseline, "MLX_BUN_LIBMLXC")[0]).toContain("| process.env | computed | [native.ts:");
  expect(rows(baseline, "MLX_BUN_PAGED_KV")[0]).toContain("[cli/serve.ts:");
  // The installed modules' and host libraries' keys are app keys, not library tuning.
  expect(rows(baseline, "MLX_BUN_MIC_CAPTURE")[0]).toContain("[module-transcription/src/mic-capture.ts:");
  expect(rows(baseline, "MLX_BUN_HOME")[0]).toContain("[app-services/src/home.ts:");
  const page = renderServerConfig(baseline, "a".repeat(40)), appKeys = page.slice(page.indexOf("### App keys"), page.indexOf("## Library tuning"));
  expect(appKeys).toContain("`MLX_BUN_MIC_CAPTURE`"); expect(appKeys).toContain("`MLX_BUN_HOME`");
  expect(page.slice(page.indexOf("## Library tuning"))).not.toContain("### @mlx-bun/module-transcription");
  for (const read of baseline.reads) expect(/^(apps\/mlx-bun|packages\/[a-z-]+)\/src\//.test(read.file) && read.line > 0).toBe(true);
});

test("generation writes a build-owned page with source links at the revision", async () => {
  const destination = await mkdtemp(resolve(tmpdir(), "mlx-site-server-config-"));
  try {
    await generateServerConfig({ destination, revision });
    const page = await readFile(resolve(destination, SERVER_CONFIG_PAGE), "utf8");
    expect(page).toBe(renderServerConfig(baseline, revision));
    for (const heading of ["## Serve options", "### Keys set by `serve`", "### App keys", "## Library tuning", "### @mlx-bun/inference", "### @mlx-bun/training", "## Notes"])
      expect(page).toContain(`\n${heading}\n`);
    expect(page).toContain("not app options; none is promoted to a flag");
    expect(page).toContain("[CLI reference](/reference/cli/#serve)");
    expect(page).toMatch(/\| `--port` \| `8080` \| integer in \[0, 65535\] \| \[cli\/serve\.ts:\d+\]\(https:\/\/github\.com\/joshuarossi\/mlx-bun\/blob\/a{40}\/apps\/mlx-bun\/src\/cli\/serve\.ts#L\d+\) \|/);
  } finally { await rm(destination, { recursive: true, force: true }); }
  expect(await readFile(resolve(root, "apps/website/.gitignore"), "utf8")).toContain(SERVER_CONFIG_PAGE);
});

test("each unsupported key form fails with its location; a comment does not", () => {
  const serve = "apps/mlx-bun/src/cli/serve.ts", gateway = "packages/inference/src/execution/gateway-binding.ts";
  expect(() => configInventory(mutate(serve, 'runtimeValue("MLX_BUN_RD_CONTEXT_LIMIT")', "runtimeValue(profileKey)")))
    .toThrow(`${serve}:${lineOf(serve, 'runtimeValue("MLX_BUN_RD_CONTEXT_LIMIT")')}: non-literal runtime key \`runtimeValue(profileKey)\``);
  expect(() => configInventory(mutate(gateway, 'runtime.flag("MLX_BUN_COMPILED_DECODE", true)', "runtime.flag(`MLX_BUN_${name}`, true)")))
    .toThrow(`${gateway}:${lineOf(gateway, 'runtime.flag("MLX_BUN_COMPILED_DECODE", true)')}: non-literal runtime key`);
  for (const [text, message] of [["process.env[name]", "computed environment read"], ["Bun.env[name]", "computed environment read"],
    ["process.env.MLX_BUN_NEW", "direct environment read"], ["Bun.env.MLX_BUN_NEW", "direct environment read"], ['process.env["MLX_BUN_LIBMLXC"]', "direct environment read"]])
    expect(() => configInventory(extra(`export const read = (name: string) =>\n  ${text};\n`))).toThrow(`packages/inference/src/extra.ts:2: ${message} \`${text}\``);
  expect(() => configInventory(mutate(serve, 'const hlg = value("hlg-sampling");', 'const hlg = value(["hlg", "sampling"].join("-"));')))
    .toThrow(`${serve}:${lineOf(serve, 'const hlg = value("hlg-sampling");')}: serve flag name must be a literal`);
  // The AST, not a text search: comments and unrelated strings are not reads.
  const commented = configInventory(extra('// process.env.MLX_BUN_NEW, runtimeValue(name), process.env[name]\nexport const note = "process.env.MLX_BUN_NEW";\n'));
  expect(renderServerConfig(commented, revision)).toBe(renderServerConfig(baseline, revision));
  expect(() => configInventory(mutate("packages/mlx/src/native.ts", "process.env.MLX_BUN_LIBMLXC", "undefined")))
    .toThrow("packages/mlx/src/native.ts: the listed direct read of MLX_BUN_LIBMLXC disappeared");
}, 20_000); // each case rescans every source; concurrent Mac CI needs more than the 5 s default

test("aliased and string-keyed runtime readers are inventoried; destructured environment reads follow the direct-read rule", () => {
  const readsOf = (text: string) => configInventory(extra(text)).reads.filter(r => r.file === "packages/inference/src/extra.ts").map(r => `${r.key} ${r.how} ${r.line}`);
  expect(readsOf('import { runtimeValue as setting } from "./runtime/config";\nexport const a = setting("MLX_BUN_ALIASED");\n')).toEqual(["MLX_BUN_ALIASED value 2"]);
  expect(readsOf('import * as config from "./runtime/config";\nexport const a = config.runtimeFlag("MLX_BUN_NAMESPACED");\n')).toEqual(["MLX_BUN_NAMESPACED flag 2"]);
  expect(readsOf('import { runtimeConfig } from "./runtime/config";\nexport const a = runtimeConfig()["number"]("MLX_BUN_KEYED", 3);\n')).toEqual(["MLX_BUN_KEYED number 2"]);
  expect(readsOf('export const { HOME } = process.env;\n')).toEqual([]);
  for (const [text, message] of [
    ['import { runtimeValue as setting } from "./runtime/config";\nexport const a = setting(name);\n', "non-literal runtime key `setting(name)`"],
    ['import { runtimeConfig } from "./runtime/config";\nexport const a = runtimeConfig()[how]("MLX_BUN_X");\n', 'computed runtime reader `runtimeConfig()[how]("MLX_BUN_X")`'],
    ["export const read = () => 1;\nconst { MLX_BUN_NEW } = process.env;\n", "direct environment read `{ MLX_BUN_NEW } = process.env`"],
    ["export const read = () => 1;\nconst { MLX_BUN_LIBMLXC: lib } = Bun.env;\n", "direct environment read `{ MLX_BUN_LIBMLXC: lib } = Bun.env`"],
    ["export const read = () => 1;\nconst { ...all } = process.env;\n", "computed environment read `{ ...all } = process.env`"],
    ["export const read = () => 1;\nconst { [name]: value } = process.env;\n", "computed environment read `{ [name]: value } = process.env`"],
  ]) expect(() => configInventory(extra(text))).toThrow(`packages/inference/src/extra.ts:2: ${message}`);
}, 20_000); // each case rescans every source; concurrent Mac CI needs more than the 5 s default

test("a note whose key or flag is gone fails", () => {
  expect(() => configInventory(mutate("apps/mlx-bun/src/cli/serve.ts", 'runtimeValue("MLX_BUN_PAGED_KV")', 'runtimeValue("MLX_BUN_PAGING")')))
    .toThrow("A configuration note names MLX_BUN_PAGED_KV, which no source reads");
  expect(() => configInventory(mutate("apps/mlx-bun/src/cli/args.ts", '    "prompt-cache": { type: "string", description: "RAM prompt cache cap, GiB; 0 disables [default: 8 GB]" },\n', "")))
    .toThrow("A configuration note names --prompt-cache, which is not a serve flag");
});

test("a help default that differs from the parser's literal fails", () => {
  const serve = "apps/mlx-bun/src/cli/serve.ts";
  expect(() => configInventory(mutate("apps/mlx-bun/src/cli/args.ts", "0 chooses a free port [default: 8080]", "0 chooses a free port [default: 8081]")))
    .toThrow(`${serve}:${lineOf(serve, 'number("port"')}: --port help says [default: 8081] but the parser defaults to 8080`);
});

test("a key serve writes shows its flag, never its local literal", () => {
  const host = "apps/mlx-bun/src/cli/serve-host.ts", write = '    ...(options.forceWire ? { MLX_BUN_FORCE_WIRE: "1" } : {}),\n';
  expect(rows(baseline, "MLX_BUN_FORCE_WIRE")[0]).toContain("| `--force-wire` |");
  const written = rows(baseline, "MLX_BUN_FORCE_WIRE").slice(1);
  expect(written).toHaveLength(1);
  expect(written[0]).toContain(`| value | set by \`serve\` from \`--force-wire\` ([cli/serve-host.ts:${lineOf(host, "MLX_BUN_FORCE_WIRE")}]) |`);
  expect(written[0]).not.toContain("only `1` changes it");
  expect(rows(baseline, "MLX_BUN_NO_FUSED_SDPA").join("\n")).not.toContain("only `1` changes it");
  // Without the write the read sites' own fallback is the default.
  expect(rows(configInventory(mutate(host, write, "")), "MLX_BUN_FORCE_WIRE")[0]).toContain("| value | unset (only `1` changes it) |");
  expect(() => configInventory(mutate(host, "options.forceWire ?", "options.wireAlways ?")))
    .toThrow(`${host}:${lineOf(host, "MLX_BUN_FORCE_WIRE")}: MLX_BUN_FORCE_WIRE is written from \`options.wireAlways\`, which names no serve flag`);
});

test("removing a read site removes it from the output", () => {
  const removed = configInventory(mutate("apps/mlx-bun/src/server/inference-request.ts", 'runtimeValue("MLX_BUN_LANE_DEBUG") === "1"', "false"));
  expect(rows(baseline, "MLX_BUN_LANE_DEBUG")).toHaveLength(1);
  expect(renderServerConfig(removed, revision)).not.toContain("MLX_BUN_LANE_DEBUG");
  const one = configInventory(mutate("packages/inference/src/generation/speculative/run.ts", 'runtimeConfig().number("MLX_BUN_RD_PREFILL_CHUNK", PREFILL_CHUNK)', "PREFILL_CHUNK"));
  expect(rows(one, "MLX_BUN_RD_PREFILL_CHUNK")).toEqual(rows(baseline, "MLX_BUN_RD_PREFILL_CHUNK").slice(0, 2));
});
