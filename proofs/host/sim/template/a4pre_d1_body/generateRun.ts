import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
type Segment = { from: number; to: number; fuel: number; next?: number };
const d = JSON.parse(readFileSync(join(import.meta.dir, "sized-pieces.json"), "utf8")) as {
  steps: number; last: number; segments: Segment[];
};
if (d.steps !== 1541184 || d.last !== 635 || d.segments.length !== 183) throw new Error("wrong body partition");
const mod = (s: string) => `host.sim.template.a4pre_d1_body.${s}`;
const head = (files: string[]) => files.map(s => `import ${mod(s)}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\n" +
  "namespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill\n";
const pars = "{NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}";
const cut = (i: number) => `(D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s${i} D1BodySized.S${i})`;
const chain = (names: string[]) => names.slice(1).reduce((p, n) => `(${p}).trans ${n}`, names[0]!);
const groups: { from: number; to: number; fuel: number; file: string }[] = [];
for (let from = 0; from < d.segments.length; from += 16) {
  const to = Math.min(from + 16, d.segments.length), n = groups.length;
  const ss = d.segments.slice(from, to), end = ss.at(-1)!;
  const group = { from: ss[0]!.from, to: end.next ?? end.to,
    fuel: ss.reduce((n, s) => n + s.fuel + (s.next === undefined ? 0 : 4), 0), file: `SR${n}` };
  const names = Array.from({ length: to - from }, (_, j) => `SP${from + j}`);
  const text = head(names) + `\ntheorem D1BodySized.group${n} ${pars} :\n` +
    `    CutStep ${cut(group.from)} ${cut(group.to)} ${group.fuel} :=\n` +
    `  ${chain(names.map((_, j) => `D1BodySized.piece${from + j}`))}\n\nend Host.Load.Run.Tpl\n`;
  writeFileSync(join(import.meta.dir, group.file + ".lean"), text); groups.push(group);
}
if (groups.reduce((n, g) => n + g.fuel, 0) !== d.steps || groups.at(-1)!.to !== d.last) throw new Error("incomplete run");
writeFileSync(join(import.meta.dir, "SizedRun.lean"), head(groups.map(g => g.file)) +
  `\ntheorem D1BodySized.fullRun ${pars} :\n    CutStep ${cut(0)} ${cut(d.last)} ${d.steps} :=\n` +
  `  ${chain(groups.map((_, i) => `D1BodySized.group${i}`))}\n\nend Host.Load.Run.Tpl\n`);
console.log({ groups: groups.length, fuel: d.steps });
