// Emit the server at a chain boundary with canonical results replaced by their defining terms.
// usage: HOST_STREAM_DIR=... bun genBoundary.ts <chain-dir> <Name>
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const [dir, name] = process.argv.slice(2);
if (!dir || !name) throw Error("usage: genBoundary.ts <chain-dir> <Name>");
const streams = process.env.HOST_STREAM_DIR ?? join(import.meta.dir, "../../../.host-stream");
const chain = JSON.parse(readFileSync(join(streams, `Host.Load.Run.Tpl.${name}/chain.json`), "utf8"));
const { ws, rs, endTab } = chain.dtheta as { ws: number[]; rs: string[]; endTab: string[] };
if (ws.length !== rs.length) throw Error("inconsistent canonical result substitution");
const mod = `host.sim.template.${dir.replaceAll("/", ".")}`;
const data = `import ${mod}.H${Math.floor(chain.T1 / 32)}
import host.sim.conv.Compact
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

noncomputable def ${name}.dws : List Nat := [${ws.join(", ")}]
noncomputable def ${name}.drs : List SymE := [${rs.join(", ")}]
noncomputable def ${name}.dtheta : Nat → SymE := Conv.compactθ ${name}.dws ${name}.drs
noncomputable def ${name}.endSrv : SSrv :=
  ⟨[${endTab.join(", ")}], []⟩

end Host.Load.Run.Tpl
`;
const count = Math.ceil(endTab.length / 256);
const chunked = endTab.length > 256;
const xs = `${name}.S${chain.T1}.tab`, ys = `${name}.endSrv.tab`, f = `(·.subst ${name}.dtheta)`;
const header = (imports: string[]) => imports.map(i => `import ${i}\n`).join("") +
  `set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Template\n`;
if (chunked) {
  writeFileSync(join(import.meta.dir, dir, "BoundaryData.lean"), data);
  for (let j = 0; j < count; j++) writeFileSync(join(import.meta.dir, dir, `BoundaryTab${j}.lean`),
    header([`${mod}.BoundaryData`, "host.sim.template.BoundaryCheck"]) +
    `kernel_rfl ${name}.endTab${j} : ((${xs}.drop ${j * 256}).take 256).map ${f} = (${ys}.drop ${j * 256}).take 256\nend Host.Load.Run.Tpl\n`);
}
let proof = `boundary_map_nil (f := ${f}) ${name}.endTabNilS ${name}.endTabNilT`;
for (let j = count - 1; j >= 0; j--) proof = `boundary_map_drop (xs := ${xs}) (ys := ${ys}) (f := ${f}) 256 ${j * 256} ${name}.endTab${j} (${proof})`;
const checks = chunked ?
  `kernel_rfl ${name}.endTabNilS : ${xs}.drop ${count * 256} = []\n` +
  `kernel_rfl ${name}.endTabNilT : ${ys}.drop ${count * 256} = []\n` +
  `theorem ${name}.endTab : ${xs}.map ${f} = ${ys} := ${proof}\n` :
  `kernel_rfl ${name}.endTab : ${xs}.map ${f} = ${ys}\n`;
const out = (chunked ? header(Array.from({length: count}, (_, j) => `${mod}.BoundaryTab${j}`)) :
  data.slice(0, data.lastIndexOf("end Host.Load.Run.Tpl"))) + checks + `
theorem ${name}.endSrv_length : ${name}.endSrv.tab.length = ${name}.S${chain.T1}.tab.length := by
  rw [← ${name}.endTab, List.length_map]

end Host.Load.Run.Tpl
`;
writeFileSync(join(import.meta.dir, dir, "Boundary.lean"), out);
console.log(`${name}: Boundary.lean at s${chain.T1}/S${chain.T1}, ${ws.length} canonical results substituted`);
