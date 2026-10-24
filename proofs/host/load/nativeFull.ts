import { mkdir } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { buildProofs } from "../../build.ts";
import { isLoadChooser } from "../../checker.ts";
import type { LoadNativeOptions } from "./native.ts";

/** The second native state chooser: `host/load/NativeFull.lean` (the load chooser's
 * modules and the full stack, `host.load.Layers`) for the template commands of the full
 * world (`tpl_* … (world := full)`). It is separate from `host/load/Native.lean` so that the
 * existing choosers keep their keys and their library: `checker.ts` and `native.ts` are
 * part of every module's key, so this file holds the second library's build, its chooser
 * test and the keys. As for the first, loading it grants no theorem. */
export const fullRoot = "host/load/NativeFull.lean";
export const fullDir = ".native-load-full";
export const fullLibrary = "libloadproof-full.dylib";

/** A module running a template command in a world other than the load world. */
export function isFullChooser(file: string, source: string): boolean {
  return file.startsWith("host/") && /^tpl_\w+\b[^\n]*[\s(,]world\s*:=\s*(?!lf\b)/m.test(source);
}

// checker.ts's hash (not exported there), byte for byte.
const sha256 = (parts: string[]) => {
  const hasher = new Bun.CryptoHasher("sha256");
  for (const part of parts) hasher.update(`${part.length}:${part}`);
  return hasher.digest("hex");
};

/** `checker.ts`'s `moduleKeys`, with full-world choosers keyed by the second library
 * (`NativeFull.lean`'s key and this file's text) instead of the first. A module that is no
 * full-world chooser and imports none gets exactly `moduleKeys`'s key. */
export function moduleKeysFull(sources: ReadonlyMap<string, string>, imports: ReadonlyMap<string, string[]>,
    base: string, builder: string): Map<string, string> {
  const keys = new Map<string, string>();
  const visiting = new Set<string>();
  const key = (file: string): string => {
    const known = keys.get(file);
    if (known) return known;
    if (visiting.has(file)) throw new Error(`Local proof import cycle at ${file}`);
    visiting.add(file);
    const source = sources.get(file)!;
    const native = isFullChooser(file, source) && sources.has(fullRoot) ? [key(fullRoot), builder]
      : isLoadChooser(file, source) && sources.has("host/load/Native.lean") ? [key("host/load/Native.lean")] : [];
    const result = sha256([base, file, source, ...imports.get(file)!.map(key), ...native]);
    visiting.delete(file);
    keys.set(file, result);
    return result;
  };
  for (const file of sources.keys()) key(file);
  return keys;
}

/** `native.ts`'s `buildLoadNative` for the root `NativeFull.lean`. */
export async function buildLoadNativeFull(options: LoadNativeOptions): Promise<string> {
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
  await load(fullRoot);
  if (!sources.has(fullRoot)) throw Error(`The source snapshot lacks ${fullRoot}`);
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
lean_object* initialize_host_load_NativeFull(uint8_t builtin);
LEAN_EXPORT lean_object* initialize_loadproof(uint8_t builtin) {
  return initialize_host_load_NativeFull(builtin);
}
`);
  await run([leanc, "-c", "-O3", "-DLEAN_EXPORTING", "-o", stubObject, stub]);
  const prefix = (await run([lean, "--print-prefix"])).trim();
  const library = join(out, fullLibrary);
  await run([leanc, "-shared", "-Wl,-undefined,dynamic_lookup", "-o", library,
    ...[...sources.keys()].map(f => objects.get(f)!), stubObject, "-lleanshared", "-Wl,-rpath," + join(prefix, "lib/lean")]);
  return library;
}

if (import.meta.main) {
  const [proofRoot, lean, leanPath, outputDir, jobs] = process.argv.slice(2);
  if (!proofRoot || !lean || !leanPath || !outputDir) throw Error("usage: nativeFull.ts <proof-root> <lean> <lean-path> <output-dir> [jobs]");
  console.log(await buildLoadNativeFull({ proofRoot, lean, leanPath, outputDir, jobs: jobs === undefined ? undefined : Number(jobs) }));
}
