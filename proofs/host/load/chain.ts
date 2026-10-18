/** Chunk files of the load run (`host/load/run`).
 *   bun proofs/host/load/chain.ts <total steps> <steps per chunk> <chunks per segment> [first segment] [last segment]
 * Segment `j` (`run/S<j>/`) starts `j · chunks · steps` steps after boot: `States.lean`
 * (`run_segment`, native boot and skip, then its states), `C<i>.lean` (`host_chunk`, one kernel
 * check each), `Run.lean` (`host_chain_run`); `run/Join<j>.lean` joins segment `j` to `j + 1`
 * (`seg_join`) and `run/Boot.lean` joins the link chain to segment 0. The last segment gets one
 * more chunk of the remainder, so the run halts within it. Prints the files for proofFiles.
 * States files are elaborated with the interpreter compiled as a plugin (`--load-dynlib`). */
import { mkdir } from "node:fs/promises";
import { join, relative, resolve } from "node:path";

const [total, steps, per, first, last] = process.argv.slice(2).map(Number) as [number, number, number, number?, number?];
if (!total || !steps || !per) throw new Error("usage: chain.ts <total> <steps> <chunks per segment> [first] [last]");
const proofs = resolve(import.meta.dir, "../..");
const runDir = join(proofs, "host/load/run");
const segLen = steps * per;
const nSeg = Math.ceil(total / segLen);
const files: string[] = [];
const mod = (p: string) => relative(proofs, p).replace(/\.lean$/, "").replaceAll("/", ".");
const write = async (p: string, text: string) => { await mkdir(join(p, ".."), { recursive: true }); await Bun.write(p, text); files.push(relative(proofs, p)); };

for (let j = first ?? 0; j <= Math.min(last ?? nSeg - 1, nSeg - 1); j++) {
  const dir = join(runDir, `S${j}`);
  const skip = j * segLen;
  const remaining = total - skip;
  const ks = Array.from({ length: Math.min(per, Math.ceil(remaining / steps)) }, () => steps);
  if (j === nSeg - 1) ks.push(steps);
  const ns = `Host.Load.Run.S${j}`;
  await write(join(dir, "States.lean"), `import host.load.Route
import host.load.Segment
import host.load.Expr
namespace ${ns}
open Host.Ts Host.Load

/-! Segment ${j} of the load run: ${ks.length} chunks of ${steps} steps from step ${skip}. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
run_segment P : Host.Load.ffi, bootL Route.cx Route.world 2000, ⟨[], []⟩, ${skip}, [${ks.join(", ")}]

end ${ns}
`);
  for (let i = 0; i < ks.length; i++)
    await write(join(dir, `C${i}.lean`), `import ${mod(join(dir, "States.lean"))}\nnamespace ${ns}\nset_option maxRecDepth 1000000 in\nhost_chunk P ${i}\nend ${ns}\n`);
  await write(join(dir, "Run.lean"), [...Array.from({ length: ks.length }, (_, i) => `import ${mod(join(dir, `C${i}.lean`))}`)].join("\n") +
    `\nnamespace ${ns}\nhost_chain_run P\nend ${ns}\n`);
  if (j + 1 < nSeg)
    await write(join(runDir, `Join${j}.lean`), `import ${mod(join(dir, "States.lean"))}\nimport host.load.run.S${j + 1}.States\nnamespace Host.Load.Run\nset_option maxRecDepth 1000000 in\nseg_join S${j}.P S${j + 1}.P\nend Host.Load.Run\n`);
}
if ((first ?? 0) === 0)
  await write(join(runDir, "Boot.lean"), `import host.load.link.States
import host.load.run.S0.States
namespace Host.Load.Run
open Host.Ts

-- The linked machine is segment 0's first state.
set_option maxRecDepth 1000000 in
kernel_rfl boot_join : Host.Load.Link.L.x42.st = S0.P.s0

end Host.Load.Run
`);
// run/Result.lean: the whole load run from the link chain's boot (checks once every segment is checked).
if ((first ?? 0) === 0 && (last ?? nSeg - 1) >= nSeg - 1) {
  const segKs = Array.from({ length: nSeg }, (_, j) => {
    const n = Math.min(per, Math.ceil((total - j * segLen) / steps)) + (j === nSeg - 1 ? 1 : 0);
    return n;
  });
  const out = [`import host.load.link.Run`, `import host.load.run.Boot`,
    ...segKs.map((_, j) => `import host.load.run.S${j}.Run`), ...segKs.slice(0, -1).map((_, j) => `import host.load.run.Join${j}`),
    `namespace Host.Load.Run`, `open Host.Ts Host.Load`, ``,
    `/-! The load run, composed: the link chain boots the machine (\`L.booted\`), segment 0 starts`,
    `there (\`boot_join\`), and each segment continues the previous one (\`P.join\`). -/`, ``];
  let K = 0;
  segKs.forEach((n, j) => {
    const prevK = K; K += n * steps;
    if (j === 0) out.push(`theorem upTo0 : runS Host.Load.ffi ${K} S0.P.s0 S0.P.S0 = some (S0.P.s${n}, S0.P.S${n}) := S0.P.run`);
    else out.push(`theorem upTo${j} : runS Host.Load.ffi ${K} S0.P.s0 S0.P.S0 = some (S${j}.P.s${n}, S${j}.P.S${n}) :=`,
      `  runS_trans (m := ${prevK}) (n := ${n * steps}) Host.Load.ffi upTo${j - 1} (by rw [S${j - 1}.P.join, S${j - 1}.P.joinS]; exact S${j}.P.run)`);
  });
  const last = nSeg - 1, nl = segKs[last]!;
  out.push(``, `/-- From the link chain's boot, ${K} steps of the load run reach the last segment's final state. -/`,
    `theorem load : (bootL Route.cx Route.world 2000).bind (fun s => runS Host.Load.ffi ${K} s ⟨[], []⟩) =`,
    `    some (S${last}.P.s${nl}, S${last}.P.S${nl}) := by`,
    `  rw [Host.Load.Link.L.booted 2000 (by decide), Option.bind_some, boot_join]`,
    `  exact upTo${last}`, ``, `end Host.Load.Run`, ``);
  await write(join(runDir, "Result.lean"), out.join("\n"));
}
for (const f of files) console.log(`  "${f}",`);
