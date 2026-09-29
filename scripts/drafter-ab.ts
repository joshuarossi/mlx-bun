// The drafter acceptance A/B: THE gate for a drafter experiment, a quantized
// drafter above all. Two servers, one per drafter, mount the same target; the
// same prompt set runs against each at temperature 0; acceptance and wall clock
// are compared prompt by prompt (drafter numerics move acceptance, never
// correctness: the target verifies every draft).
//
//   bun scripts/drafter-ab.ts --command '["bun","/abs/tree/apps/mlx-bun/src/cli/main.ts","serve"]' \
//     --target /abs/target-snapshot --drafter-a /abs/drafter --drafter-b /abs/drafter-affine-q4-g64 \
//     --out /abs/empty-dir [--library /abs/libmlxc.dylib] [--num-draft-tokens N] [--max-tokens 64]
//     [--n-prompts 32] [--prompts /abs/prompts.txt] [--max-drop 3] [--serve-args '["--kv-quant","4"]']
//
// Each arm runs sequentially (one drafter resident at a time) against a server
// the runner starts from --command and stops. Results live only in --out, which
// must be outside the source tree. Exit 0 when B holds A's acceptance within
// --max-drop points AND is faster; 1 otherwise. The paired verdict survives
// machine load; a quotable pair still belongs on a quiet machine.
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { isAbsolute, resolve } from "node:path";
import { parseArgs } from "node:util";
import { cellEnvironment, freePort, machine } from "./bench-serve";
import { ServerProcess, stopAll, waitReady } from "./bench/measure";
import { checkOutputDirectory, fileSha } from "./bench/plan";
import { DEFAULT_PROMPTS, runArm } from "./drafter-ab/arm";
import { pairedVerdict, renderReport, type AbPromptResult } from "./drafter-ab/stats";

const TOOL_ROOT = resolve(import.meta.dir, "..");

export interface ServerArgs {
  command: readonly string[]; target: string; drafter: string; port: number; numDraftTokens?: number; serveArgs: readonly string[];
}
/** The server one arm runs: the explicit serve command over the target with the drafter mounted. */
export function serverArgv(a: ServerArgs): string[] {
  return [...a.command, a.target, "--draft-model", a.drafter, "--host", "127.0.0.1", "--port", String(a.port), "--thinking", "off",
    ...(a.numDraftTokens ? ["--num-draft-tokens", String(a.numDraftTokens)] : []), ...a.serveArgs];
}

function jsonList(name: string, raw: string): string[] {
  let value: unknown;
  try { value = JSON.parse(raw); } catch { throw new Error(`--${name} must be a JSON array of strings`); }
  if (!Array.isArray(value) || !value.every(v => typeof v === "string")) throw new Error(`--${name} must be a JSON array of strings`);
  return value as string[];
}

async function main(argv: string[]): Promise<number> {
  const { values } = parseArgs({ args: argv, strict: true, options: {
    command: { type: "string" }, target: { type: "string" }, "drafter-a": { type: "string" }, "drafter-b": { type: "string" }, out: { type: "string" },
    library: { type: "string" }, "num-draft-tokens": { type: "string" }, "max-tokens": { type: "string", default: "64" },
    "n-prompts": { type: "string", default: "32" }, prompts: { type: "string" }, "max-drop": { type: "string", default: "3" },
    "serve-args": { type: "string", default: "[]" }, "ready-timeout": { type: "string", default: "300" },
  } });
  for (const name of ["command", "target", "drafter-a", "drafter-b", "out"] as const)
    if (!values[name]) throw new Error(`--${name} is required (see the header of scripts/drafter-ab.ts)`);
  const command = jsonList("command", values.command!), serveArgs = jsonList("serve-args", values["serve-args"]!);
  const paths = { target: values.target!, a: values["drafter-a"]!, b: values["drafter-b"]!, ...(values.library ? { library: values.library } : {}) };
  for (const [name, path] of Object.entries(paths)) if (!isAbsolute(path) || !existsSync(path)) throw new Error(`--${name === "a" ? "drafter-a" : name === "b" ? "drafter-b" : name} must be an existing absolute path (got ${path})`);
  const number = (name: string, min: number) => {
    const value = Number(values[name as keyof typeof values]);
    if (!Number.isFinite(value) || value < min) throw new Error(`--${name} must be a number >= ${min}`);
    return value;
  };
  const maxTokens = number("max-tokens", 1), count = number("n-prompts", 1), maxDrop = number("max-drop", 0), ready = number("ready-timeout", 1);
  const numDraftTokens = values["num-draft-tokens"] ? number("num-draft-tokens", 1) : undefined;
  const all = values.prompts ? readFileSync(values.prompts, "utf8").split("\n").map(l => l.trim()).filter(Boolean) : [...DEFAULT_PROMPTS];
  if (all.length < count) console.warn(`only ${all.length} prompts available (asked for ${count})`);
  const prompts = all.slice(0, count);
  const out = checkOutputDirectory(values.out!, [TOOL_ROOT]);
  mkdirSync(out, { recursive: true });

  const arm = async (label: "A" | "B", drafter: string): Promise<AbPromptResult[]> => {
    const port = await freePort(), sandbox = mkdtempSync(`${out}/${label}-`), log = `${out}/${label}.stderr.log`, tail: string[] = [];
    const argv = serverArgv({ command, target: paths.target, drafter, port, numDraftTokens, serveArgs });
    console.log(`\n[arm ${label}] ${drafter}\n  ${argv.join(" ")}`);
    const server = new ServerProcess(argv, cellEnvironment(sandbox, values.library ?? null), tail, log, sandbox);
    const base = `http://127.0.0.1:${port}`;
    try {
      await waitReady(base, undefined, ready * 1000, () => { if (!server.running) throw new Error(`server exited before it was ready:\n${tail.slice(-20).join("\n")}`); });
      return await runArm({ base, model: paths.target, prompts, maxTokens, onPrompt: (i, r) =>
        console.log(`  [${i + 1}/${prompts.length}] ${r.generatedTokens} tok acceptance ${r.drafted ? ((r.accepted / r.drafted) * 100).toFixed(0) : "-"}% ${(r.wallMs / 1000).toFixed(1)}s`) });
    } finally { await server.stop(); }
  };

  try {
    const a = await arm("A", paths.a), b = await arm("B", paths.b);
    const verdict = pairedVerdict(a, b, { maxDropPts: maxDrop });
    const report = renderReport(paths.a, paths.b, verdict);
    console.log(`\n=== drafter A/B (${prompts.length} prompts, temp 0, max ${maxTokens} tokens) ===\n${report}`);
    writeFileSync(`${out}/result.json`, JSON.stringify({
      schema: 1, machine: machine(), startedAt: new Date().toISOString(), command, serveArgs, target: paths.target, numDraftTokens: numDraftTokens ?? null,
      drafterA: { path: paths.a, files: shaOf(paths.a) }, drafterB: { path: paths.b, files: shaOf(paths.b) },
      maxTokens, maxDropPts: maxDrop, prompts, resultsA: a, resultsB: b, verdict }, null, 1));
    writeFileSync(`${out}/report.txt`, report + "\n");
    console.log(`results: ${out}`);
    return verdict.pass ? 0 : 1;
  } finally { await stopAll(); }
}

/** Identity of a drafter directory: the hash of every file that defines it. */
function shaOf(dir: string): Record<string, string> {
  const files: Record<string, string> = {};
  for (const name of readdirSync(dir).sort()) if (/\.(json|safetensors)$/.test(name)) files[name] = fileSha(`${dir}/${name}`);
  return files;
}

if (import.meta.main) main(process.argv.slice(2)).then(code => process.exit(code), error => { console.error(error instanceof Error ? error.message : String(error)); process.exit(2); });
