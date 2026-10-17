/** Chunk files for a `host_chain` run.
 * bun proofs/host/ts/chain.ts <dir>
 * <dir>/States.lean holds one `host_chain` (or `host_chain_sym`) `P : …, [k₁, …, k_N]` in a namespace; this
 * writes <dir>/Boot.lean (`host_chain_boot P`), <dir>/C<i>.lean (`host_chunk P i`, one kernel check each) and <dir>/Run.lean
 * (`host_chain_run P`, `host_chain_result P`: the composed run), and prints the files for proofFiles. */
import { readdir, unlink } from "node:fs/promises";
import { join, relative, resolve } from "node:path";

const dir = resolve(process.argv[2] ?? "");
const proofs = resolve(import.meta.dir, "../..");
const states = await Bun.file(join(dir, "States.lean")).text();
const ns = states.match(/^namespace (\S+)/m)?.[1];
const chain = states.match(/^host_chain(?:_sym)? (\S+) : .*\[([\d,\s]+)\]\s*$/m);
if (!ns || !chain) throw new Error("States.lean needs a namespace and a host_chain line ending in a list literal");
const [, pre, list] = chain;
const ks = list!.split(",").map(s => Number(s.trim()));
const mod = (file: string) => relative(proofs, join(dir, file)).replace(/\.lean$/, "").replaceAll("/", ".");

for (const f of await readdir(dir)) if (/^C\d+\.lean$/.test(f)) await unlink(join(dir, f));
const files: string[] = [];
for (let i = 0; i < ks.length; i++) {
  const f = `C${i}.lean`;
  await Bun.write(join(dir, f), `import ${mod("States.lean")}\nnamespace ${ns}\nset_option maxRecDepth 1000000 in\nhost_chunk ${pre} ${i}\nend ${ns}\n`);
  files.push(f);
}
await Bun.write(join(dir, "Boot.lean"), `import ${mod("States.lean")}\nnamespace ${ns}\nset_option maxRecDepth 1000000 in\nhost_chain_boot ${pre}\nend ${ns}\n`);
await Bun.write(join(dir, "Run.lean"), [`import ${mod("Boot.lean")}`, ...files.map(f => `import ${mod(f)}`)].join("\n") +
  `\nnamespace ${ns}\nhost_chain_run ${pre}\nset_option maxRecDepth 1000000 in\nhost_chain_result ${pre}\nend ${ns}\n`);
for (const f of ["States.lean", "Boot.lean", ...files, "Run.lean"]) console.log(`  "${relative(proofs, join(dir, f))}",`);
