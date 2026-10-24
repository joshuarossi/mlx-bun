/** Class tables and LinGood checks for the prefill classes and the route's positions (gen-plan T6, G10).
 *
 *   bun proofs/host/sim/lin/gen.ts table
 *     reads host/sim/PrefillSched.lean; writes host/sim/lin/classes.json and the Lean modules
 *     host/sim/lin/{Table,CoverA,CoverT1,CoverT2,Cover,CoverR,CoverD}.lean.
 *   bun proofs/host/sim/lin/gen.ts checks <spec.json>
 *     reads classes.json and a piece spec; writes one `goodLin` (or `goodEnum`) check per
 *     (piece, row) into the spec's modules.
 *   bun proofs/host/sim/lin/gen.ts spec <out.json> <chain>=<case-dir>[@<L> | :<rows>] …
 *     reads A4's route chains (`chain.json`, `glue<k>.json`, the instances' `stage.json`); writes their piece spec.
 *   bun proofs/host/sim/lin/gen.ts rows <L>
 *     prints the prefill rows of a prompt of length `L`.
 *
 * Every step of every class (`L ≤ 262143`) is enumerated: a row's box is the range of its
 * parameters' witnesses over the row's steps, a class splits into rows where its stage tags
 * (`nps`, `kv`, `kv2`) differ, and each step is checked to reach its row through the cover
 * proof's decision tree with every form's value. `Cover.lean` proves the same in Lean
 * (`table_cover`), so nothing written here is trusted. The route classes (POST and the short
 * paths at each post class, `pos: "route"`) extend the post rows with the budget and the tokens;
 * `CoverR.lean` proves their cover (`route_cover`). The decode classes (the decode loop's six cases,
 * `pos: "dec"`, `CasesL`'s boxes over `decI`): `CoverD.lean` (`dec_cover`).
 *
 * classes.json, per class: `pos`, `id` (Lean namespace under `lean.namespace`), `key` (the
 * PrefillSched class; `X`: the row class of the step's rows), `lean` (the class as a Lean term),
 * `count` (its steps), `cover` (its Lean cover theorem), `hints`, `layout` (the class's parameters
 * with their witnesses in `L` and the drain index `j`, and each quantity as `c + Σ cs[i]·x_i`), and
 * `rows`: `id` (Lean `Row`), `tags`, `count`, `params` (the row's own parameters: name, witness,
 * `box` `[lo, hi]`), `fixed` (layout parameters with one value on the row, folded into the forms),
 * `forms` (over the row's parameters), `rep` (a step near the box's centre: `L`, `j`, parameters
 * `x`); a route row's `params` carry their excluded values `ex`. A check of a template reading quantity `q` in variable `v` is
 * `goodLin <row>.ps (varsOf <row>.V [(v, .q), …]) O = true`, used through `good_of_row`. */
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

const HERE = dirname(new URL(import.meta.url).pathname);
const PROOFS = join(HERE, "../../..");
const LMAX = 262143;
const NS = "Host.Ts.Sim.Lin.Cls";

function fail(msg: string): never {
  throw new Error(msg);
}

/* ---------- The schedule, read from PrefillSched.lean ---------- */

const sched = readFileSync(join(PROOFS, "host/sim/PrefillSched.lean"), "utf8");

function block(start: string): string {
  const i = sched.indexOf(start);
  if (i < 0) fail(`PrefillSched.lean: no \`${start}\``);
  const j = sched.indexOf("\n\n", i);
  return sched.slice(i, j < 0 ? undefined : j);
}

const rowBands: [number, number][] = [...block("def rowBands").matchAll(/\((\d+), (\d+)\)/g)].map(m => [+m[1]!, +m[2]!]);
const chunkSizes: number[] = [...block("def chunkSizes").split(":=")[1]!.matchAll(/\d+/g)].map(m => +m[0]);
const chunkEq = block("theorem chunkC_eq");
const chunkTable: [number, number][] = [...chunkEq.matchAll(/L ≤ (\d+) then (\d+)/g)].map(m => [+m[1]!, +m[2]!]);
const chunkLast = +(chunkEq.match(/else (\d+) := by/) ?? fail("chunkC_eq: no final chunk"))[1]!;
const setupBands = [...block("def SetupClass.Applies").matchAll(/\| \.(\w+), L => (\d+) ≤ L ∧ L ≤ (\d+)/g)]
  .map(m => ({ name: m[1]!, lo: +m[2]!, hi: +m[3]! }));
const setupChunk = new Map([...block("def SetupClass.chunk").matchAll(/\| \.(\w+) => (\d+)/g)].map(m => [m[1]!, +m[2]!]));
const drainKeys = [...block("def drainClasses").matchAll(/⟨(\d+), (true|false)⟩/g)].map(m => ({ C: +m[1]!, grow: m[2] === "true" }));
if (rowBands.length !== 37 || chunkSizes.length !== 6 || chunkTable.length !== 5 || setupBands.length !== 7 || drainKeys.length !== 8)
  fail("PrefillSched.lean: unexpected class lists (update the generator)");

function chunkC(L: number): number {
  for (const [hi, c] of chunkTable) if (L <= hi) return c;
  return chunkLast;
}
// The band of lengths of each chunk size, within `L ≤ LMAX`.
const chunkBand = new Map<number, [number, number]>();
chunkTable.forEach(([hi, c], i) => chunkBand.set(c, [i === 0 ? 1 : chunkTable[i - 1]![0] + 1, Math.min(hi, LMAX)]));
chunkBand.set(chunkLast, [chunkTable[chunkTable.length - 1]![0] + 1, LMAX]);
const capL = (p: number) => 256 * Math.floor((p + 255) / 256);
const drains = (L: number) => Math.floor((L - 1) / chunkC(L));
const tailRows = (L: number) => (L - 1) % chunkC(L);
function rowClass(t: number): number {
  const i = rowBands.findIndex(([, hi]) => t <= hi);
  return i < 0 ? fail(`no row band for ${t}`) : i;
}
const rowClassesBelow = (C: number) => rowBands.map((b, X) => [b, X] as const).filter(([b]) => b[0] < C).map(([, X]) => X);
// The `chunkC_bounds` component of each chunk size.
const boundsPath = (C: number) => [".1", ".2.1", ".2.2.1", ".2.2.2.1", ".2.2.2.2.1", ".2.2.2.2.2"][chunkSizes.indexOf(C)] ?? fail(`chunk ${C}`);

/* ---------- Steps, tags ---------- */

type Q = "L" | "C" | "o" | "n" | "e" | "cap" | "cap1" | "k" | "T" | "t1" | "t2" | "kp";
type Pos = "setup" | "first" | "drain" | "tail" | "final" | "post";
interface Inst { L: number; C: number; o: number; n: number; cap: number; cap1: number; k: number }
const get = (i: Inst, q: Q) => (q === "e" ? i.o + i.n : q === "T" || q === "t1" || q === "t2" || q === "kp" ? 0 : i[q]);

const setupI = (L: number): Inst => ({ L, C: chunkC(L), o: 0, n: 0, cap: 0, cap1: 0, k: 0 });
function firstI(L: number): Inst {
  const C = chunkC(L), n = drains(L) >= 1 ? C : L >= 2 ? L - 1 : 1;
  return { L, C, o: 0, n, cap: 0, cap1: capL(n), k: 0 };
}
const drainI = (L: number, j: number): Inst => {
  const C = chunkC(L);
  return { L, C, o: j * C, n: C, cap: capL(j * C), cap1: capL((j + 1) * C), k: j };
};
const tailI = (L: number): Inst => {
  const C = chunkC(L), d = drains(L);
  return { L, C, o: d * C, n: tailRows(L), cap: capL(d * C), cap1: capL(L - 1), k: d };
};
const finalI = (L: number): Inst => ({ L, C: chunkC(L), o: L - 1, n: 1, cap: capL(L - 1), cap1: capL(L), k: drains(L) });
const postI = (L: number): Inst => ({ L, C: chunkC(L), o: L, n: 1, cap: capL(L), cap1: capL(L + 1), k: drains(L) });

function unique(kind: string, cands: [string, boolean][]): string {
  const hit = cands.filter(c => c[1]);
  if (hit.length !== 1) fail(`${kind}: ${hit.length} classes hold`);
  return hit[0]![0];
}
const nps = (L: number, o: number, C: number) => unique("nps", [
  ["DCby", C < L - o - 1], ["DCeq", L - o - 1 === C], ["DTtail", 3 <= L - o && L - o - 1 < C],
  ["DTdec", L - o === 2], ["FIN", L - o === 1]]);
const kv = (o: number, cap: number, n: number) => unique("kv", [
  ["DFirst", o === 0 && cap === 0 && n === 1],
  ["DGrow", 256 <= o && o % 256 === 0 && cap === o && n === 1],
  ["DFill", 1 <= o && cap === o + 1 && n === 1],
  ["DFit", 1 <= o && o + 1 < cap && n === 1],
  ["WFirst", o === 0 && cap === 0 && 2 <= n && n % 256 !== 0],
  ["WFirst256", o === 0 && cap === 0 && 256 <= n && n % 256 === 0],
  ["WGrow", 256 <= o && o % 256 === 0 && cap === o && 2 <= n && n % 256 !== 0],
  ["WGrow256", 256 <= o && o % 256 === 0 && cap === o && 256 <= n && n % 256 === 0],
  ["WFill", 1 <= o && 2 <= n && cap === o + n],
  ["WFit", 1 <= o && 2 <= n && o + n < cap]]);
function tagsOf(pos: Pos, i: Inst): [string, string][] {
  if (pos === "setup") return [];
  if (pos === "post") return [["kv", kv(i.o, i.cap, i.n)], ["kv2", kv(i.o + i.n, i.cap1, 1)]];
  return [["nps", nps(i.L, i.o, i.C)], ["kv", kv(i.o, i.cap, i.n)]];
}

/* ---------- Layouts: parameters, witnesses, forms ---------- */

interface Param { name: string; ts: (L: number, j: number) => number; lean: string }
interface Aff { c: number; cs: number[] }
interface Layout { params: Param[]; forms: [Q, Aff][] }
const aff = (c: number, cs: number[] = []): Aff => ({ c, cs });
const LI = "(L : Int)", JI = "(j : Int)";
const pL: Param = { name: "L", ts: L => L, lean: LI };
const pC: Param = { name: "c", ts: L => chunkC(L), lean: "(chunkC L : Int)" };
const allQ = (L: Aff, C: Aff, o: Aff, n: Aff, e: Aff, cap: Aff, cap1: Aff, k?: Aff): [Q, Aff][] =>
  [["L", L], ["C", C], ["o", o], ["n", n], ["e", e], ["cap", cap], ["cap1", cap1], ...(k ? [["k", k] as [Q, Aff]] : [])];

/** `capL` is constant over the rows of a band within one 256-block. */
function capConst(lo: number, hi: number): number {
  if (capL(lo) !== capL(hi)) fail(`band [${lo}, ${hi}] crosses a 256-block`);
  return capL(lo);
}

function drainLayout(C: number, grow: boolean): Layout {
  const t: Param = { name: "t", ts: (L, j) => L - 1 - (j + 1) * C, lean: `${LI} - 1 - (${JI} + 1) * ${C}` };
  if (C >= 256) return { params: [{ name: "j", ts: (_, j) => j, lean: JI }, t],
    forms: allQ(aff(C + 1, [C, 1]), aff(C), aff(0, [C]), aff(C), aff(C, [C]), aff(0, [C]), aff(C, [C]), aff(0, [1])) };
  const per = 256 / C;
  const a: Param = { name: "a", ts: (_, j) => Math.floor(j / per), lean: `${JI} / ${per}` };
  if (grow) return { params: [a, t],
    forms: allQ(aff(C + 1, [256, 1]), aff(C), aff(0, [256]), aff(C), aff(C, [256]), aff(0, [256]), aff(256, [256]), aff(0, [per])) };
  if (C === 128) return { params: [a, t],
    forms: allQ(aff(257, [256, 1]), aff(C), aff(128, [256]), aff(C), aff(256, [256]), aff(256, [256]), aff(256, [256]), aff(1, [2])) };
  const s: Param = { name: "s", ts: (_, j) => j % per, lean: `${JI} % ${per}` };
  return { params: [a, s, t],
    forms: allQ(aff(C + 1, [256, C, 1]), aff(C), aff(0, [256, C]), aff(C), aff(C, [256, C]), aff(256, [256]), aff(256, [256]), aff(0, [per, 1])) };
}

function tailLayout(C: number, X: number, grow: boolean): Layout {
  const [lo, hi] = rowBands[X]!;
  const t: Param = { name: "t", ts: L => (L - 1) % C, lean: `(${LI} - 1) % ${C}` };
  if (C >= 256) {
    const cc = capConst(Math.max(lo, 1), Math.min(hi, C - 1));
    return { params: [{ name: "k", ts: L => Math.floor((L - 1) / C), lean: `(${LI} - 1) / ${C}` }, t],
      forms: allQ(aff(1, [C, 1]), aff(C), aff(0, [C]), aff(0, [0, 1]), aff(0, [C, 1]), aff(0, [C]), aff(cc, [C]), aff(0, [1])) };
  }
  const per = 256 / C;
  const a: Param = { name: "a", ts: L => Math.floor(Math.floor((L - 1) / C) / per), lean: `(${LI} - 1) / ${C} / ${per}` };
  if (grow) return { params: [a, t],
    forms: allQ(aff(1, [256, 1]), aff(C), aff(0, [256]), aff(0, [0, 1]), aff(0, [256, 1]), aff(0, [256]), aff(256, [256]), aff(0, [per])) };
  if (C === 128) return { params: [a, t],
    forms: allQ(aff(129, [256, 1]), aff(C), aff(128, [256]), aff(0, [0, 1]), aff(128, [256, 1]), aff(256, [256]), aff(256, [256]), aff(1, [2])) };
  const s: Param = { name: "s", ts: L => Math.floor((L - 1) / C) % per, lean: `(${LI} - 1) / ${C} % ${per}` };
  return { params: [a, s, t],
    forms: allQ(aff(1, [256, C, 1]), aff(C), aff(0, [256, C]), aff(0, [0, 0, 1]), aff(0, [256, C, 1]), aff(256, [256]), aff(256, [256]), aff(0, [per, 1])) };
}

/* ---------- Classes ---------- */

interface Row { tags: [string, string][]; lo: number[]; hi: number[]; count: number; rep?: { L: number; j: number; x: number[] }; score: number }

/** A row's own parameters: the layout's minus those with one value on the row, which are folded
 * into the forms' constants (`goodLin` decides an equality of two forms only when their
 * difference is a constant, so `t - 1` over `t ∈ [1, 1]` must become `0`). */
const free = (r: Row) => r.lo.map((_, p) => p).filter(p => r.lo[p]! < r.hi[p]!);
function fold(r: Row, f: Aff): Aff {
  const cs = free(r).map(p => f.cs[p] ?? 0);
  while (cs.length && cs[cs.length - 1] === 0) cs.pop();
  return { c: f.cs.reduce((c, a, p) => (r.lo[p] === r.hi[p] ? c + a * r.lo[p]! : c), f.c), cs };
}
type Tree = { leaf: number } | { p: number; v: number; le: Tree; gt: Tree };
interface Cls {
  pos: Pos; id: string; key: Record<string, unknown>; lean: string; layout: Layout;
  prelude: string[]; unfold: string[]; hints: Record<string, string>;
  rowMap: Map<string, Row>; rows: Row[]; tree?: Tree; count: number;
}

const classes: Cls[] = [];
const byId = new Map<string, Cls>();
function cls(c: Omit<Cls, "rowMap" | "rows" | "count" | "hints"> & { hints?: Record<string, string> }): Cls {
  const k: Cls = { hints: {}, ...c, rowMap: new Map(), rows: [], count: 0 };
  classes.push(k);
  byId.set(k.id, k);
  return k;
}

const introL = "intro L h1 h2 ha";
/** A whole chunk's row class (`X`, as a tail of `C` rows would have) where `rowBands` holds `C`. */
const rowsX = (C: number) => (C <= rowBands[rowBands.length - 1]![1] ? { X: rowClass(C) } : {});
for (const { name, lo, hi } of setupBands) {
  const C = setupChunk.get(name) ?? fail(`SetupClass.chunk .${name}`);
  cls({ pos: "setup", id: `setup_${name}`, key: { name, band: [lo, hi], chunk: C }, lean: `.${name}`,
    layout: { params: [pL], forms: [["L", aff(0, [1])], ["C", aff(C)]] },
    prelude: [introL, "simp only [SetupClass.Applies] at ha",
      `have hC : chunkC L = ${C} := by rw [chunkC_eq L (by omega)]; (repeat' split) <;> omega`],
    unfold: ["setupI", "hC"], hints: { chunk: `K${name === "early" ? 8 : C}` } });
}
for (const C of chunkSizes)
  cls({ pos: "first", id: `first_drain_${C}`, key: { kind: "drain", C, ...rowsX(C) }, lean: `.drain ${C}`,
    layout: { params: [pL], forms: allQ(aff(0, [1]), aff(C), aff(0), aff(C), aff(C), aff(0), aff(capL(C)), aff(0)) },
    prelude: [introL, "obtain ⟨hC0, hd⟩ := ha", `have hC : chunkC L = ${C} := hC0.symm`,
      `have hb := (chunkC_bounds (L := L) (by omega))${boundsPath(C)} hC`, "simp only [drains, hC] at hd",
      `have hn : firstN L = ${C} := by simp only [firstN, drains, hC]; (repeat' split) <;> omega`],
    unfold: ["firstI", "hn", "hC"] });
rowBands.forEach(([lo, hi], X) => cls({ pos: "first", id: `first_tail_x${X}`, key: { kind: "tail", X, band: [lo, hi] }, lean: `.tail ${X}`,
  layout: { params: [{ name: "t", ts: L => L - 1, lean: `${LI} - 1` }],
    forms: allQ(aff(1, [1]), aff(2048), aff(0), aff(0, [1]), aff(0, [1]), aff(0), aff(capConst(lo, Math.min(hi, 2047))), aff(0)) },
  prelude: [introL, "obtain ⟨hd, hL, hX⟩ := ha", "have hC : chunkC L = 2048 := (first_chunk (by omega) hd).1",
    "have hL2 := (first_chunk (by omega) hd).2",
    `have hX' := (rowMem_iff (X := ${X}) (lo := ${lo}) (hi := ${hi}) (by decide)).1 hX`,
    "have hn : firstN L = L - 1 := by simp only [firstN, hd]; (repeat' split) <;> omega"],
  unfold: ["firstI", "hn", "hC"] }));
cls({ pos: "first", id: "first_final", key: { kind: "final" }, lean: ".final",
  layout: { params: [], forms: allQ(aff(1), aff(2048), aff(0), aff(1), aff(1), aff(0), aff(256), aff(0)) },
  prelude: [introL, "simp only [FirstClass.Applies] at ha", "subst ha",
    "have hC : chunkC 1 = 2048 := by decide", "have hn : firstN 1 = 1 := by decide"],
  unfold: ["firstI", "hn", "hC"] });
for (const { C, grow } of drainKeys)
  cls({ pos: "drain", id: `drain_${C}_${grow ? "g" : "f"}`, key: { C, grow, ...rowsX(C) }, lean: `⟨${C}, ${grow}⟩`, layout: drainLayout(C, grow),
    prelude: ["intro L j h1 h2 ha", "obtain ⟨hC0, hj, hle, hg⟩ := ha", "simp only at hC0 hle hg",
      `have hC : chunkC L = ${C} := hC0.symm`, `have hb := (chunkC_bounds (L := L) (by omega))${boundsPath(C)} hC`,
      `have hg' := of_decide_eq_${grow} hg.symm`],
    unfold: ["drainI", "hC"] });
for (const C of chunkSizes)
  for (const X of rowClassesBelow(C))
    for (const grow of C >= 256 ? [true] : [true, false]) {
      const [lo, hi] = rowBands[X]!;
      cls({ pos: "tail", id: `tail_${C}_x${X}_${grow ? "g" : "f"}`, key: { C, X, band: [lo, hi], grow }, lean: `⟨${C}, ${X}, ${grow}⟩`,
        layout: tailLayout(C, X, grow),
        prelude: [introL, "obtain ⟨hC0, hd, ht, hX, hg⟩ := ha", "simp only at hC0 hX hg",
          `have hC : chunkC L = ${C} := hC0.symm`, `have hb := (chunkC_bounds (L := L) (by omega))${boundsPath(C)} hC`,
          `have hX' := (rowMem_iff (X := ${X}) (lo := ${lo}) (hi := ${hi}) (by decide)).1 hX`,
          `have hg' := of_decide_eq_${grow} hg.symm`, "simp only [drains, tailRows, hC] at hd ht hX' hg'"],
        unfold: ["tailI", "drains", "tailRows", "hC"] });
    }
cls({ pos: "final", id: "final_cold", key: { kind: "cold" }, lean: ".cold",
  layout: { params: [], forms: allQ(aff(1), aff(2048), aff(0), aff(1), aff(1), aff(0), aff(256)) },
  prelude: [introL, "simp only [FinalClass.Applies] at ha", "subst ha", "have hC : chunkC 1 = 2048 := by decide"],
  unfold: ["finalI", "hC"] });
const bW: Param = { name: "b", ts: L => Math.floor((L - 1) / 256), lean: `(${LI} - 1) / 256` };
for (const [kvb, layout] of [
  ["ord", { params: [bW, { name: "s", ts: L => (L - 1) % 256, lean: `(${LI} - 1) % 256` }, pC],
    forms: allQ(aff(1, [256, 1]), aff(0, [0, 0, 1]), aff(0, [256, 1]), aff(1), aff(1, [256, 1]), aff(256, [256]), aff(256, [256])) }],
  ["fill", { params: [bW, pC], forms: allQ(aff(256, [256]), aff(0, [0, 1]), aff(255, [256]), aff(1), aff(256, [256]), aff(256, [256]), aff(256, [256])) }],
  ["grow", { params: [bW, pC], forms: allQ(aff(1, [256]), aff(0, [0, 1]), aff(0, [256]), aff(1), aff(1, [256]), aff(0, [256]), aff(256, [256])) }],
] as [string, Layout][])
  cls({ pos: "final", id: `final_${kvb}`, key: { kind: "warm", kv: kvb }, lean: `.warm .${kvb}`, layout,
    prelude: [introL, "obtain ⟨hL, hkv⟩ := ha", `have hk := kvOf_${kvb} hkv`, "have hr := chunkC_range (L := L) (by omega)"],
    unfold: ["finalI"] });
const bP: Param = { name: "b", ts: L => Math.floor(L / 256), lean: `${LI} / 256` };
for (const [pc, layout] of [
  ["r0", { params: [bP, pC], forms: allQ(aff(0, [256]), aff(0, [0, 1]), aff(0, [256]), aff(1), aff(1, [256]), aff(0, [256]), aff(256, [256])) }],
  ["r255", { params: [bP, pC], forms: allQ(aff(255, [256]), aff(0, [0, 1]), aff(255, [256]), aff(1), aff(256, [256]), aff(256, [256]), aff(256, [256])) }],
  ["r254", { params: [bP, pC], forms: allQ(aff(254, [256]), aff(0, [0, 1]), aff(254, [256]), aff(1), aff(255, [256]), aff(256, [256]), aff(256, [256])) }],
  ["other", { params: [bP, { name: "r", ts: L => L % 256, lean: `${LI} % 256` }, pC],
    forms: allQ(aff(0, [256, 1]), aff(0, [0, 0, 1]), aff(0, [256, 1]), aff(1), aff(1, [256, 1]), aff(256, [256]), aff(256, [256])) }],
] as [string, Layout][])
  cls({ pos: "post", id: `post_${pc}`, key: { residue: pc }, lean: `.${pc}`, layout,
    prelude: [introL, `have hk := postOf_${pc} ha`, "have hr := chunkC_range (L := L) (by omega)"], unfold: ["postI"] });

/* ---------- Enumeration ---------- */

const evalAff = (f: Aff, x: number[]) => f.cs.reduce((s, a, i) => s + a * x[i]!, f.c);
const tagKey = (t: [string, string][]) => t.map(([k, v]) => `${k}:${v}`).join(" ");

function walk(t: Tree, x: number[]): number {
  while (!("leaf" in t)) t = x[t.p]! <= t.v ? t.le : t.gt;
  return t.leaf;
}

/** One step `i` of class `c` (at `L`, drain index `j`). Pass 1 records boxes; pass 2 checks the
 * decision tree and picks the representatives. */
function visit(pass: 1 | 2, c: Cls, i: Inst, L: number, j: number, steps = 1) {
  const x = c.layout.params.map(p => p.ts(L, j));
  for (const [q, f] of c.layout.forms)
    if (evalAff(f, x) !== get(i, q)) fail(`${c.id}: form of ${q} at L=${L} j=${j}: ${evalAff(f, x)} ≠ ${get(i, q)}`);
  const tags = tagsOf(c.pos, i), key = tagKey(tags);
  if (pass === 1) {
    let r = c.rowMap.get(key);
    if (!r) c.rowMap.set(key, r = { tags, lo: x.slice(), hi: x.slice(), count: 0, score: Infinity });
    x.forEach((v, p) => { r.lo[p] = Math.min(r.lo[p]!, v); r.hi[p] = Math.max(r.hi[p]!, v); });
    r.count += steps;
    c.count += steps;
    return;
  }
  const r = c.rows[walk(c.tree!, x)]!;
  if (tagKey(r.tags) !== key) fail(`${c.id}: L=${L} j=${j} reaches row ${tagKey(r.tags)}, tags ${key}`);
  x.forEach((v, p) => { if (v < r.lo[p]! || v > r.hi[p]!) fail(`${c.id}: L=${L} j=${j} outside its box`); });
  const score = x.reduce((s, v, p) => s + Math.abs(v - (r.lo[p]! + r.hi[p]!) / 2) / Math.max(1, r.hi[p]! - r.lo[p]!), 0);
  if (score < r.score) { r.score = score; r.rep = { L, j, x }; }
}

function enumerate(pass: 1 | 2) {
  for (let L = 1; L <= LMAX; L++) {
    const C = chunkC(L), d = drains(L), t = tailRows(L);
    const setup = setupBands.find(b => b.lo <= L && L <= b.hi) ?? fail(`setup class of ${L}`);
    visit(pass, byId.get(`setup_${setup.name}`)!, setupI(L), L, 0);
    visit(pass, byId.get(d >= 1 ? `first_drain_${C}` : L >= 2 ? `first_tail_x${rowClass(L - 1)}` : "first_final")!, firstI(L), L, 0);
    if (d >= 1 && t >= 1) visit(pass, byId.get(`tail_${C}_x${rowClass(t)}_${(d * C) % 256 === 0 ? "g" : "f"}`)!, tailI(L), L, 0);
    const o = L - 1;
    visit(pass, byId.get(L === 1 ? "final_cold" : `final_${o % 256 === 0 ? "grow" : o % 256 === 255 ? "fill" : "ord"}`)!, finalI(L), L, 0);
    visit(pass, byId.get(`post_${L % 256 === 0 ? "r0" : L % 256 === 255 ? "r255" : L % 256 === 254 ? "r254" : "other"}`)!, postI(L), L, 0);
  }
  // The drains: for each chunk and index `j ≥ 1`, the lengths with `(j + 1)·C ≤ L - 1` in the chunk's
  // band are an interval; the forms are affine in `L` there and the tags constant on its last
  // (`L - 1 = (j + 1)·C`) and other lengths, so its ends and middle are visited.
  for (const C of chunkSizes) {
    const [lo, hi] = chunkBand.get(C)!;
    for (let j = 1; (j + 1) * C + 1 <= hi; j++) {
      const c = byId.get(`drain_${C}_${(j * C) % 256 === 0 ? "g" : "f"}`)!;
      const last = (j + 1) * C + 1;
      if (last >= lo) visit(pass, c, drainI(last, j), last, j);
      const a = Math.max(lo, last + 1);
      if (a <= hi)
        for (const L of new Set([a, Math.floor((a + hi) / 2), hi])) visit(pass, c, drainI(L, j), L, j, L === a ? hi - a + 1 : 0);
    }
  }
}

/** A decision tree separating the rows' boxes by one parameter at a time. */
function separate(c: Cls, rows: number[]): Tree {
  if (rows.length === 1) return { leaf: rows[0]! };
  for (let p = 0; p < c.layout.params.length; p++) {
    const sorted = rows.slice().sort((a, b) => c.rows[a]!.lo[p]! - c.rows[b]!.lo[p]!);
    let v = -Infinity;
    for (let k = 0; k + 1 < sorted.length; k++) {
      v = Math.max(v, c.rows[sorted[k]!]!.hi[p]!);
      if (c.rows[sorted[k + 1]!]!.lo[p]! > v) {
        const le = sorted.slice(0, k + 1), gt = sorted.slice(k + 1);
        return { p, v, le: separate(c, le), gt: separate(c, gt) };
      }
    }
  }
  fail(`${c.id}: rows ${rows.map(r => tagKey(c.rows[r]!.tags)).join(", ")} are not separated by one parameter`);
}

/* ---------- Lean ---------- */

const leanInt = (v: number) => (v < 0 ? `-${-v}` : `${v}`);
const leanAff = (f: Aff) => `⟨${leanInt(f.c)}, [${f.cs.map(leanInt).join(", ")}]⟩`;
const leanTag = ([k, v]: [string, string]) => `.${k} .${v}`;
const rowName = (c: Cls, i: number) => `${c.id}.r${i}`;
const pred: Record<Pos, string> = { setup: "SetupP", first: "FirstP", drain: "DrainP", tail: "TailP", final: "FinalP", post: "PostP" };
const table: Record<Pos, string> = { setup: "setupTable", first: "firstTable", drain: "drainTable", tail: "tailTable", final: "finalTable", post: "postTable" };
const ktype: Record<Pos, string> = { setup: "SetupClass", first: "FirstClass", drain: "DrainClass", tail: "TailClass", final: "FinalClass", post: "PostClass" };
const klist: Record<Pos, string> = { setup: "setupClasses", first: "firstClasses", drain: "drainClasses", tail: "tailClasses", final: "finalClasses", post: "postClasses" };
const POS: Pos[] = ["setup", "first", "drain", "tail", "final", "post"];

function rowDef(c: Cls, i: number): string {
  const r = c.rows[i]!;
  const ps = free(r).map(p => `⟨${leanInt(r.lo[p]!)}, ${leanInt(r.hi[p]!)}, []⟩`).join(", ");
  const V = c.layout.forms.map(([q, f]) => `(.${q}, ${leanAff(fold(r, f))})`).join(", ");
  return `def ${rowName(c, i)} : Row :=\n  ⟨[${ps}],\n   [${V}],\n   [${r.tags.map(leanTag).join(", ")}]⟩`;
}

function coverProof(c: Cls): string {
  const wit = (r: Row) => `vx [${free(r).map(p => c.layout.params[p]!.lean).join(", ")}]`;
  const u = c.unfold.join(", ");
  let n = 0;
  const bullet = (ls: string[]) => [`· ${ls[0]}`, ...ls.slice(1).map(l => `  ${l}`)];
  const go = (t: Tree): string[] => {
    if ("leaf" in t) {
      const r = rowName(c, t.leaf), mem = ".tail _ (".repeat(t.leaf) + ".head _" + ")".repeat(t.leaf);
      return [`exact ⟨${r}, ${mem}, by row_close [${r}, ${u}], ${wit(c.rows[t.leaf]!)},`, `  by row_close [${r}], by row_close [${r}, ${u}]⟩`];
    }
    const h = `s${n++}`;
    return [`by_cases ${h} : ${c.layout.params[t.p]!.lean} ≤ ${leanInt(t.v)}`, ...bullet(go(t.le)), ...bullet(go(t.gt))];
  };
  return `theorem ${c.id}.cover : ${pred[c.pos]} (${c.lean}) ${c.id}.rows := by\n` +
    [...c.prelude, ...go(c.tree!)].map(l => `  ${l}`).join("\n");
}

const HEADER = (imports: string[], doc: string) =>
  `${imports.map(i => `import ${i}`).join("\n")}\nset_option maxRecDepth 100000\nnamespace ${NS}\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Prefill\n\n/-! ${doc} -/\n\n`;

function writeTable() {
  let s = HEADER(["host.sim.lin.Classes"],
    `# The class table (generated by \`host/sim/lin/gen.ts table\` from \`host.sim.PrefillSched\`)

Each class's rows (\`<class>.rows\`), and per position the table of the classes in
\`PrefillSched\`'s order (\`*Table\`, keys checked: \`*Table_keys\`). \`host.sim.lin.Cover\` proves
that the rows cover their classes.`);
  for (const c of classes) {
    s += c.rows.map((_, i) => rowDef(c, i)).join("\n\n") + "\n\n";
    s += `def ${c.id}.rows : List Row := [${c.rows.map((_, i) => rowName(c, i)).join(", ")}]\n\n`;
  }
  for (const p of POS) {
    const cs = classes.filter(c => c.pos === p);
    s += `def ${table[p]} : List (${ktype[p]} × List Row) :=\n  [${cs.map(c => `(${c.lean}, ${c.id}.rows)`).join(",\n   ")}]\n\n`;
    s += `theorem ${table[p]}_keys : ${table[p]}.map Prod.fst = ${klist[p]} := by decide +kernel\n\n`;
  }
  writeFileSync(join(HERE, "Table.lean"), s + `end ${NS}\n`);
}

const coverGroups: [string, (c: Cls) => boolean][] = [
  ["CoverA", c => c.pos !== "tail"],
  ["CoverT1", c => c.pos === "tail" && (c.key.C as number) >= 1024],
  ["CoverT2", c => c.pos === "tail" && (c.key.C as number) < 1024],
];

function writeCover() {
  for (const [mod, sel] of coverGroups) {
    let s = HEADER(["host.sim.lin.Table"], `# Cover proofs of the class table (generated by \`host/sim/lin/gen.ts table\`)

\`<class>.cover\`: every step of the class is in one of its rows. The facts of the class
(\`*.Applies\`, the chunk's band) are put in context, the decision tree's tests split the
rows, and each row's tags, box and forms close by \`omega\` at the witnesses \`vx [...]\`.`);
    for (const c of classes.filter(sel)) s += coverProof(c) + "\n\n";
    writeFileSync(join(HERE, `${mod}.lean`), s + `end ${NS}\n`);
  }
  let s = HEADER(coverGroups.map(([m]) => `host.sim.lin.${m}`), `# The class table covers exactly the classes of \`PrefillSched\` (generated by \`host/sim/lin/gen.ts table\`)

\`table_cover\`: the tables' keys are \`PrefillSched\`'s class lists, and at every length
\`1 ≤ L ≤ 262143\` the step at each position of the chain of \`L\` (\`chainOf\`) is in a row of its
class.`);
  for (const p of POS) {
    const cs = classes.filter(c => c.pos === p);
    s += `theorem ${table[p]}_all : ∀ q ∈ ${table[p]}, ${pred[p]} q.1 q.2 := by\n  unfold ${table[p]}\n  exact ` +
      cs.map(c => `all_cons ${c.id}.cover (`).join("\n    ") + "all_nil" + ")".repeat(cs.length) + "\n\n";
  }
  s += `/-- **The class table covers exactly the classes of \`PrefillSched\`.** -/
theorem table_cover :
    setupTable.map Prod.fst = setupClasses ∧ firstTable.map Prod.fst = firstClasses ∧
    drainTable.map Prod.fst = drainClasses ∧ tailTable.map Prod.fst = tailClasses ∧
    finalTable.map Prod.fst = finalClasses ∧ postTable.map Prod.fst = postClasses ∧
    ∀ L, 1 ≤ L → L ≤ 262143 →
      (∃ r ∈ rowsOf setupTable (chainOf L).setup, InRow r (setupI L)) ∧
      (∃ r ∈ rowsOf firstTable (chainOf L).first, InRow r (firstI L)) ∧
      (∀ j, 1 ≤ j → j + 1 ≤ drains L → ∃ r ∈ rowsOf drainTable ((chainOf L).later j), InRow r (drainI L j)) ∧
      (∀ d, (chainOf L).tail = some d → ∃ r ∈ rowsOf tailTable d, InRow r (tailI L)) ∧
      (∃ r ∈ rowsOf finalTable (chainOf L).final, InRow r (finalI L)) ∧
      (∃ r ∈ rowsOf postTable (chainOf L).post, InRow r (postI L)) := by
  refine ⟨setupTable_keys, firstTable_keys, drainTable_keys, tailTable_keys, finalTable_keys, postTable_keys, ?_⟩
  intro L h1 h2
  obtain ⟨⟨s1, s2, -⟩, ⟨f1, f2, -⟩, hdr, -, htl, ⟨n1, n2, -⟩, ⟨p1, p2, -⟩⟩ := chain_cover L h1 h2
  refine ⟨rowsOf_all setupTable_all _ (by rw [setupTable_keys]; exact s1) L h1 h2 s2,
    rowsOf_all firstTable_all _ (by rw [firstTable_keys]; exact f1) L h1 h2 f2,
    fun j hj1 hjk => rowsOf_all drainTable_all _ (by rw [drainTable_keys]; exact (hdr j hj1 hjk).1) L j h1 h2 (hdr j hj1 hjk).2.1,
    fun d hd => rowsOf_all tailTable_all d (by rw [tailTable_keys]; exact (htl d hd).1) L h1 h2 (htl d hd).2.1,
    rowsOf_all finalTable_all _ (by rw [finalTable_keys]; exact n1) L h1 h2 n2,
    rowsOf_all postTable_all _ (by rw [postTable_keys]; exact p1) L h1 h2 p2⟩

`;
  writeFileSync(join(HERE, "Cover.lean"), s + `end ${NS}\n`);
}

function writeJson() {
  const out = {
    generator: "proofs/host/sim/lin/gen.ts",
    schedule: "proofs/host/sim/PrefillSched.lean",
    lean: { table: "host.sim.lin.Table", cover: "host.sim.lin.Cover", namespace: NS, theorem: `${NS}.table_cover` },
    Lmax: LMAX,
    quantities: {
      L: "prompt length", C: "chunk size", o: "step start", n: "step rows", e: "step end o + n",
      cap: "KV capacity before the step's append", cap1: "KV capacity after it", k: "drain index (drain), drains before the tail (tail)",
    },
    positions: {
      setup: { step: "setupI L", args: ["L"], pred: "SetupP" }, first: { step: "firstI L", args: ["L"], pred: "FirstP" },
      drain: { step: "drainI L j", args: ["L", "j"], pred: "DrainP" }, tail: { step: "tailI L", args: ["L"], pred: "TailP" },
      final: { step: "finalI L", args: ["L"], pred: "FinalP" }, post: { step: "postI L", args: ["L"], pred: "PostP" },
    },
    classes: classes.map(c => ({
      pos: c.pos, id: c.id, key: c.key, lean: c.lean, count: c.count, cover: `${NS}.${c.id}.cover`, hints: c.hints,
      layout: { params: c.layout.params.map(p => ({ name: p.name, wit: p.lean })), forms: Object.fromEntries(c.layout.forms) },
      rows: c.rows.map((r, i) => ({
        id: rowName(c, i), tags: Object.fromEntries(r.tags), count: r.count,
        params: free(r).map(p => ({ name: c.layout.params[p]!.name, wit: c.layout.params[p]!.lean, box: [r.lo[p], r.hi[p]] })),
        fixed: Object.fromEntries(r.lo.map((lo, p) => [c.layout.params[p]!.name, lo] as const).filter((_, p) => r.lo[p] === r.hi[p])),
        forms: Object.fromEntries(c.layout.forms.map(([q, f]) => [q, fold(r, f)])),
        rep: r.rep && { L: r.rep.L, j: r.rep.j, x: free(r).map(p => r.rep!.x[p]) },
      })),
    })),
  };
  Object.assign(out.quantities, { T: "the budget (route positions)", t1: "token 1 (route positions)", t2: "token 2 (route positions)" });
  Object.assign(out.positions, { route: { step: "routeI L T t1 t2", args: ["L", "T", "t1", "t2"], pred: "RouteP", facts: "RouteKind.Holds" } });
  (out.classes as unknown[]).push(...routeClasses.map(c => ({
    pos: "route", id: c.id, key: { kind: c.kind, post: c.post }, lean: c.lean, cover: `${NS}.${c.id}.cover`,
    rows: c.rows.map(r => ({ id: r.id, tags: Object.fromEntries(r.tags), params: r.params.map(p => ({ name: p.name, wit: p.lean, box: [p.lo, p.hi], ex: p.ex })),
      forms: Object.fromEntries(r.forms) })),
  })));
  Object.assign(out.quantities, { kp: "the iteration minus one (decode)" });
  Object.assign(out.positions, { dec: { step: "decI L T i t1", args: ["L", "T", "i", "t1"], pred: "DecP", facts: "DecKind.Sel",
    vars: { map: `${NS}.decM`, of: [[0, "T"], [9, "o"], [10, "k"], [11, "k"], [12, "k"], [13, "kp"], [14, "t1"], [16, "cap"]] } } });
  (out.classes as unknown[]).push(...decClasses.map(c => ({
    pos: "dec", id: c.id, key: { kind: c.kind }, lean: `.${c.kind}`, cover: `${NS}.${c.id}.cover`,
    rows: [{ id: c.row.id, tags: Object.fromEntries(c.row.tags),
      params: c.row.params.map(p => ({ name: p.name, wit: p.lean, box: [p.lo, p.hi], ex: p.ex })), forms: Object.fromEntries(c.row.forms) }],
  })));
  writeFileSync(join(HERE, "classes.json"), JSON.stringify(out, null, 1) + "\n");
}

/* ---------- The route's classes: POST and the short paths ---------- */

// After the prefill the route reads the budget `T` and tokens 1, 2 (each in the vocabulary
// `[0, 248319]`, EOS `248044`; `Classes.RouteKind.Holds`): a route class is a position at a post
// class, its rows the post class's row with the budget and the tokens as parameters. A token is
// EOS (a constant), not EOS (a parameter excluding EOS), or, where the position's facts leave it
// open, split into both rows, so that a piece's EOS test is decided on every row; past the budget
// (token 2 at `T = 1`) it is no parameter.
const EOS = 248044, VOC = 248319, TMAX = LMAX;
type TokM = "eos" | "not" | "split" | "none";
interface RParam { name: string; lean: string; lo: number; hi: number; ex: number[] }
interface RRow { id: string; params: RParam[]; forms: [Q, Aff][]; tags: [string, string][] }
interface RCls { kind: string; post: string; id: string; lean: string; rows: RRow[]; splits: string[]; prelude: string[] }
const routeClasses: RCls[] = [];
const kinds: [string, { T: number | [number, number]; t1: TokM; t2: TokM }][] = [
  ["post", { T: [3, TMAX], t1: "not", t2: "split" }], ["pathA", { T: [2, TMAX], t1: "eos", t2: "split" }],
  ["pathB", { T: 2, t1: "not", t2: "split" }], ["pathC", { T: 1, t1: "split", t2: "none" }]];
function buildRoute() {
  for (const [kind, spec] of kinds)
    for (const c of classes.filter(c => c.pos === "post")) {
      if (c.rows.length !== 1) fail(`${c.id}: one row expected`);
      const r = c.rows[0]!;
      const base: RParam[] = free(r).map(p => ({ name: c.layout.params[p]!.name, lean: c.layout.params[p]!.lean, lo: r.lo[p]!, hi: r.hi[p]!, ex: [] }));
      const baseForms: [Q, Aff][] = c.layout.forms.map(([q, fm]) => [q, fold(r, fm)]);
      const opts = (m: TokM): ("eos" | "not" | "none")[] => (m === "split" ? ["eos", "not"] : [m]);
      const vs = opts(spec.t1).flatMap(t1 => opts(spec.t2).map(t2 => ({ t1, t2 })));
      const rows: RRow[] = vs.map((v, k) => {
        const params = base.slice(), forms = baseForms.slice();
        const add = (q: Q, p: RParam) => { params.push(p); forms.push([q, aff(0, [...Array(params.length - 1).fill(0), 1])]); };
        if (typeof spec.T === "number") forms.push(["T", aff(spec.T)]);
        else add("T", { name: "T", lean: "(T : Int)", lo: spec.T[0], hi: spec.T[1], ex: [] });
        for (const q of ["t1", "t2"] as const)
          if (v[q] === "eos") forms.push([q, aff(EOS)]); else if (v[q] === "not") add(q, { name: q, lean: `(${q} : Int)`, lo: 0, hi: VOC, ex: [EOS] });
        return { id: `route_${kind}_${c.key.residue}.r${k}`, params, forms, tags: r.tags };
      });
      routeClasses.push({ kind, post: c.key.residue as string, id: `route_${kind}_${c.key.residue}`,
        lean: `(RouteKind.${kind}, PostClass.${c.key.residue})`, rows,
        splits: (["t1", "t2"] as const).filter(q => spec[q] === "split"), prelude: c.prelude.slice(1) });
    }
}
function routeRowDef(r: RRow): string {
  const ps = r.params.map(p => `⟨${leanInt(p.lo)}, ${leanInt(p.hi)}, [${p.ex.join(", ")}]⟩`).join(", ");
  const V = r.forms.map(([q, fm]) => `(.${q}, ${leanAff(fm)})`).join(", ");
  return `def ${r.id} : Row :=\n  ⟨[${ps}],\n   [${V}],\n   [${r.tags.map(leanTag).join(", ")}]⟩`;
}
/** The cover: each split token's EOS test, then the row (rows in the order t1's options, t2's). */
function routeCover(c: RCls): string {
  const leaf = (k: number): string[] => {
    const r = c.rows[k]!, mem = ".tail _ (".repeat(k) + ".head _" + ")".repeat(k);
    return [`exact ⟨${r.id}, ${mem}, by row_close [${r.id}, routeI], vx [${r.params.map(p => p.lean).join(", ")}],`,
      `  by row_close [${r.id}], by row_close [${r.id}, routeI]⟩`];
  };
  const bullet = (ls: string[]) => [`· ${ls[0]}`, ...ls.slice(1).map(l => `  ${l}`)];
  const go = (d: number, k: number, w: number): string[] => {
    if (d === c.splits.length) return leaf(k);
    const q = c.splits[d]!, h = w / 2;
    return [`by_cases e${q} : ${q} = ${EOS}`, ...bullet(go(d + 1, k, h)), ...bullet(go(d + 1, k + h, h))];
  };
  return `theorem ${c.id}.cover : RouteP .${c.kind} .${c.post} ${c.id}.rows := by\n` +
    ["intro L T t1 t2 h1 h2 hq ha", "simp only [RouteKind.Holds] at hq", ...c.prelude, ...go(0, 0, c.rows.length)].map(l => `  ${l}`).join("\n");
}
/* ---------- The decode loop's classes ---------- */

// A decode iteration `i` after a prompt of length `L` at budget `T` (`Classes.decI`): the row at offset
// `p = L + i + 1` with capacity `capL p`, its case (`DecKind`: the clear at `i ≡ 0`, the KV class of `p`).
// One row per case, `CasesL`'s boxes: `i = 256 a + r`, `p = 256 b + s`, `T = i + 3 + t`, the current token
// `tok` in the vocabulary and not EOS. The pieces' oracles (the regenerated decode templates') are
// checked over these rows; the KV append's (the D1 row, `DFit`, `DGrow`, `DFill`) already is.
interface DSpec { kind: string; clear: boolean; s: "mid" | "fill" | "grow"; kv: string }
const decSpecs: DSpec[] = [
  { kind: "ord", clear: false, s: "mid", kv: "DFit" }, { kind: "clear", clear: true, s: "mid", kv: "DFit" },
  { kind: "grow", clear: false, s: "grow", kv: "DGrow" }, { kind: "fill", clear: false, s: "fill", kv: "DFill" },
  { kind: "clearFill", clear: true, s: "fill", kv: "DFill" }, { kind: "clearGrow", clear: true, s: "grow", kv: "DGrow" }];
const DMAX = Math.floor(TMAX / 256);
interface DCls { kind: string; id: string; row: RRow }
const decClasses: DCls[] = [];
function buildDec() {
  for (const d of decSpecs) {
    // the parameters by name, a fixed value or a box (with its witness)
    type PV = { fixed: number } | RParam;
    const pv: [string, PV][] = [
      ["a", { name: "a", lean: "(i : Int) / 256", lo: d.clear ? 1 : 0, hi: DMAX, ex: [] }],
      ["r", d.clear ? { fixed: 0 } : { name: "r", lean: "(i : Int) % 256", lo: 1, hi: 255, ex: [] }],
      ["b", { name: "b", lean: "((L + i + 1 : Nat) : Int) / 256", lo: d.s === "grow" ? 1 : 0, hi: DMAX, ex: [] }],
      ["s", d.s === "mid" ? { name: "s", lean: "((L + i + 1 : Nat) : Int) % 256", lo: 1, hi: 254, ex: [] }
        : { fixed: d.s === "fill" ? 255 : 0 }],
      ["t", { name: "t", lean: "(T : Int) - i - 3", lo: 0, hi: TMAX - 3, ex: [] }],
      ["tok", { name: "tok", lean: "(t1 : Int)", lo: 0, hi: VOC, ex: [EOS] }]];
    const params = pv.filter(([, v]) => !("fixed" in v)).map(([, v]) => v as RParam);
    const idx = new Map(pv.filter(([, v]) => !("fixed" in v)).map(([n], k) => [n, k]));
    const form = (c: number, terms: [string, number][]): Aff => {
      const cs = Array(params.length).fill(0);
      for (const [n, a] of terms) {
        const v = pv.find(([m]) => m === n)![1];
        if ("fixed" in v) c += a * v.fixed; else cs[idx.get(n)!] += a;
      }
      while (cs.length && cs[cs.length - 1] === 0) cs.pop();
      return aff(c, cs);
    };
    const forms: [Q, Aff][] = [
      ["L", form(-1, [["b", 256], ["s", 1], ["a", -256], ["r", -1]])], ["o", form(0, [["b", 256], ["s", 1]])],
      ["n", aff(1)], ["e", form(1, [["b", 256], ["s", 1]])], ["cap", form(d.s === "grow" ? 0 : 256, [["b", 256]])],
      ["cap1", form(256, [["b", 256]])], ["k", form(0, [["a", 256], ["r", 1]])], ["kp", form(-1, [["a", 256], ["r", 1]])],
      ["T", form(3, [["a", 256], ["r", 1], ["t", 1]])], ["t1", form(0, [["tok", 1]])]];
    decClasses.push({ kind: d.kind, id: `dec_${d.kind}`, row: { id: `dec_${d.kind}.r0`, params, forms, tags: [["kv", d.kv]] } });
  }
}
function decCover(c: DCls): string {
  const r = c.row;
  return `theorem ${c.id}.cover : DecP .${c.kind} ${c.id}.rows := by
  intro L T i t1 h1 hc hs ht hne
  simp only [DecKind.Sel, DecKind.Holds] at hs
  exact ⟨${r.id}, .head _, by row_close [${r.id}, decI], vx [${r.params.map(p => p.lean).join(", ")}],
    by row_close [${r.id}], by row_close [${r.id}, decI]⟩`;
}
function writeDec() {
  let t = readFileSync(join(HERE, "Table.lean"), "utf8").replace(`end ${NS}\n`, "");
  for (const c of decClasses) t += routeRowDef(c.row) + "\n\n" + `def ${c.id}.rows : List Row := [${c.row.id}]\n\n`;
  t += `/-- The decode classes' rows. -/\ndef decTable : List (DecKind × List Row) :=\n  [${decClasses.map(c => `(.${c.kind}, ${c.id}.rows)`).join(",\n   ")}]\n\n`;
  t += `theorem decTable_keys : decTable.map Prod.fst = decKeys := by decide +kernel\n\n`;
  writeFileSync(join(HERE, "Table.lean"), t + `end ${NS}\n`);
  let s = HEADER(["host.sim.lin.Table"], `# The decode classes' covers (generated by \`host/sim/lin/gen.ts table\`)

\`<decode class>.cover\`: every iteration of a decode case (\`decI L T i t1\` where \`DecKind.Sel\` holds) is in
its row. \`dec_cover\`: the decode table's keys are the cases, and every iteration is in a row of its case.`);
  for (const c of decClasses) s += decCover(c) + "\n\n";
  s += `theorem decTable_all : ∀ q ∈ decTable, DecP q.1 q.2 := by\n  unfold decTable\n  exact ` +
    decClasses.map(c => `all_cons (P := DecP) ${c.id}.cover (`).join("\n    ") + "all_nil" + ")".repeat(decClasses.length) + "\n\n";
  s += `/-- **The decode table covers the decode loop's iterations.** -/
theorem dec_cover : decTable.map Prod.fst = decKeys ∧
    ∀ k L T i t1, 1 ≤ L → L + T ≤ 262144 → k.Sel T L i → t1 ≤ 248319 → t1 ≠ 248044 →
      ∃ r ∈ rowsOf decTable k, InRow r (decI L T i t1) := by
  refine ⟨decTable_keys, fun k L T i t1 h1 hc hs ht hne => ?_⟩
  have hmem : k ∈ decTable.map Prod.fst := by rw [decTable_keys]; cases k <;> simp [decKeys]
  exact rowsOf_all (P := DecP) decTable_all k hmem L T i t1 h1 hc hs ht hne

/-- **An oracle checked over its decode case's rows is correct at every iteration of the case**
(\`CasesL\`'s \`good_*L\` over the table's rows). -/
theorem good_valL_dec {k : DecKind} {o : List Ans} (hc : ∀ r ∈ rowsOf decTable k, goodLin r.ps (varsOf r.V decM) o = true)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {L i nx : Nat} (h1 : 1 ≤ L) (hctx : L + T ≤ 262144) (hs : k.Sel T L i)
    (ht : tk (i + 1) ≤ 248319) (hne : tk (i + 1) ≠ 248044) : Good (valL ρ T tk L i nx) o := by
  obtain ⟨r, hr, hin⟩ := dec_cover.2 k L T i (tk (i + 1)) h1 hctx hs ht hne
  exact good_valL_of_row (hc r hr) hin

`;
  writeFileSync(join(HERE, "CoverD.lean"), s + `end ${NS}\n`);
}

function writeRoute() {
  let t = readFileSync(join(HERE, "Table.lean"), "utf8").replace(`end ${NS}\n`, "");
  for (const c of routeClasses) {
    t += c.rows.map(routeRowDef).join("\n\n") + "\n\n";
    t += `def ${c.id}.rows : List Row := [${c.rows.map(r => r.id).join(", ")}]\n\n`;
  }
  t += `/-- The route classes' rows. -/\ndef routeTable : List ((RouteKind × PostClass) × List Row) :=\n  [${routeClasses.map(c => `(${c.lean}, ${c.id}.rows)`).join(",\n   ")}]\n\n`;
  t += `theorem routeTable_keys : routeTable.map Prod.fst = routeKeys := by decide +kernel\n\n`;
  writeFileSync(join(HERE, "Table.lean"), t + `end ${NS}\n`);
  let s = HEADER(["host.sim.lin.Table"], `# The route classes' covers (generated by \`host/sim/lin/gen.ts table\`)

\`<route class>.cover\`: every step of a route position at a post class (\`routeI L T t1 t2\` with the
position's facts \`RouteKind.Holds\`) is in one of its rows. \`route_cover\`: the route table's keys are
the route classes, and every route step is in a row of its class.`);
  for (const c of routeClasses) s += routeCover(c) + "\n\n";
  s += `/-- A route class's rows cover it. -/\ndef RQ (q : RouteKind × PostClass) (rs : List Row) : Prop := RouteP q.1 q.2 rs\n\n`;
  s += `theorem routeTable_all : ∀ q ∈ routeTable, RQ q.1 q.2 := by\n  unfold routeTable\n  exact ` +
    routeClasses.map(c => `all_cons (P := RQ) ${c.id}.cover (`).join("\n    ") + "all_nil" + ")".repeat(routeClasses.length) + "\n\n";
  s += `/-- **The route table covers the route's positions.** -/
theorem route_cover : routeTable.map Prod.fst = routeKeys ∧
    ∀ k L T t1 t2, 1 ≤ L → L ≤ 262143 → k.Holds L T t1 t2 →
      ∃ r ∈ rowsOf routeTable (k, postOf L), InRow r (routeI L T t1 t2) := by
  refine ⟨routeTable_keys, fun k L T t1 t2 h1 h2 hk => ?_⟩
  have hp := (post_cover (L := L)).1
  have hmem : (k, postOf L) ∈ routeTable.map Prod.fst := by
    rw [routeTable_keys]
    simp only [routeKeys, List.mem_flatMap, List.mem_map]
    exact ⟨k, by cases k <;> simp, postOf L, hp, rfl⟩
  exact rowsOf_all (P := RQ) routeTable_all (k, postOf L) hmem L T t1 t2 h1 h2 hk
    (post_cover (L := L)).2.1

`;
  writeFileSync(join(HERE, "CoverR.lean"), s + `end ${NS}\n`);
}

/** The classes' rows and decision trees (both enumeration passes). */
function buildClasses() {
  enumerate(1);
  for (const c of classes) {
    if (c.count === 0) fail(`${c.id}: no steps`);
    c.rows = [...c.rowMap.values()].sort((a, b) => tagKey(a.tags) < tagKey(b.tags) ? -1 : 1);
    c.tree = separate(c, c.rows.map((_, i) => i));
  }
  enumerate(2);
}

/** The prefill rows of a prompt of length `L`: its setup, first step, tail, final step (`enumerate`'s classes,
 * the row by the class's decision tree). The drains' rows are not a route chain's (one per drain index). */
function prefillRowsAt(L: number): string[] {
  const at = (id: string, i: Inst, j = 0) => {
    const c = byId.get(id) ?? fail(`no class ${id}`);
    return rowName(c, walk(c.tree!, c.layout.params.map(p => p.ts(L, j))));
  };
  const C = chunkC(L), d = drains(L), t = tailRows(L), o = L - 1;
  const setup = setupBands.find(b => b.lo <= L && L <= b.hi) ?? fail(`setup class of ${L}`);
  return [at(`setup_${setup.name}`, setupI(L)),
    at(d >= 1 ? `first_drain_${C}` : L >= 2 ? `first_tail_x${rowClass(L - 1)}` : "first_final", firstI(L)),
    ...(d >= 1 && t >= 1 ? [at(`tail_${C}_x${rowClass(t)}_${(d * C) % 256 === 0 ? "g" : "f"}`, tailI(L))] : []),
    at(L === 1 ? "final_cold" : `final_${o % 256 === 0 ? "grow" : o % 256 === 255 ? "fill" : "ord"}`, finalI(L))];
}

function genTable() {
  const t0 = performance.now();
  buildClasses();
  buildRoute();
  buildDec();
  writeTable();
  writeRoute();
  writeDec();
  writeCover();
  writeJson();
  const rows = classes.reduce((s, c) => s + c.rows.length, 0);
  console.log(`${classes.length} classes, ${rows} rows (${((performance.now() - t0) / 1000).toFixed(1)} s)`);
}

/* ---------- Checks ---------- */

/** A piece: a template (one oracle per variant) at some positions (a route position: `route.<kind>`), reading quantity `q` in
 * variable `v` (`vars`); its variant at a row is the row's tag `by`, the class id
 * (`by: "class"`), the row id (`by: "row"`) or a field of the class key (`by: "key.X"`); with `partial` the rows without a
 * variant are not the piece's. `mode`: `lin` (default) or `enum` (the forms read one parameter). */
interface Piece {
  id: string; pos: string[]; vars: [number, Q][]; by: string; variants: Record<string, string>;
  mode?: "lin" | "enum"; partial?: boolean; module: string; imports: string[];
}
interface Spec { doc: string; pieces: Piece[] }

function genChecks(specPath: string, profile: boolean) {
  const spec: Spec = JSON.parse(readFileSync(specPath, "utf8"));
  const tab = JSON.parse(readFileSync(join(HERE, "classes.json"), "utf8"));
  const mods = new Map<string, { imports: Set<string>; thms: string[] }>();
  let n = 0;
  for (const p of spec.pieces) {
    const m = `[${p.vars.map(([v, q]) => `(${v}, .${q})`).join(", ")}]`;
    const mod = mods.get(p.module) ?? { imports: new Set(["host.sim.lin.Table"]), thms: [] };
    mods.set(p.module, mod);
    p.imports.forEach(i => mod.imports.add(i));
    for (const c of tab.classes) {
      if (!p.pos.includes(c.pos === "route" ? `route.${c.key.kind}` : c.pos)) continue;
      for (const r of c.rows) {
        const tag = p.by === "class" ? c.id : p.by === "row" ? r.id : p.by.startsWith("key.") ? String(c.key[p.by.slice(4)]) : r.tags[p.by];
        const O = p.variants[tag];
        if (O === undefined) { if (p.partial) continue; fail(`${p.id}: no variant for ${tag} (${r.id})`); }
        if (p.mode === "enum") {
          const read = new Set(p.vars.flatMap(([, q]) => (r.forms[q]?.cs ?? []).flatMap((a: number, i: number) => (a ? [i] : []))));
          if (read.size > 1) fail(`${p.id}: ${r.id}: the forms read ${read.size} parameters`);
        }
        const chk = p.mode === "enum" ? "goodEnum" : "goodLin";
        mod.thms.push(`theorem ${r.id}.${p.id.replaceAll("__", ".")} : ${chk} ${r.id}.ps (varsOf ${r.id}.V ${m}) (${O}) = true := by decide +kernel`);
        n++;
      }
    }
  }
  for (const [mod, { imports, thms }] of mods) {
    const prof = profile ? "set_option profiler true\nset_option profiler.threshold 0\n\n" : "";
    mkdirSync(dirname(join(PROOFS, `${mod}.lean`)), { recursive: true });
    writeFileSync(join(PROOFS, `${mod}.lean`), HEADER([...imports], spec.doc) + prof + thms.join("\n") + `\n\nend ${NS}\n`);
  }
  console.log(`${n} checks in ${mods.size} modules: ${[...mods.keys()].join(", ")}`);
}

/* ---------- Piece specs from the route chains (A4's `tpl_chain`) ---------- */

/** `spec <out.json> [--enum] <chain>=<case-dir>[@<L> | :<rows>] …`: the check spec of a route chain's pieces, from
 * `$HOST_STREAM_DIR/<chain>/chain.json` (`<chain>` the stream, `Host.Load.Run.Tpl.` prepended if absent): its
 * pieces in order, each glue piece's `glue<k>.json` (its `meta`: `vars`, `oracle`, a slice of the chain's)
 * and each call's instance's `stage.json` (`<instance>/stage.json`: `vars`, `oracle`). The chain's rows: its
 * `row` (a class table row), else the rows given (`:<row>,<row>…`, or `:@<file>` one per line: e.g. the rows of the
 * piece's uses, `compose/chains.json`), else the prefill rows of the prompt length `L` it was run at
 * (`prefillRowsAt`: the setup, the first step, the tail, the final step). A piece (`<chain>.<glue>` or `<chain>.<call>`, the call
 * named `<stage>__<glue k>__<glue k+1>`) has a variant at each row: its oracle, imported from the chain's
 * `States` module (`host.sim.template.<case-dir>.States`, running `tpl_chain`); its positions' other rows are not
 * the chain's (`partial`). A glue piece's derived result variables (`derived`) map to the quantity they equal
 * (`derivedQ`). */
function genSpec(out: string, args: string[]) {
  // `--enum`: the checks by enumeration (`goodEnum`: the rows' forms read one parameter), for oracles outside
  // `goodLin`'s affine fragment (non-integer factors, `ceil` of a quotient)
  const ei = args.indexOf("--enum");
  const mode: "lin" | "enum" = ei >= 0 ? (args.splice(ei, 1), "enum") : "lin";
  const tab = JSON.parse(readFileSync(join(HERE, "classes.json"), "utf8"));
  const rowPos = new Map<string, string>(), rowForms = new Map<string, Record<string, Aff>>();
  for (const c of tab.classes) for (const r of c.rows) {
    rowPos.set(r.id, c.pos === "route" ? `route.${c.key.kind}` : c.pos);
    rowForms.set(r.id, r.forms);
  }
  const qs = new Set(["L", "C", "o", "n", "e", "cap", "cap1", "k", "T", "t1", "t2", "kp"]);
  /** A derived result variable (`glue<k>.json`'s `derived`: `[v, q, "(v<j> add <c>)"]`, the quantity `q` of variable `j`
   * plus `c`) as the quantity whose form is `q`'s plus `c` at every row (e.g. `o + 1` the decode row's `e`). */
  const derivedQ = (rows: string[], q: string, c: number, what: string): Q => {
    const same = (a: Aff, b: Aff) => a.c === b.c + c && JSON.stringify(a.cs) === JSON.stringify(b.cs);
    const hit = [...qs].filter(q2 => rows.every(r => {
      const fs = rowForms.get(r)!;
      return fs[q2] !== undefined && fs[q] !== undefined && same(fs[q2]!, fs[q]!);
    }));
    if (hit.length === 0) fail(`${what}: no quantity is ${q} + ${c} at rows ${rows.join(", ")}`);
    return hit[0] as Q;
  };
  const streams = process.env.HOST_STREAM_DIR ?? join(PROOFS, ".host-stream");
  if (args.some(a => a.includes("@"))) buildClasses();
  const pieces: Piece[] = [];
  for (const a of args) {
    const m = a.match(/^([^=]+)=([^@:]+)(?:@(\d+)|:(.+))?$/) ?? fail(`spec: ${a}: <chain>=<case-dir>[@<L> | :<rows>]`);
    const [, name, dir, Ls, Rs] = m as unknown as [string, string, string, string | undefined, string | undefined];
    const given = Rs === undefined ? undefined : Rs.startsWith("@")
      ? readFileSync(Rs.slice(1), "utf8").split("\n").map(l => l.trim()).filter(l => l) : Rs.split(",");
    const cdir = join(streams, name.startsWith("Host.") ? name : `Host.Load.Run.Tpl.${name}`);
    const chain = JSON.parse(readFileSync(join(cdir, "chain.json"), "utf8"));
    const short = String(chain.chain).split(".").pop()!;
    const rows: string[] = chain.row ? [chain.row] : given ?? (Ls ? prefillRowsAt(+Ls) : fail(`${name}: no row in chain.json; give @<L> or :<rows>`));
    const pos = [...new Set(rows.map(r => rowPos.get(r) ?? fail(`${name}: row ${r} is not in classes.json`)))];
    const imp = `host.sim.template.${dir.replaceAll("/", ".")}.States`;
    const glue: string[] = chain.pieces.filter((p: any) => "glue" in p).map((p: any) => p.glue);
    for (const p of chain.pieces) {
      const isGlue = "glue" in p;
      const meta = JSON.parse(readFileSync(isGlue ? join(cdir, p.meta ?? fail(`${name}: glue ${p.glue} has no meta`))
        : join(streams, p.stage.instance, "stage.json"), "utf8"));
      const call = isGlue ? undefined : (String(p.stage.name).includes("__") ? p.stage.name
        : `${p.stage.name}__${glue[p.stage.site]}__${glue[p.stage.site + 1]}`);
      const what = `${name}: ${isGlue ? p.glue : call}`;
      const vars = (meta.vars as [number, string][]).map(([v, q]) => {
        if (!qs.has(q)) fail(`${what}: variable ${v}: unknown quantity ${q}`);
        return [v, q] as [number, Q];
      });
      for (const [v, q, e] of (meta.derived ?? []) as [number, string, string][]) {
        // an `int32` of an integer below `2 ^ 31` is the integer: its quantity the inner form's
        const ex = e.match(/^int32\((.*)\)$/)?.[1] ?? e;
        const dm = ex.match(/^\(v(\d+) add (-?\d+)\)$/) ?? ex.match(/^v(\d+)$/) ??
          fail(`${what}: derived ${v}: ${e} is not (v<j> add <c>), v<j> or their int32`);
        const base = vars.find(([j]) => j === +dm[1]!) ?? fail(`${what}: derived ${v}: v${dm[1]} is not mapped`);
        if (base[1] !== q) fail(`${what}: derived ${v}: v${dm[1]} holds ${base[1]}, not ${q}`);
        vars.push([v, derivedQ(rows, q, dm[2] === undefined ? 0 : +dm[2], `${what}: derived ${v}`)]);
      }
      pieces.push({ id: `${short}.${isGlue ? p.glue : call}`, pos, vars, by: "row", partial: true, mode,
        variants: Object.fromEntries(rows.map(r => [r, meta.oracle as string])),
        module: `host/sim/lin/checks/chain/${short}`, imports: [imp] });
    }
    console.log(`${short}: ${chain.pieces.length} pieces at rows ${rows.join(", ")}`);
  }
  writeFileSync(out, JSON.stringify({
    doc: "# The route chains' pieces' oracles over the class table's rows (generated by `host/sim/lin/gen.ts spec`, checks by `host/sim/lin/gen.ts checks`)\n\nOne check per (piece, row of its chain): the piece's oracle (a glue piece's slice of the chain's, a call's instance's) over the row's box, its variables the chain's map.",
    pieces }, null, 1) + "\n");
}

const [cmd, arg, flag] = process.argv.slice(2);
if (cmd === "table") genTable();
else if (cmd === "checks" && arg) genChecks(arg, flag === "--profile");
else if (cmd === "spec" && arg) genSpec(arg, process.argv.slice(4));
else if (cmd === "rows" && arg) { buildClasses(); console.log(prefillRowsAt(+arg).join(" ")); }
else fail("usage: gen.ts table | gen.ts checks <spec.json> [--profile] | gen.ts spec <out.json> <chain>=<case-dir>[@<L> | :<rows>] … | gen.ts rows <L>");
