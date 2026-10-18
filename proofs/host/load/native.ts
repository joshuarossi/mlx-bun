import { mkdir } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { buildProofs } from "../../build.ts";

export interface LoadNativeOptions {
  /** Immutable source snapshot whose dependency oleans have already passed. */
  proofRoot: string;
  lean: string;
  leanPath: string;
  outputDir: string;
  /** Native compiler processes in flight; defaults to two, at most four. */
  jobs?: number;
}

/** Compile the state chooser from the same snapshot as its checked oleans.
 * The plugin only accelerates elaboration's choice of explicit state definitions.
 * Loading it grants no theorem: boot, chunk, join, and summary equalities still
 * go through the ordinary Lean kernel in the checking processes. */
export async function buildLoadNative(options: LoadNativeOptions): Promise<string> {
  const root = resolve(options.proofRoot);
  const out = resolve(options.outputDir);
  const lean = Bun.which(options.lean) ?? resolve(options.lean);
  const leanc = join(dirname(lean), "leanc");
  const jobs = options.jobs ?? 2;
  if (!Number.isSafeInteger(jobs) || jobs < 1 || jobs > 4) throw Error("Native build jobs must be from 1 to 4");
  const env = { ...process.env, LEAN_PATH: options.leanPath };
  const run = async (args: string[]): Promise<string> => {
    const p = Bun.spawn(args, { cwd: root, env, stdout: "pipe", stderr: "pipe" });
    const [stdout, stderr, code] = await Promise.all([
      new Response(p.stdout).text(), new Response(p.stderr).text(), p.exited,
    ]);
    if (code !== 0) throw Error(`Native state chooser command failed (${args[0]}):\n${stdout}${stderr}`);
    return stdout;
  };
  const sources = new Map<string, string>();
  const load = async (file: string): Promise<void> => {
    if (sources.has(file)) return;
    const path = join(root, file);
    if (!(await Bun.file(path).exists())) return; // Toolchain/dependency import.
    const source = await Bun.file(path).text();
    sources.set(file, source);
    for (const m of source.matchAll(/^import\s+([^\n]+)/gm)) {
      for (const module of m[1]!.split(/\s+/).filter(Boolean)) await load(module.replaceAll(".", "/") + ".lean");
    }
  };
  await load("host/load/Native.lean");
  if (!sources.has("host/load/Native.lean")) throw Error("The source snapshot lacks host/load/Native.lean");
  await mkdir(out, { recursive: true });
  const objects = new Map<string, string>();
  await buildProofs(sources, jobs, async (file) => {
    const c = join(out, file.replace(/\.lean$/, ".c"));
    const o = c.replace(/\.c$/, ".o");
    await mkdir(dirname(c), { recursive: true });
    await run([lean, "-R", root, "-c", c, join(root, file)]);
    await run([leanc, "-c", "-O3", "-DLEAN_EXPORTING", "-o", o, c]);
    objects.set(file, o);
  });
  const stub = join(out, "plugin.c");
  const stubObject = join(out, "plugin.o");
  await Bun.write(stub, `#include <lean/lean.h>
lean_object* initialize_host_load_Native(uint8_t builtin);
LEAN_EXPORT lean_object* initialize_loadproof(uint8_t builtin) {
  return initialize_host_load_Native(builtin);
}
`);
  await run([leanc, "-c", "-O3", "-DLEAN_EXPORTING", "-o", stubObject, stub]);
  const prefix = (await run([lean, "--print-prefix"])).trim();
  const library = join(out, "libloadproof.dylib");
  await run([leanc, "-shared", "-Wl,-undefined,dynamic_lookup", "-o", library,
    ...[...sources.keys()].map(f => objects.get(f)!), stubObject, "-lleanshared", "-Wl,-rpath," + join(prefix, "lib/lean")]);
  return library;
}

if (import.meta.main) {
  const [proofRoot, lean, leanPath, outputDir, jobs] = process.argv.slice(2);
  if (!proofRoot || !lean || !leanPath || !outputDir) throw Error("usage: native.ts <proof-root> <lean> <lean-path> <output-dir> [jobs]");
  console.log(await buildLoadNative({ proofRoot, lean, leanPath, outputDir, jobs: jobs === undefined ? undefined : Number(jobs) }));
}
