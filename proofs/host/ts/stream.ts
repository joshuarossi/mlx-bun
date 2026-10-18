/** Chunk files for a `host_stream` run.
 * bun proofs/host/ts/stream.ts <dir>
 * <dir>/States.lean holds one `host_stream P : F, boot, tab, ρ, k, N` (or `…, k, N, j`: from step j; then
 * optionally `abs i, j, "name"`: `host_chunk_abs` for chunks i … j-1) in a namespace; this writes
 * <dir>/G<i>.lean (`host_stream_state P i`, importing G<i-1>; i in [0, N]), <dir>/C<i>.lean
 * (`host_chunk P i`, importing G<i+1>; one kernel check each, independent of each other), Run.lean
 * (`host_chain_run P`) and, for a run from boot, Boot.lean and `host_chain_result P` (the run halts), and
 * prints the files for proofFiles. */
import { readdir, unlink } from "node:fs/promises";
import { join, relative, resolve } from "node:path";

const dir = resolve(process.argv[2] ?? "");
const proofs = resolve(import.meta.dir, "../..");
const states = await Bun.file(join(dir, "States.lean")).text();
const ns = states.match(/^namespace (\S+)/m)?.[1];
const line = states.match(/^host_stream (\S+) : (.*?)((?:, \d+){2,3})(?: abs (\d+), (\d+), "[^"]+")?\s*$/m);
if (!ns || !line) throw new Error("States.lean needs a namespace and a host_stream line ending in `k, N` (or `k, N, j`) literals");
const pre = line[1]!;
const nums = line[3]!.split(",").slice(1).map(Number);
const N = nums[1]!;
const fromBoot = nums.length === 2;
const abstracted = (i: number) => line[4] !== undefined && i >= Number(line[4]) && i < Number(line[5]);
const mod = (file: string) => relative(proofs, join(dir, file)).replace(/\.lean$/, "").replaceAll("/", ".");
const header = (imports: string[]) => imports.map(i => `import ${i}`).join("\n") + `\nnamespace ${ns}\nset_option maxRecDepth 1000000 in\n`;

for (const f of await readdir(dir)) if (/^[CG]\d+\.lean$/.test(f)) await unlink(join(dir, f));
const files: string[] = [];
for (let i = 0; i <= N; i++) {
  await Bun.write(join(dir, `G${i}.lean`), header([mod(i ? `G${i - 1}.lean` : "States.lean")]) + `host_stream_state ${pre} ${i}\nend ${ns}\n`);
  files.push(`G${i}.lean`);
}
for (let i = 0; i < N; i++) {
  await Bun.write(join(dir, `C${i}.lean`), header([mod(`G${i + 1}.lean`)]) + `host_chunk${abstracted(i) ? "_abs" : ""} ${pre} ${i}\nend ${ns}\n`);
  files.push(`C${i}.lean`);
}
if (fromBoot) await Bun.write(join(dir, "Boot.lean"), header([mod("G0.lean")]) + `host_chain_boot ${pre}\nend ${ns}\n`);
await Bun.write(join(dir, "Run.lean"), [...(fromBoot ? [`import ${mod("Boot.lean")}`] : []), `import ${mod(`G${N}.lean`)}`,
  ...Array.from({ length: N }, (_, i) => `import ${mod(`C${i}.lean`)}`)].join("\n") +
  `\nnamespace ${ns}\nhost_chain_run ${pre}\n` + (fromBoot ? `set_option maxRecDepth 1000000 in\nhost_chain_result ${pre}\n` : "") + `end ${ns}\n`);
for (const f of ["States.lean", ...(fromBoot ? ["Boot.lean"] : []), ...files, "Run.lean"]) console.log(`  "${relative(proofs, join(dir, f))}",`);
