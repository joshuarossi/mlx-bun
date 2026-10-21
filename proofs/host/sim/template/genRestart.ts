// Write the restart modules (Restart, Heap, Shift, NShift, Facts, Case) of a loop case from the ORDINARY ones.
// usage: bun proofs/host/sim/template/genRestart.ts <case-dir> <Name> <T1> <dJ> <dH> <dN> <grow>
//   e.g. growth GROWTH 153 151053 3738 2445 true
//   T1: the last boundary; dJ/dH/dN: heap, native handle and node counter deltas; grow: capacity growth.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const [dir, name, last, dJ, dH, dN, grow] = process.argv.slice(2);
if (!dir || !name || !last || !dJ || !dH || !dN || !grow) {
  throw new Error("usage: genRestart.ts <case-dir> <Name> <T1> <dJ> <dH> <dN> <grow>");
}
const here = import.meta.dir;
for (const file of ["Restart", "Heap", "Shift", "NShift", "Facts", "Case"]) {
  const src = readFileSync(join(here, "ordinary", `${file}.lean`), "utf8");
  let out = src
    .replaceAll("ORDINARY 150", `${name} ${last}`)
    .replaceAll("ORDINARY", name)
    .replaceAll("ordinary", dir)
    .replaceAll("s150", `s${last}`)
    .replaceAll("S150", `S${last}`);
  if (file === "Case") out = out.replace("grow := false", `grow := ${grow}`);
  if (file === "Facts") {
    out = out
      .replace(`- Base.s0.next = 147917`, `- Base.s0.next = ${dJ}`)
      .replace(`- Base.s0.ffi.mlx.next = 3642`, `- Base.s0.ffi.mlx.next = ${dH}`)
      .replace(`- Base.s0.ffi.mlx.nnext = 2381`, `- Base.s0.ffi.mlx.nnext = ${dN}`)
      .replaceAll("loopTheta false", `loopTheta ${grow}`);
  }
  writeFileSync(join(here, dir, `${file}.lean`), out);
}
console.log(`${name}: Restart, Heap, Shift, NShift, Facts, Case written (T1 = ${name}.s${last})`);
