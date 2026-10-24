/** The prefill classes' steps and the route's pieces (gen-plan T8).
 *
 *   bun proofs/host/sim/compose/gen.ts
 *     reads host/sim/lin/classes.json (the class table) and the check specs host/sim/lin/stages.json,
 *     host/sim/lin/plan.json; writes host/sim/compose/{Bundle,ClassA,ClassT1,ClassT2,Route,
 *     RouteBundle,RouteSteps}.lean and chains.json (each row's glue and stage names, for `tpl_chain`'s plans).
 *   bun proofs/host/sim/compose/gen.ts decode --spec host/sim/lin/decode.spec.json <chain>@<kind> …
 *     reads A4's decode chains; writes DecBundle.lean.
 *   bun proofs/host/sim/compose/gen.ts fill --spec host/sim/lin/decode.spec.json --out <file> [--run] <chain>@<kind>:<case-dir>
 *     reads A4's chain modules (host/sim/template/<case-dir>/); writes one decode case's pieces (out of tree).
 *
 * Each row of each class gets its chain of pieces (host.sim.compose.Shape), each piece named by
 * what it depends on: the row's stage tags (`nps`, `kv`, `kv2`), the class's chunk or row band (the
 * dispatch range, the forward body and its family, the prefix's memo warmth), the call site.
 *
 * * The prefill (SETUP, the first step, the drains, the tails, the final step): `Bundle.lean` is the
 *   structure `Pieces F I` (the boundary cuts, the pieces with the oracles of templates not yet
 *   generated and their checks, the length equalities between rows of a class); `Class*.lean`
 *   prove each class's step from its cover and its rows' pieces, discharging the existing stage
 *   templates' oracles with their generated checks (`<row>.nps`, `.chunk`, `.kv`, `.plan`);
 *   `Route.lean` builds `ClassSteps I` and the prefill's reach to its exit cut.
 * * The route pieces (POST, the short budgets' path prefixes, at every post class) are over the
 *   route classes' rows (the budget and tokens 1, 2 as parameters), their oracles checked per row
 *   like the prefill's: `RoutePieces F I T tk` holds each at the run's steps (`RunAt T tk`);
 *   `RouteSteps.lean` composes POST's steps and the paths' prefixes.
 * * The route's artifacts from these bundles (`route_of_pieces`) are `host.sim.compose.Main`'s
 *   (not generated: it reads the bundles only through their composed results).
 *
 * When a piece's template exists, its field is filled by its theorem: only names change. */
import { mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

const HERE = dirname(new URL(import.meta.url).pathname);
const LIN = join(HERE, "../lin");
const NS = "Host.Ts.Sim.Compose";
const fail = (m: string): never => { throw new Error(m); };

const table = JSON.parse(readFileSync(join(LIN, "classes.json"), "utf8"));
const stages = JSON.parse(readFileSync(join(LIN, "stages.json"), "utf8"));
const plan = JSON.parse(readFileSync(join(LIN, "plan.json"), "utf8"));
const piece = (id: string) => stages.pieces.find((p: { id: string }) => p.id === id) ?? fail(`stages.json: no ${id}`);
const npsO = (t: string) => piece("nps").variants[t] ?? fail(`nps ${t}`);
const kvO = (t: string) => piece("kv").variants[t] ?? fail(`kv ${t}`);
const chunkO = (cls: string) => piece("chunk").variants[cls] ?? fail(`chunk ${cls}`);
const planO = (X: number) => plan.pieces[0].variants[String(X)] as string | undefined;

/* ---------- What a step's pieces depend on (gen-plan §1.1, §1.3) ---------- */

// models/qwen/qwen38-27b-trellis-m1max.ts:1073 (aneRanges), :1180 (prompt), :1181 (promptChunk).
const aneTo = [256, 320, 384, 448, 512, 576, 640, 704, 768, 896, 1024, 1280, 1536, 1792, 2048];
/** The forward closure of a tail of row class `X` (`prompt`'s ranges; `V58` fused at 5 rows, folded at 6–8). */
function bodyX(X: number): string {
  if (X <= 4) return ["D1", "V23", "V4", "V58f", "V58d"][X]!;
  if (X <= 21) return "VW";
  return `ane${aneTo[X - 22]}`;
}
/** The dispatch range of a tail of row class `X` (`decode` for one row). */
const dispX = (X: number) => (X === 0 ? "D1" : X <= 2 ? bodyX(X) : X <= 4 ? "V58" : X <= 21 ? "VW" : `A${aneTo[X - 22]}`);
/** A whole chunk's forward closure and dispatch range (`promptChunk`). */
const bodyC = (C: number) => (C <= 128 ? "VW" : `ane${C}`);
const dispC = (C: number) => (C <= 128 ? "cVW" : `cA${C}`);
/** A forward closure's family (the Neural Engine kinds: `aneSmall` 256–512, `aneDense` 576–704,
 * `aneAffine` .353 at 768, .382 from 896). */
function family(b: string): string {
  if (!b.startsWith("ane")) return b.startsWith("V58") ? "V58" : b;
  const n = +b.slice(3);
  return n <= 512 ? "aneSmall" : n <= 704 ? "aneDense" : n === 768 ? "aneAff353" : "aneAff382";
}
/** The final D1 forward's prefix by its source (G15: after a one-row tail the D1 memos may be warm;
 * one class until the pieces show two). */
const finalPrefix: Record<string, string> = { first: "cold", drained: "dcold", tailed: "dcold" };

/* ---------- Bundles of pieces ---------- */

type Kind = "glue" | "stageP" | "stageR" | "fwd";
interface Obl { m: string; O: string; chk: (row: string) => string; enumMode?: boolean }
interface Piece { name: string; kind: Kind; A: string; B: string; mock: boolean; real: Obl[]; uses: string[] }
/** A link of a row's chain: the piece and how its obligations are discharged at the row. */
interface Link { p: Piece; mem: number; obls: string[] }
type Spec = ({ glue: string } | { stage: string; real?: Obl[] } | { fwd: string; real: Obl[] })[];

const MOCK_M = "[(0, .L), (1, .C), (2, .o), (3, .n), (4, .e), (5, .cap), (6, .cap1), (7, .k)]";
const NPS_M = "[(0, .L), (1, .o), (2, .C)]", KV_M = "[(0, .o), (1, .cap), (2, .n)]";
const KV2_M = "[(0, .e), (1, .cap1), (2, .n)]", PLAN_M = "[(0, .n)]", CHUNK_M = "[(0, .L)]";
const ROUTE_M = "[(0, .L), (1, .C), (2, .o), (3, .n), (4, .e), (5, .cap), (6, .cap1), (7, .k), (8, .T), (9, .t1), (10, .t2)]";
const GROUP = 200;

class Bundle {
  pieces = new Map<string, Piece>();
  bounds = new Set<string>();
  eqs: string[] = [];
  /** `route`: route pieces (over route rows, at the run's steps `RunAt T tk`). */
  constructor(readonly var_: string, readonly route: boolean) {}
  get mockM() { return this.route ? ROUTE_M : MOCK_M; }
  groupOf(p: Piece) { return `q${Math.floor([...this.pieces.keys()].indexOf(p.name) / GROUP) + 1}`; }
  at(p: Piece) { return `${this.var_}.${this.groupOf(p)}.${p.name}`; }
  use(name: string, kind: Kind, A: string, B: string, row: string, real: Obl[] = []): Link {
    let p = this.pieces.get(name);
    if (!p) this.pieces.set(name, p = { name, kind, A, B, mock: kind !== "stageR", real, uses: [] });
    if (p.A !== A || p.B !== B || p.kind !== kind) fail(`piece ${name}: used between different cuts`);
    if (JSON.stringify(p.real.map(o => [o.m, o.O])) !== JSON.stringify(real.map(o => [o.m, o.O]))) fail(`piece ${name}: obligations differ`);
    let k = p.uses.indexOf(row);
    if (k < 0) { k = p.uses.length; p.uses.push(row); }
    const mem = k;
    const obls = [
      ...(p.mock ? [`obl_of_row hin (${this.at(p)}.chk _ (mem_at (k := ${k}) rfl))`] : []),
      ...real.map(o => `${o.enumMode ? "obl_of_row_enum" : "obl_of_row"} hin ${o.chk(row)}`),
    ];
    return { p, mem, obls };
  }
  b(n: string) { this.bounds.add(n); return n; }
  /** The chain glue → call → … with the boundary cuts `b_<glue>_i`, `b_<glue>_o` between (the fixed
   * cuts at the chain's ends); a call is named `<stage>__<glue before>__<glue after>`. */
  chain(row: string, start: string, end: string, spec: Spec): Link[] {
    const links: Link[] = [];
    const glueAt = spec.map((s, k) => ("glue" in s ? k : -1)).filter(k => k >= 0);
    for (let k = 0; k < spec.length; k++) {
      const s = spec[k]!;
      if ("glue" in s) {
        const A = k === 0 ? start : this.b(`b_${s.glue}_i`), B = k === spec.length - 1 ? end : this.b(`b_${s.glue}_o`);
        links.push(this.use(s.glue, "glue", A, B, row));
      } else {
        const prev = glueAt.filter(g => g < k).pop(), next = glueAt.find(g => g > k);
        const pg = prev === undefined ? undefined : (spec[prev] as { glue: string }).glue;
        const ng = next === undefined ? fail(`${row}: a call ends the chain`) : (spec[next] as { glue: string }).glue;
        const A = pg === undefined ? start : `b_${pg}_o`, B = `b_${ng}_i`;
        const name = `${"stage" in s ? s.stage : s.fwd}__${pg ?? "start"}__${ng}`;
        const kind: Kind = "fwd" in s ? "fwd" : s.real?.length ? "stageR" : "stageP";
        links.push(this.use(name, kind, A, B, row, ("real" in s ? s.real : undefined) ?? []));
      }
    }
    return links;
  }
  fieldType(p: Piece): string {
    const uses = `[${p.uses.join(", ")}]`;
    const real = `[${p.real.map(o => `⟨${o.m}, ${o.O}⟩`).join(", ")}]`;
    const ends = `(${p.A}) (${p.B})`.replace(/\bb_(\w+)/g, "K.b_$1");
    if (this.route) {
      if (p.kind === "stageR") fail(`route piece ${p.name}: a stage with existing oracles`);
      return p.kind === "glue" ? `RGlue F (RunAt T tk) ${uses} ${ROUTE_M} ${ends}`
        : p.kind === "fwd" ? `RFwd F (RunAt T tk) ${uses} ${ROUTE_M} ${real} ${ends}` : `RStage F (RunAt T tk) ${uses} ${ROUTE_M} ${ends}`;
    }
    if (p.kind === "glue") return `GlueP F ${uses} ${MOCK_M} ${ends}`;
    if (p.kind === "stageP") return `StageP F ${uses} ${MOCK_M} ${ends}`;
    if (p.kind === "stageR") return `StageR F ${uses} ${real} ${ends}`;
    return `FwdP F ${uses} ${MOCK_M} ${real} ${ends}`;
  }
  /** The bundle's structures: `<Cuts>`, the piece groups, `<Eqs>`, and the bundle `name`. */
  structures(name: string, params: string, args: string): string {
    const cuts = `${name}Cuts`, groups = [...new Set([...this.pieces.values()].map(p => this.groupOf(p)))];
    let s = `/-- The boundary cuts between pieces. -/\nstructure ${cuts} (F : Ffi) where\n`;
    for (const bn of [...this.bounds].sort()) s += `  ${bn} : Cls.Inst → ICut F\n`;
    for (const q of groups) {
      s += `\n/-- Pieces (group \`${q}\`). -/\nstructure ${name}_${q} (F : Ffi) (I : PrefInvsW F) ${params} (K : ${cuts} F) where\n`;
      for (const p of this.pieces.values()) if (this.groupOf(p) === q) s += `  ${p.name} : ${this.fieldType(p)}\n`;
    }
    s += `\n/-- The length equalities between the rows of a class. -/\nstructure ${name}Eqs (F : Ffi) (I : PrefInvsW F) ${params} (K : ${cuts} F) ${groups.map(q => `(${q} : ${name}_${q} F I ${args} K)`).join(" ")} where\n`;
    s += this.eqs.join("\n") + (this.eqs.length ? "\n" : "  trivial : True\n");
    s += `\n/-- **The pieces.** -/\nstructure ${name} (F : Ffi) (I : PrefInvsW F) ${params} where\n  cuts : ${cuts} F\n`;
    for (const q of groups) s += `  ${q} : ${name}_${q} F I ${args} cuts\n`;
    s += `  eqs : ${name}Eqs F I ${args} cuts ${groups.join(" ")}\n`;
    return s;
  }
}

/* ---------- The rows' chains ---------- */

interface RowChain { row: string; shape: "setup" | "step" | "final" | "post" | "pre" | "preDec" | "preDec2"; links: Link[] }
interface ClassChains { cls: any; src?: string; kind?: string; rows: RowChain[] }

const npsObl = (t: string): Obl => ({ m: NPS_M, O: npsO(t), chk: r => `${r}.nps` });
const kvObl = (t: string): Obl => ({ m: KV_M, O: kvO(t), chk: r => `${r}.kv` });
const kv2Obl = (t: string): Obl => ({ m: KV2_M, O: kvO(t), chk: r => `${r}.kv2` });
function fwdReal(row: any, cls: any, kvTag: string, body: string): Obl[] {
  const o = [kvObl(kvTag)];
  if (body === "VW") {
    const X = cls.key.X as number;
    const O = planO(X) ?? fail(`${row.id}: no plan variant for X = ${X}`);
    o.push({ m: PLAN_M, O, chk: r => `${r}.plan`, enumMode: true });
  }
  return o;
}

const PB = new Bundle("P", false), RB = new Bundle("H", true);
const out: ClassChains[] = [];
for (const c of table.classes) {
  if (c.pos === "setup") {
    const K = chunkO(c.id).split(".")[2];
    out.push({ cls: c, rows: c.rows.map((r: any) => ({ row: r.id, shape: "setup", links: PB.chain(r.id, "fun i => I.ld i.L", "fun i => I.pc0 i.L", [
      { glue: "g0a" }, { stage: `chunk_${K}`, real: [{ m: CHUNK_M, O: chunkO(c.id), chk: (x: string) => `${x}.chunk` }] }, { glue: "g0b" }]) })) });
  } else if (c.pos === "first" && c.key.kind === "final") {
    // L = 1: the final step from the first call
  } else if (c.pos === "first" || c.pos === "drain" || c.pos === "tail") {
    const site = c.pos === "first" ? "first" : "later";
    const start = c.pos === "first" ? "fun i => I.pc0 i.L" : "fun i => I.pc i.L i.k";
    const toPf = c.pos === "tail" || (c.pos === "first" && c.key.kind === "tail");
    const end = toPf ? "fun i => I.pf i.L" : "fun i => I.pc i.L (i.k + 1)";
    const C = c.key.C as number | undefined;
    const body = toPf ? bodyX(c.key.X) : bodyC(C!);
    const disp = toPf ? dispX(c.key.X) : dispC(C!);
    const prefix = c.pos === "first" ? "cold" : c.pos === "drain" ? "warm" : family(body) === family(bodyC(C!)) ? "warm" : "dcold";
    out.push({ cls: c, rows: c.rows.map((r: any) => ({ row: r.id, shape: "step", links: PB.chain(r.id, start, end, [
      { stage: `nps_${r.tags.nps}_${site}`, real: [npsObl(r.tags.nps)] }, { glue: `g1_${r.tags.nps}_${site}` },
      { stage: `disp_${disp}` }, { glue: `g2_${site}` },
      { fwd: `fwd_${body}_${prefix}_${r.tags.kv}${body === "VW" ? `_p${c.key.X}` : ""}`, real: fwdReal(r, c, r.tags.kv, body) },
      { glue: `g3d_${site}` }, { stage: "eval" }, { glue: `g4_${toPf ? "pf" : "pc"}_${site}` }]) })) });
  } else if (c.pos === "final") {
    for (const src of c.key.kind === "cold" ? ["first"] : ["drained", "tailed"]) {
      const start = src === "first" ? "fun i => I.pc0 i.L" : src === "drained" ? "fun i => I.pc i.L i.k" : "fun i => I.pf i.L";
      out.push({ cls: c, src, rows: c.rows.map((r: any) => ({ row: r.id, shape: "final", links: PB.chain(r.id, start, "fun i => I.ps i.L", [
        { stage: `nps_FIN_${src}`, real: [npsObl(r.tags.nps)] }, { glue: `g1_FIN_${src}` }, { stage: "disp_D1" },
        { glue: `g2_fin_${src}` }, { fwd: `fwd_D1_${finalPrefix[src]}_${r.tags.kv}`, real: [kvObl(r.tags.kv)] },
        { glue: `g3f_${src}` }]) })) });
    }
  } else if (c.pos === "post") {
    // the prefill table's post classes: the route classes below are POST's, with the budget and the tokens
  } else if (c.pos === "route") {
    // POST: from the exit cut through the head, the cold sample, the decode rows at `L` and `L + 1`.
    // The short budgets' paths' prefixes to their cuts: `pathA` (token 1 EOS, a decode row), `pathB`
    // (T = 2, a decode row and the readback of token 2), `pathC` (T = 1, no decode row).
    const k = c.key.kind as string, ab = ({ post: "post", pathA: "pA", pathB: "pB", pathC: "pC" } as Record<string, string>)[k]!;
    const pre: Spec = [{ glue: `${ab}_g5` }, { stage: "head" }, { glue: `${ab}_g6` }, { stage: "smp_cold" },
      { glue: `${ab}_g7` }, { stage: "async" }, { glue: `${ab}_g8` }];
    const row = (j: string, kv: string, obl: Obl): Spec => [{ stage: "rb" }, { glue: `${ab}_g9${j}` },
      { fwd: `fwd_D1_warm_${kv}`, real: [obl] }, { glue: `${ab}_g10${j}` }, { stage: "smp_warm" }, { glue: `${ab}_g11${j}` },
      { stage: "async" }, { glue: `${ab}_g12${j}` }];
    const spec = (r: any): Spec => k === "post" ? [...pre, ...row("_0", r.tags.kv, kvObl(r.tags.kv)), ...row("_1", r.tags.kv2, kv2Obl(r.tags.kv2))]
      : k === "pathA" ? [...pre, ...row("", r.tags.kv, kvObl(r.tags.kv))]
      : k === "pathB" ? [...pre, ...row("", r.tags.kv, kvObl(r.tags.kv)), { stage: "rb" }, { glue: "pB_g13" }] : pre;
    const shape = ({ post: "post", pathA: "preDec", pathB: "preDec2", pathC: "pre" } as Record<string, RowChain["shape"]>)[k]!;
    const end = k === "post" ? "fun i => I.dec i.L" : `fun i => ${RB.b(`b_${ab}_cut`)} i`;
    out.push({ cls: c, kind: k, rows: c.rows.map((r: any) => ({ row: r.id, shape, links: RB.chain(r.id, "fun i => I.ps i.L", end, spec(r)) })) });
  } else if (c.pos === "dec") {
    // the decode cases: their chains (links, compactions) come with the regenerated decode templates
  } else fail(`class ${c.id}: unknown position`);
}

/* ---------- Lean: the chains ---------- */

function lensOf(bd: Bundle, rc: RowChain): string {
  const lens = (l: Link) => (l.p.kind === "fwd" ? [`${bd.at(l.p)}.np`, `${bd.at(l.p)}.nb`] : [`${bd.at(l.p)}.n`]);
  const ns = rc.links.flatMap(lens);
  const pre = rc.links.slice(0, 7).flatMap(lens), dec = (a: number, b: number) => `⟨${rc.links.slice(a, b).flatMap(lens).join(", ")}⟩`;
  switch (rc.shape) {
    case "setup": return `(⟨${ns.join(", ")}⟩ : SetupLens).total`;
    case "step": return `(⟨${ns.join(", ")}⟩ : StepLens).total`;
    case "final": return `(⟨${[...ns, "0", "0"].join(", ")}⟩ : StepLens).final`;
    case "post": return `(⟨${[...pre, dec(7, 15), dec(15, 23)].join(", ")}⟩ : PostLens).total`;
    case "pre": return `(⟨${pre.join(", ")}⟩ : PreLens).total`;
    case "preDec": return `((⟨${pre.join(", ")}⟩ : PreLens).total + (${dec(7, 15)} : DecLens).total)`;
    case "preDec2": return `((⟨${pre.join(", ")}⟩ : PreLens).total + (${dec(7, 15)} : DecLens).total + (${rc.links.slice(15).flatMap(lens).join(" + ")}))`;
  }
}

function rowProof(bd: Bundle, rc: RowChain): string {
  const ls = rc.links.map(l => `(${bd.at(l.p)}.ok _ (mem_at (k := ${l.mem}) rfl) _ hin ${l.obls.length ? `⟨${[...l.obls, "trivial"].join(", ")}⟩` : "trivial"}${bd.route ? " hadm" : ""})`);
  const head = (k: number) => `pre_shape ${ls.slice(0, 7).join("\n        ")}`;
  switch (rc.shape) {
    case "post": return `post_shape ${ls.slice(0, 7).join("\n        ")}\n        (dec_shape ${ls.slice(7, 15).join(" ")})\n        (dec_shape ${ls.slice(15).join(" ")})`;
    case "pre": return head(7);
    case "preDec": return `(${head(7)}).trans\n        (dec_shape ${ls.slice(7, 15).join(" ")})`;
    case "preDec2": return `((${head(7)}).trans\n        (dec_shape ${ls.slice(7, 15).join(" ")})).trans\n        (${ls[15]}.step.trans ${ls[16]})`;
    default: return `${rc.shape === "setup" ? "setup_shape" : rc.shape === "step" ? "step_shape" : "final_shape"} ${ls.join("\n        ")}`;
  }
}

const thmName = (cc: ClassChains) => `${cc.cls.id}${cc.src ? `_${cc.src}` : ""}`;
const posPred: Record<string, string> = { setup: "SetupS", drain: "DrainS", tail: "TailS", final: "FinalS" };
const ofRows: Record<string, string> = { setup: "setupS_of_rows", drain: "drainS_of_rows", tail: "tailS_of_rows", final: "finalS_of_rows" };
/** A route position's end: POST's decode cut, a path's cut. */
const routeEnd = (k: string, V: string) => (k === "post" ? "fun i => I.dec i.L" : `fun i => ${V}.cuts.b_${({ pathA: "pA", pathB: "pB", pathC: "pC" } as Record<string, string>)[k]}_cut i`);

function classTheorem(bd: Bundle, cc: ClassChains, bundleT: string): string {
  const c = cc.cls, id = thmName(cc), V = bd.var_;
  let pred: string, rule: string, binders: string;
  if (cc.kind) {
    pred = `RouteS I T tk .${cc.kind} (${routeEnd(cc.kind, V)}) .${c.key.post}`; rule = "routeS_of_rows";
    binders = "fun r hr L h1 h2 hq ha hin hadm => by";
  } else if (c.pos === "first") {
    pred = c.key.kind === "drain" ? `FirstDrainS I ${c.key.C}` : `FirstTailS I ${c.key.X}`;
    rule = c.key.kind === "drain" ? "firstDrainS_of_rows" : "firstTailS_of_rows";
    binders = "fun r hr L h1 h2 ha hin => by";
  } else if (c.pos === "drain") {
    pred = `DrainS I (${c.lean})`; rule = ofRows.drain!; binders = "fun r hr L j h1 h2 ha hin => by";
  } else if (c.pos === "final") {
    pred = `FinalS I .${cc.src} (${c.lean})`; rule = ofRows.final!; binders = "fun r hr L h1 h2 ha hs hin => by";
  } else {
    pred = `${posPred[c.pos]} I (${c.lean})`; rule = ofRows[c.pos]!; binders = "fun r hr L h1 h2 ha hin => by";
  }
  const total0 = lensOf(bd, cc.rows[0]!);
  let s = `/-- ${cc.kind ?? c.pos} class \`${c.id}\`${cc.src ? ` from the ${cc.src} source` : ""}: the step from its rows' pieces. -/\n`;
  s += `def ${id}.total (${V} : ${bundleT}) : Nat := ${total0}\n\n`;
  s += `theorem ${id}.steps (${V} : ${bundleT}) : ${pred} (${id}.total ${V}) :=\n  ${rule} ${c.cover} ${binders}\n`;
  s += `    simp only [${c.id}.rows, List.mem_cons, List.not_mem_nil, or_false] at hr\n`;
  s += `    rcases hr with ${cc.rows.map(() => "rfl").join(" | ")}\n`;
  cc.rows.forEach((rc, k) => {
    const tot = lensOf(bd, rc), same = tot === total0;
    if (!same) bd.eqs.push(`  /-- The rows of \`${id}\` take the same number of steps. -/\n  eq_${id}_r${k} : ${total0.replaceAll(`${V}.`, "")} = ${tot.replaceAll(`${V}.`, "")}`);
    s += `    · exact ${same ? "" : "("}${rowProof(bd, rc)}${same ? "" : `).cast rfl rfl ${V}.eqs.eq_${id}_r${k}`}\n`;
  });
  return s;
}

const HEADER = (imports: string[], doc: string) =>
  `${imports.map(i => `import ${i}`).join("\n")}\nset_option maxRecDepth 100000\nset_option maxHeartbeats 1000000\nnamespace ${NS}\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls\n\n/-! ${doc} -/\n\n`;
const sect = (vars: string, body: string) => `section\nvariable ${vars}\n\n${body}end\n`;

/* ---------- The prefill ---------- */

const pre = out.filter(cc => !cc.kind);
const groups: [string, (cc: ClassChains) => boolean][] = [
  ["ClassA", cc => cc.cls.pos !== "tail"],
  ["ClassT1", cc => cc.cls.pos === "tail" && cc.cls.key.C >= 1024],
  ["ClassT2", cc => cc.cls.pos === "tail" && cc.cls.key.C < 1024],
];
const classMods = groups.map(([mod, sel]) =>
  [mod, sect("{F : Ffi} {I : PrefInvsW F}", pre.filter(sel).map(cc => classTheorem(PB, cc, "Pieces F I") + "\n").join(""))] as const);
writeFileSync(join(HERE, "Bundle.lean"), HEADER(["host.sim.compose.Steps", "host.sim.lin.Cover", "host.sim.lin.checks.Nps",
  "host.sim.lin.checks.Kv", "host.sim.lin.checks.Chunk", "host.sim.lin.checks.Plan"],
`# The pieces of the prefill classes (generated by \`host/sim/compose/gen.ts\`)

\`Pieces F I\`: the boundary cuts between pieces (\`b_<glue>_i\`, \`b_<glue>_o\`), every piece the
classes' rows use (\`host.sim.compose.Shape\`: \`GlueP\`, \`StageP\`, \`StageR\`, \`FwdP\`, each over the
rows that use it; a call is named \`<stage>__<glue before>__<glue after>\`), and the length
equalities between the rows of a class. A field is filled by the piece's theorem once its template
exists (tpl_chain, A3's conversions); the stage templates' oracles are the existing ones
(\`host.sim.stage\`), checked per row (\`host.sim.lin.checks\`).`) + PB.structures("Pieces", "", "") + `\nend ${NS}\n`);
for (const [mod, s] of classMods)
  writeFileSync(join(HERE, `${mod}.lean`), HEADER(["host.sim.compose.Bundle"],
    `# The prefill classes' steps from their pieces (generated by \`host/sim/compose/gen.ts\`)

\`<class>.steps P\`: the class's step at every length where it applies, from its cover (the row of
each step) and, in each row, the row's chain of pieces (\`setup_shape\`, \`step_shape\`,
\`final_shape\`) with the oracles discharged by the row's checks.`) + s + `\nend ${NS}\n`);

const byPos = (pos: string, pred: (cc: ClassChains) => boolean = () => true) => pre.filter(cc => cc.cls.pos === pos && pred(cc));
const chainAll = (cs: ClassChains[], arg: string) => cs.map(cc => `all_cons' (${thmName(cc)}.steps ${arg}) (`).join("\n      ") + "all_nil'" + ")".repeat(cs.length);
const ktype: Record<string, string> = { setup: "SetupClass", drain: "DrainClass", tail: "TailClass", post: "PostClass" };
const keyOf = (cc: ClassChains) => (cc.kind ? `PostClass.${cc.cls.key.post}` : `(${cc.cls.lean} : ${ktype[cc.cls.pos]})`);
const countList = (cs: ClassChains[], key: (cc: ClassChains) => string, arg: string) => `[${cs.map(cc => `(${key(cc)}, ${thmName(cc)}.total ${arg})`).join(", ")}]`;
const fd = byPos("first", cc => cc.cls.key.kind === "drain"), ft = byPos("first", cc => cc.cls.key.kind === "tail");
const fin = byPos("final");
const finalCase = (kv: string | null, src: string) => {
  const cc = fin.find(x => (kv ? x.cls.key.kv === kv : x.cls.key.kind === "cold") && x.src === src);
  if (cc) return `${thmName(cc)}.steps P`;
  return kv ? `FinalS.warm_first _ _` : `FinalS.cold_of_ne (by decide) _`;
};
writeFileSync(join(HERE, "Route.lean"), HEADER(["host.sim.compose.ClassA", "host.sim.compose.ClassT1", "host.sim.compose.ClassT2"],
`# The prefill from the classes' pieces (generated by \`host/sim/compose/gen.ts\`)

\`classSteps P\`: the classes' steps (\`ClassSteps\`); \`reach_of_pieces\`: the prefill from the
loadDone cut to the exit cut at every \`1 ≤ L ≤ 262143\`.`) + `theorem tailClasses_lit : tailClasses = [${byPos("tail").map(cc => cc.cls.lean).join(", ")}] := by decide +kernel
theorem range37 : List.range 37 = [${[...Array(37).keys()].join(", ")}] := by decide +kernel

` + sect("{F : Ffi} {I : PrefInvsW F}", `/-- **The classes' steps from the pieces.** -/
def classSteps (P : Pieces F I) : ClassSteps I where
  nSetup := countOf ${countList(byPos("setup"), keyOf, "P")}
  setup := by
    unfold setupClasses
    exact ${chainAll(byPos("setup"), "P")}
  nFirstDrain := countOf ${countList(fd, cc => String(cc.cls.key.C), "P")}
  firstDrain := by
    unfold chunkSizes
    exact ${chainAll(fd, "P")}
  nFirstTail := countOf ${countList(ft, cc => String(cc.cls.key.X), "P")}
  firstTail := by
    rw [range37]
    exact ${chainAll(ft, "P")}
  nDrain := countOf ${countList(byPos("drain"), keyOf, "P")}
  drain := by
    unfold drainClasses
    exact ${chainAll(byPos("drain"), "P")}
  nTail := countOf ${countList(byPos("tail"), keyOf, "P")}
  tail := by
    rw [tailClasses_lit]
    exact ${chainAll(byPos("tail"), "P")}
  nFinal src c := countOf ${countList(fin, cc => `((PFSrc.${cc.src}, FinalClass${cc.cls.lean}) : PFSrc × FinalClass)`, "P")} (src, c)
  final := by
    unfold finalClasses
    refine all_cons' ?_ (all_cons' ?_ (all_cons' ?_ (all_cons' ?_ all_nil'))) <;> intro src <;> cases src
${["null", "ord", "fill", "grow"].flatMap(kv => ["first", "drained", "tailed"].map(src => `    · exact ${finalCase(kv === "null" ? null : kv, src)}`)).join("\n")}

/-- **The prefill from its pieces**: from the loadDone cut to the exit cut at every length of the range. -/
theorem reach_of_pieces (P : Pieces F I) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    CutStep (I.ld L) (I.ps L) ((classSteps P).toPrefSteps.n L) :=
  (classSteps P).reach h1 h2

`) + `\nend ${NS}\n`);

/* ---------- The route pieces ---------- */

const routeT = "RoutePieces F I T tk";
const routeCs = out.filter(cc => cc.kind);
let rsteps = "";
for (const cc of routeCs) rsteps += classTheorem(RB, cc, routeT) + "\n";
writeFileSync(join(HERE, "RouteBundle.lean"), HEADER(["host.sim.compose.Route", "host.sim.lin.CoverR"],
`# The route pieces (generated by \`host/sim/compose/gen.ts\`)

\`RoutePieces F I T tk\`: POST's pieces and the short budgets' paths' prefixes to their cuts
\`b_pA_cut\`, \`b_pB_cut\`, \`b_pC_cut\`, each over the route classes' rows that use it
(\`host.sim.lin.CoverR\`; \`host.sim.compose.Shape\`: \`RGlue\`, \`RStage\`, \`RFwd\`) with its oracle and
its checks, at the steps of the run at budget \`T\` with tokens \`tk\` (\`RunAt T tk\`); the KV append's
oracle at the step's offset is discharged by the rows' checks.`) +
  RB.structures("RoutePieces", "(T : Nat) (tk : Nat → Nat)", "T tk") + `\nend ${NS}\n`);
const post = routeCs.filter(cc => cc.kind === "post");
const pathCs = (k: string) => routeCs.filter(cc => cc.kind === k);
writeFileSync(join(HERE, "RouteSteps.lean"), HEADER(["host.sim.compose.RouteBundle"],
`# POST and the short paths' prefixes from the route pieces (generated by \`host/sim/compose/gen.ts\`)

\`route_post_<class>.steps H\`: POST's step at every length of the post class where POST's facts
hold (\`post_shape\`); \`route_path<A|B|C>_<class>.steps H\`: a short path's prefix to its cut.
\`postN\`, \`postStep\`: POST at every length of the range; \`path*Pre\`: a path's prefix at every
length.`) + sect("{F : Ffi} {I : PrefInvsW F} {T : Nat} {tk : Nat → Nat}",
  rsteps + `/-- POST's count by class. -/
def postN (H : ${routeT}) : PostClass → Nat := countOf ${countList(post, keyOf, "H")}

/-- **POST at every length of the range.** -/
theorem postStep (H : ${routeT}) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) (hq : RouteKind.post.Holds L T (tk 1) (tk 2)) :
    CutStep (I.ps L) (I.dec L) (postN H (postOf L)) := by
  have hall : ∀ c ∈ postClasses, RouteS I T tk .post (${routeEnd("post", "H")}) c (postN H c) := by
    unfold postClasses
    exact ${chainAll(post, "H")}
  have hc := post_cover (L := L)
  exact hall _ hc.1 L h1 h2 hq hc.2.1

${["pathA", "pathB", "pathC"].map(k => {
  const cut = k === "pathA" ? "b_pA_cut" : k === "pathB" ? "b_pB_cut" : "b_pC_cut";
  const cs = pathCs(k);
  return `/-- The ${k} prefix's count by post class. -/
def ${k}N (H : ${routeT}) : PostClass → Nat := countOf ${countList(cs, keyOf, "H")}

/-- **The ${k} prefix at every length of the range.** -/
theorem ${k}Pre (H : ${routeT}) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) (hq : RouteKind.${k}.Holds L T (tk 1) (tk 2)) :
    CutStep (I.ps L) (H.cuts.${cut} (routeI L T (tk 1) (tk 2))) (${k}N H (postOf L)) := by
  have hall : ∀ c ∈ postClasses, RouteS I T tk .${k} (${routeEnd(k, "H")}) c (${k}N H c) := by
    unfold postClasses
    exact ${chainAll(cs, "H")}
  have hc := post_cover (L := L)
  exact hall _ hc.1 L h1 h2 hq hc.2.1
`;
}).join("\n")}`) + `\nend ${NS}\n`);

/* ---------- The rows' chains for the template generation ---------- */

// `chains.json`: per row (a final row per source: `<row>@<src>`), its chain's glue pieces and stage calls in
// order, the names `tpl_chain`'s plan takes (`glue`, each stage's `name`): call `k` is
// `<stage>__<glue k>__<glue k+1>` (a forward call's `<stage>` is `fwd_…`); a chain from a call has the glue
// `start` first (the empty segment before it: `Bundle.chain`'s `<stage>__start__<glue>`).
const chainsOut: Record<string, { glue: string[]; stages: string[] }> = {};
for (const cc of out)
  for (const rc of cc.rows)
    chainsOut[`${rc.row}${cc.src ? `@${cc.src}` : ""}`] = {
      glue: [...(rc.links[0]!.p.kind === "glue" ? [] : ["start"]), ...rc.links.filter(l => l.p.kind === "glue").map(l => l.p.name)],
      stages: rc.links.filter(l => l.p.kind !== "glue").map(l => l.p.name.split("__")[0]!),
    };
writeFileSync(join(HERE, "chains.json"), JSON.stringify(chainsOut, null, 1) + "\n");

const nP = PB.pieces.size, nR = RB.pieces.size;
console.log(`${pre.length} prefill class steps, ${routeCs.length} route chains; ${nP} prefill pieces, ${PB.bounds.size} cuts, ${PB.eqs.length} equalities; ${nR} route pieces, ${RB.bounds.size} cuts, ${RB.eqs.length} equalities`);

/* ---------- The decode cases' pieces from their route chains ---------- */

/** `bun gen.ts decode [--out <file>] --spec <spec.json> <chain>@<kind> …`: the decode cases' bundles (`DecBundle.lean`) from A4's
 * decode chains (`$HOST_STREAM_DIR/Host.Load.Run.Tpl.<chain>/chain.json`, `tpl_chain`'s order: glue piece 0,
 * call 0, glue piece 1, …). Per chain, at decode case `<kind>` (its rows `dec_<kind>.rows`,
 * `host.sim.lin.CoverD`): `DecPieces_<chain>`, the cuts between the links (at the iteration's step
 * `decI` and its start pair) and each link a `DLink` over the case's rows at its variables (the chains' spec,
 * `host/sim/lin/gen.ts spec`: the template's map and the derived results; a glue piece's oracle its
 * `glue<k>.json`'s, a call's its instance's `stage.json`'s; their checks `host/sim/lin/gen.ts spec`);
 * `DecPieces_<chain>.chain`, the case's `IterChainW` (`DLink.link` per link at the case's cover). */
function genDecode(args: string[]) {
  const oi = args.indexOf("--out");
  const outFile = oi >= 0 ? args.splice(oi, 2)[1]! : join(HERE, "DecBundle.lean");
  const si = args.indexOf("--spec");
  if (si < 0) fail("decode: --spec <spec.json> (host/sim/lin/gen.ts spec of the chains)");
  const spec = JSON.parse(readFileSync(args.splice(si, 2)[1]!, "utf8"));
  const varsOf = new Map<string, string>(spec.pieces.map((p: any) =>
    [p.id, `[${p.vars.map(([v, q]: [number, string]) => `(${v}, .${q})`).join(", ")}]`]));
  const streams = process.env.HOST_STREAM_DIR ?? join(HERE, "../../../.host-stream");
  const kinds = new Set(["ord", "clear", "grow", "fill", "clearFill", "clearGrow"]);
  const P = "Wd A W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN";
  let s = HEADER(["host.sim.compose.DecRows"], `# The decode cases' pieces (generated by \`host/sim/compose/gen.ts decode\` from A4's decode chains)

\`DecPieces_<chain>\`: a decode case's chain (\`chain.json\`'s pieces in order) as links over the case's rows
(\`DLink\`, \`host.sim.compose.DecRows\`) between the cuts \`c<k>\`; \`DecPieces_<chain>.chain\`: the case's chain of
cut steps (\`IterChainW\`) at every iteration of the case.`);
  s += `section\nvariable {Wd : World} {A : Addr} {W : Nat → Option WFrame} {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S}
  {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat}\n\n`;
  for (const a of args) {
    const [name, kind] = a.split("@");
    if (!name || !kind || !kinds.has(kind)) fail(`decode: ${a}: <chain>@<kind>`);
    const chain = JSON.parse(readFileSync(join(streams, name.startsWith("Host.") ? name : `Host.Load.Run.Tpl.${name}`, "chain.json"), "utf8"));
    const short = String(chain.chain).split(".").pop()!;
    if (chain.row && chain.row !== `dec_${kind}.r0`) fail(`${short}: row ${chain.row} is not case ${kind}'s`);
    const glue: string[] = chain.pieces.filter((p: any) => "glue" in p).map((p: any) => p.glue);
    const links: string[] = chain.pieces.map((p: any) => "glue" in p ? p.glue
      : String(p.stage.name).includes("__") ? p.stage.name : `${p.stage.name}__${glue[p.stage.site]}__${glue[p.stage.site + 1]}`);
    if (!("glue" in chain.pieces[0]) || !("glue" in chain.pieces[chain.pieces.length - 1])) fail(`${short}: a chain from glue to glue`);
    const m = links.length - 1, rows = `dec_${kind}.rows`, T = `DecPieces_${short}`;
    const cut = (k: number) => k === 0 ? `(fun i x0 => iterGhostW ${P} e.θ i.k x0)`
      : k === m + 1 ? `(fun i x0 => iterEndCW Wd A W P Fr s0 tab0 fixA toks e g i.k x0)` : `c${k}`;
    s += `variable (Wd A W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) in\n`;
    s += `/-- **Decode case \`${kind}\`'s pieces** from chain \`${short}\` (${links.length} links). -/\n`;
    s += `structure ${T} (L T : Nat) (e : IterEndW Wd A P s0 tab0 fixA) (g : GhostP) where\n`;
    for (let k = 1; k <= m; k++) s += `  c${k} : Cls.Inst → SegInst Wd.F → ICut Wd.F\n`;
    links.forEach((l, k) => {
      const m = varsOf.get(`${short}.${l}`) ?? fail(`${short}: ${l} is not in the spec`);
      s += `  ${l} : DLink (DecAt L T tk) ${rows} ${m} [] ${cut(k)} ${cut(k + 1)}\n`;
    });
    s += `\n/-- **Decode case \`${kind}\`'s chain** from chain \`${short}\`'s pieces. -/\n`;
    s += `def ${T}.chain {L T : Nat} {e : IterEndW Wd A P s0 tab0 fixA} {g : GhostP} (D : ${T} ${P} L T e g)\n`;
    s += `    (h1 : 1 ≤ L) (hctx : L + T ≤ 262144) : IterChainW ${P} e g (DecSel T L tk .${kind}) where\n`;
    s += `  cuts := [${[...Array(m).keys()].map(k => `fun i x0 => D.c${k + 1} (decI L T i (tk (i + 1))) x0`).join(",\n    ")}]\n`;
    s += `  lens := [${links.map(l => `D.${l}.n`).join(", ")}]\n`;
    s += `  links i x0 hs := ⟨${links.map(l => `D.${l}.link ${`dec_${kind}`}.cover (fun _ h => h) (fun _ _ _ _ => trivial) h1 hctx i x0 hs`).join(",\n    ")}⟩\n\n`;
  }
  s += `end\n\nend ${NS}\n`;
  writeFileSync(outFile, s);
  console.log(`${args.length} decode chains: ${outFile}`);
}

if (process.argv[2] === "decode") genDecode(process.argv.slice(3));


/* ---------- A decode case's pieces from A4's chain modules ---------- */

/** `bun gen.ts fill --spec <spec.json> --out <file> [--run] <chain>@<kind>:<case-dir>`: decode case `<kind>`'s
 * pieces `DecPieces_<chain>` from A4's chain modules (`host/sim/template/<case-dir>/`), out of tree (it imports
 * A4's unregistered modules), in the decode world with the target's bridge pinned to `b0` (`fullWorldFb b0`). The
 * cuts are `bdCut` (`host.sim.compose.ChainFill`) at the calls' states and the
 * compactions' canonical states, each at the variables known there (the glue piece's before it), the ghost at
 * the compactions before them (`<chain>.g<j>`); the start link `startLink`, the glue links
 * `glueLinkCall`/`glueLinkEnd` from A4's runs (`<chain>.Runs`: `Run`'s `runSeg<k>`, the `K<j>`'s `stepA<j>`; with
 * `--run`, `<chain>.runs` from those modules), the boundary facts (kernel checks here) and the pinned world's growth
 * (`<chain>.Grow`, A1's); the call links `callLink` (`host.sim.compose.CallLink`) from each call's facts
 * (`<chain>.Call<j>`, by owner) and the counters and band checked here; the case's `IterCaseW` from the end facts
 * (`<chain>.End`, A4's in the full world at the prompt route's instance: `<chain>.EndAt`, moved by `IterEndW.toFb`),
 * the emitted token (`<chain>.emitTok`) and the counters (`<chain>.within`). A
 * glue piece's oracle is its start server's (`List.drop o X.O`): every later glue piece consumes no answers. */
function genFill(args: string[]) {
  const take = (flag: string) => {
    const i = args.indexOf(flag);
    return i < 0 ? undefined : args.splice(i, 2)[1];
  };
  const outFile = take("--out") ?? fail("fill: --out <file>");
  const spec = JSON.parse(readFileSync(take("--spec") ?? fail("fill: --spec <spec.json>"), "utf8"));
  const ri = args.indexOf("--run");
  const withRun = ri >= 0;
  if (withRun) args.splice(ri, 1);
  const mm = (args[0] ?? "").match(/^([^@]+)@([^:]+):(.+)$/) ?? fail("fill: <chain>@<kind>:<case-dir>");
  const [, name, kind, dir] = mm as unknown as [string, string, string, string];
  const streams = process.env.HOST_STREAM_DIR ?? join(HERE, "../../../.host-stream");
  const sdir = join(streams, name.startsWith("Host.") ? name : `Host.Load.Run.Tpl.${name}`);
  const chain = JSON.parse(readFileSync(join(sdir, "chain.json"), "utf8"));
  const seg = JSON.parse(readFileSync(join(sdir, "seg.json"), "utf8"));
  const X = String(chain.chain).split(".").pop()!;
  const C = `Host.Load.Run.Tpl.${X}`;
  const c = (n: string) => `${C}.${n}`;
  const tdir = join(HERE, "../template", dir);
  // the iteration's template start: the chain's start (the decode template's with the loop's token queue)
  const t0 = c("s0"), T0 = c("S0");
  const mod = `host.sim.template.${dir.replaceAll("/", ".")}`;
  if (chain.row !== `dec_${kind}.r0`) fail(`${X}: row ${chain.row} is not case ${kind}'s`);
  // the spec's maps
  const varsOfP = new Map<string, [number, string][]>(spec.pieces.map((p: any) => [p.id, p.vars]));
  const pieces: any[] = chain.pieces;
  const pname = (p: any) => "glue" in p ? p.glue as string : p.stage.name as string;
  const varsOf = (p: any) => varsOfP.get(`${X}.${pname(p)}`) ?? fail(`${X}: ${pname(p)} is not in the spec`);
  // each distinct map once, `<chain>.m<k>` (its quantities by name: a long list literal elaborates its tail apart)
  const maps: string[] = [];
  const mapOf = (p: any) => {
    const l = `[${varsOf(p).map(([v, q]) => `(${v}, Q.${q})`).join(", ")}]`;
    if (!maps.includes(l)) maps.push(l);
    return `${X}.m${maps.indexOf(l)}`;
  };
  if (!("glue" in pieces[0]) || pieces[0].glue !== "start" || pieces[0].steps !== 0) fail(`${X}: a chain from a call (glue 0 \`start\`)`);
  if (pieces.length % 2 !== 1 || pieces.some((p, k) => ("glue" in p) !== (k % 2 === 0))) fail(`${X}: glue, call, …, glue`);
  const nCalls = (pieces.length - 1) / 2;
  // the acceptance parameters (every okB<k> the same)
  const okb = readFileSync(join(tdir, "OkB.lean"), "utf8");
  const jsps = [...okb.matchAll(/:= Disp\.okJSK \(Host\.Ts\.Sim\.Template\.fullJSPP (⟨[^⟩]*⟩) (\[[^\]]*\]) (\[\]|\[\(.*?\)\])\) \(fun _ _ => false\)\s*$/gm)].map(m => [m[1]!, m[2]!, m[3]!]);
  if (jsps.length === 0) fail(`${X}: okB not \`Disp.okJSK (fullJSPP …) (fun _ _ => false)\` (\`decOk\`)`);
  if (jsps.length === 0 || jsps.some(j => JSON.stringify(j) !== JSON.stringify(jsps[0]))) fail(`${X}: the okB's acceptance parameters differ`);
  const [Pw, fr, wd] = jsps[0]!;
  // the decode loop's frames: `forwarded`, `emitted`, the further ones (every wide frame's address among them)
  const frs = JSON.parse(fr) as number[], wides = [...wd.matchAll(/\((\d+), /g)].map(m => +m[1]!);
  if (wides.some(w => !frs.includes(w))) console.warn(`${X}: the okB frames ${fr} miss the wide frames ${wides} (IterEndW.ShiftFW needs them in Fr.xs)`);
  // the absorbed `emitted` elements of each call: the merged state's array past the chain start's
  const eNs: string[][] = (seg.bridges as any[]).filter(b => b.kind === "stage").map(b => {
    const e = (b.arrs as { a: number; prefix: boolean; els: string[] }[] | undefined)?.find(x => x.a === frs[1]);
    if (!e || !e.prefix) fail(`${X}: bridge ${b.ia}: no emitted array past the chain start's`);
    return e.els;
  });
  // the runs `sim_chain_range X okB<j> a b runSeg<k>` and the entry steps `stepA<j>` from boundary a
  const runs = new Map<string, { ok: string; a: number; b: number }>();
  for (const m of readFileSync(join(tdir, "Run.lean"), "utf8").matchAll(/^sim_chain_range \S+ \S+\.(okB\d+) (\d+) (\d+) (\S+)$/gm))
    runs.set(m[4]!, { ok: m[1]!, a: +m[2]!, b: +m[3]! });
  const steps = new Map<number, { name: string; b: number }>();
  for (const f of readdirSync(tdir).filter(f => /^K\d+\.lean$/.test(f)))
    for (const m of readFileSync(join(tdir, f), "utf8").matchAll(/kernel_rfl \S+\.(stepA\d+) : interpS \(step \S+ \S+\.s(\d+)\)\.run \S+ = some \(\S+\.s(\d+), /g))
      steps.set(+m[2]!, { name: m[1]!, b: +m[3]! });
  // A4's modules stating the end's results `dvs` and their terms `des`, and its `emitted` elements `eR` (its end facts)
  const defMod = (n: string) => {
    const ms = readdirSync(tdir).filter(f => f.endsWith(".lean") &&
      new RegExp(`^(noncomputable )?def ${X}\\.${n}\\b`, "m").test(readFileSync(join(tdir, f), "utf8")));
    if (!ms.length) console.warn(`${X}: no \`def ${X}.${n}\` in ${dir} yet (A4's end): the fill imports EFacts`);
    return ms[0]?.replace(/\.lean$/, "") ?? "EFacts";
  };
  const desMod = defMod("des"), eRMod = defMod("eR");
  const endMod = readdirSync(tdir).find(f => f.endsWith(".lean") &&
    new RegExp(`^noncomputable def ${X}\\.iterEnd\\b`, "m").test(readFileSync(join(tdir, f), "utf8")))?.replace(/\.lean$/, "");
  if (!endMod) console.warn(`${X}: no \`def ${X}.iterEnd\` in ${dir} yet (A4's end): \`${X}.case\` takes the end facts`);
  const ia: number[] = (seg.bridges as any[]).filter(b => b.kind === "stage").map(b => b.ia);
  if (ia.length !== nCalls) fail(`${X}: ${ia.length} stage bridges, ${nCalls} calls`);
  const glues = pieces.filter((_, k) => k % 2 === 0);
  const answers = glues.map(g => g.glue === "start" ? 0 : JSON.parse(readFileSync(join(sdir, g.meta), "utf8")).answers as number);
  const P = `b0 NB ${X}.Pw ${X}.fr ${X}.wd W A Fr ${t0} ${T0}.tab fixA toks ΔJ ΔH ΔN`;
  // the ghost's data (`b0`'s world); its closed form for the kernel's counter checks (the data reads no bridge)
  const ghost = (j: number, nb = "NB", en = "eN", bb = "b0") =>
    j === 0 ? `(GhostP.init (fullWorldFb ${bb} ${nb}) ${t0})` : `(${X}.g${j} ${bb} ${nb} ${en})`;
  const ghostK = (j: number) => ghost(j, "0", "fun _ => []", "Host.Mlx.FfiAne.St.empty");
  const cut = (b: number, j: number, m: string) => `(fun i x0 => bdCut ${P} θ ${ghost(j)} ${m} ${c(`s${b}`)} ${c(`S${b}`)} i x0)`;
  const rows = `dec_${kind}.rows`;
  const sub = (m2: string, m1: string) => m2 === m1 ? "(fun _ h => h)" : "(by decide +kernel)";
  const DJ = `(decJ ${X}.Pw ${X}.fr ${X}.wd)`;
  // the cuts: c<2j+1> at call j's state (the variables of the glue piece before it), c<2j+2> at its canonical state
  const cutB: [number, number, string][] = [];
  for (let j = 0; j < nCalls; j++) {
    cutB.push([ia[j]!, j, mapOf(pieces[2 * j])]);
    cutB.push([ia[j]! + 2, j + 1, mapOf(pieces[2 * j + 2])]);
  }
  // the ghost's counters (`GhostP.compact` at each compaction: seg.json's merged and canonical counters; the end's
  // the start's and seg.json's `counters`), Lean's truncated subtraction
  const sub0 = (x: number, y: number) => Math.max(0, x - y);
  const start = chain.start as { next: number; mnext: number; nnext: number };
  let [vJ, vH, vN, gJ, gH, gN] = [start.next, start.mnext, start.nnext, 0, 0, 0];
  for (const b of (seg.bridges as any[]).filter(b => b.kind === "stage")) {
    const k = b.compaction;
    [gJ, gH, gN] = [gJ + sub0(k.n1, vJ), gH + sub0(k.xn1, vH), gN + sub0(k.nn1, vN)];
    [vJ, vH, vN] = [k.n0, k.xn0, k.nn0];
  }
  const dJ = gJ + sub0(start.next + seg.counters.dJ, vJ), dH = gH + sub0(start.mnext + seg.counters.dH, vH),
    dN = gN + sub0(start.nnext + seg.counters.dN, vN);
  let dec: { vs: number[]; u: number; m: string } | undefined;
  let facts = "", runsS = "", runsV: string[] = [], growV: string[] = [], grow = "", calls = "", callsF = "", links = "";
  links += `  start := startLink [] (by decide +kernel) rfl rfl hfr hVB
    (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb\n`;
  for (let j = 0; j < nCalls; j++) {
    const cl = pieces[2 * j + 1].stage, gl = pieces[2 * j + 2], last = j === nCalls - 1;
    const a = ia[j]!, inst = String(cl.instance).split(".").pop()!, k = cl.site as number;
    if (k !== j) fail(`${X}: call ${j} at site ${k}`);
    // the call's maps: its own (`m`), the cut's before (`R`) and after it (`R'`, within `R` and the results at their `qs`)
    const m = mapOf(pieces[2 * j + 1]), R = cutB[2 * j]![2], R2 = cutB[2 * j + 1]![2];
    const sa = c(`s${a}`), Sa = c(`S${a}`), sm = c(`s${a + 1}`), tabm = `${c(`S${a + 1}`)}.tab`, sc = c(`s${a + 2}`),
      Sc = c(`S${a + 2}`), g = ghost(j), g0 = ghostK(j);
    const A4 = (n: string) => `A4: \`${X}.${n}\``;
    // the call's kernel facts here: the loop table within the call's, the counters at the merged state, the band
    facts += `-- call \`${cl.name}\` (\`${cl.fn}\`): the call state \`s${a}\`, merged \`s${a + 1}\`, canonical \`s${a + 2}\`
kernel_rfl ${X}.len${a} : Nat.ble ${T0}.tab.length ${Sa}.tab.length = true
kernel_rfl ${X}.cJm${j} : Nat.ble ${g0}.vJ ${sm}.next = true
kernel_rfl ${X}.cJc${j} : Nat.ble ${sc}.next ${sm}.next = true
kernel_rfl ${X}.cHm${j} : Nat.ble ${g0}.vH (mlxOf ${sm}.ffi).next = true
kernel_rfl ${X}.cHE${j} : Nat.blt (mlxOf ${sm}.ffi).next ${X}.Pw.E = true
kernel_rfl ${X}.cNm${j} : Nat.ble ${g0}.vN (mlxOf ${sm}.ffi).nnext = true
kernel_rfl ${X}.bandLo${j} : Nat.ble ${DJ}.lo (mlxOf ${sc}.ffi).next = true
kernel_rfl ${X}.cRJ${j} : Nat.ble (${sm}.next + ${t0}.next + ${g0}.dJ) (${dJ} + ${g0}.vJ + ${sc}.next) = true
kernel_rfl ${X}.cRH${j} : Nat.ble (${g0}.dH + (mlxOf ${sm}.ffi).next + (mlxOf ${t0}.ffi).next) (${dH} + ${g0}.vH + (mlxOf ${sc}.ffi).next) = true
kernel_rfl ${X}.cRN${j} : Nat.ble (${g0}.dN + (mlxOf ${sm}.ffi).nnext + (mlxOf ${t0}.ffi).nnext) (${dN} + ${g0}.vN + (mlxOf ${sc}.ffi).nnext) = true
kernel_rfl ${X}.scE${j} : Nat.ble (mlxOf ${sc}.ffi).next ${X}.Pw.E = true
kernel_rfl ${X}.scN${j} : Nat.ble (mlxOf ${sc}.ffi).nnext ${X}.Pw.NE = true

`;
    calls += `/-- **Call \`${cl.name}\`'s facts** (\`${cl.fn}\`, ${cl.steps} target steps; \`callLink\`'s, by owner): the instance \`I\`, its
oracle \`O\`, written addresses \`wr\`, fresh result variables \`ws\`, canonical result variables \`cws\` and their merged
references \`nr\`, the compaction map \`κ\`, the forwarded elements \`f\`, the results' entries \`Es\` (A4's \`${inst}\`,
\`Site${k}\`, \`SiteF${k}\`, \`SiteC${k}\`, \`SiteD${k}\`, \`SiteL${k}\`, \`SiteS${k}\`). -/
structure ${X}.Call${j} (b0 : BSt) (NB : Nat) (W : Nat → Option WFrame) (A : Addr) (Fr : LoopFramesA A) (fixA : List Nat)
    (L T : Nat) (tk : Nat → Nat) (θ : Nat → SymE) (eN : Nat → List Val) where
  /-- ${A4(`${inst}.tpl`)} -/
  I : Stage.StageTpl FF (Template.okLocal (decOk ${X}.Pw ${X}.fr ${X}.wd))
  /-- ${A4(`${inst}.O`)} -/
  O : List Ans
  /-- ${A4(`${inst}.wr`)} -/
  wr : List Nat
  /-- ${A4(`ws${k}`)} -/
  ws : List Nat
  /-- ${A4(`cws${k}`)} -/
  cws : List Nat
  /-- ${A4(`nr${k}`)} -/
  nr : List Nat
  /-- ${A4(`kappa${k}`)} -/
  κ : Map
  /-- A4: \`SiteL${k}\`'s forwarded elements at \`s${a + 1}\` -/
  f : List Val
  /-- A4: \`cderived${k}\`'s entries -/
  Es : List (Option SymE)
  /-- the instance's oracle at the link's map (kernel, once \`O\` is A4's) -/
  chk : ∀ r ∈ ${rows}, goodLin r.ps (varsOf r.V ${m}) O = true
  /-- ${A4(`srvO${k}`)} -/
  hO : I.S0.oracle = O
  /-- ${A4(`iso${k}`)} -/
  hs0 : I.s0 = { ${sa} with stack := [] }
  /-- ${A4(`tab0_${k}`)} -/
  htab : I.S0.tab = ${Sa}.tab
  /-- ${A4(`stFoot${k}`)} -/
  hfoot : Conv.StageFoot wr I.s0 I.s2
  /-- ${A4(`wrNodup${k}`)} -/
  hnd : wr.Nodup
  /-- ${A4(`wrBound${k}`)} -/
  hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31
  /-- ${A4(`trace${k}`)} -/
  htr : ∃ fr, I.s2.trace = fr ++ I.s0.trace
  /-- ${A4(`merge${k}`)}, with \`n0_${k}\` -/
  hmer : ${sm} = Conv.mergeSt Map.id (Map.id.res ${Sa}.tab.length ${Sa}.tab.length) ${sa}.stack wr ${sa} I.s2 I.s0 I.s2.ffi
  /-- ${A4(`mergeTab${k}`)} -/
  hmtab : ${tabm} = ${Sa}.tab ++ Conv.resTab ws
  /-- kernel, once \`ws\` is A4's -/
  hwsl : ws.length = I.S2.tab.length - ${Sa}.tab.length
  /-- kernel -/
  hwsnd : ws.Nodup
  /-- ${A4(`fresh${k}`)} (its first conjunct) -/
  hfresh : ∀ e ∈ ${Sa}.tab, ∀ w ∈ ws, e.noVar w = true
  /-- kernel: the loop table avoids the results and the stage's variables -/
  hgtab : ∀ j e, nth? ${T0}.tab j = some e → ∀ w, (w ∈ cws ∨ w ∈ ws) → e.noVar w = true
  /-- from the end's restart substitution (\`IterEndW.theta\` at \`addrPrompt\`), kernel -/
  hgθ : ∀ j e, nth? ${T0}.tab j = some e → ∀ w, (w ∈ cws ∨ w ∈ ws) → w ≠ A.nxt → (e.subst θ).noVar w = true
  /-- ${A4(`ctab${k}`)} -/
  hctab : ${Sc}.tab = ${Sa}.tab ++ cws.map SymE.var
  /-- ${A4(`cwsDisj${k}`)} -/
  hdis : ∀ w ∈ cws, w ∉ ws
  /-- A3's \`Conv.compact_shift\` (\`hcall\` the call state's \`CallFacts\`; A4's \`JClean\`, \`cfix${k}\`, \`cheap${k}\`, the frames'
  per-array facts; \`Fd\` the acceptance's frames (\`hFd\` from \`Kp\`), \`Xs\` those off \`W\`, the wide frame's address framed
  and present at the canonical state, its \`WFix\` trivial; \`hctab\` rewrites its canonical table) -/
  hshift : ∀ x0 x : SegInst FF, Conv.CallFacts ${sa} ${Sa}.tab.length → Disp.Kp ${DJ} x.K → IterGhostCW (fullWorldFb b0 NB) A ${X}.Pw Fr ${t0} ${T0}.tab fixA θ ${g} x0 x →
    ShiftD FF (fun _ _ _ => True) κ (Conv.compactθ cws (nr.map fun r => (nth? ${tabm} r).getD (.var 0)))
      (kpOf x.K W) W x.K ${sc} ⟨${Sc}.tab, []⟩ ${sm} ⟨${tabm}, []⟩
  /-- ${A4(`cshift${k}`)} with the chain's \`NClean\` and the **E-form facts** -/
  hffi : Conv.FullShiftQ ${X}.Pw ${Sc}.tab.length κ ${sc}.ffi ${sm}.ffi
  /-- ${A4(`cbigs${k}`)} with \`ccounters${k}\` -/
  hbig : bigsOutB (mlxOf ${sc}.ffi).next ${X}.Pw.E (mlxOf ${sc}.ffi) = true
  /-- **A3/A4**: no bigint of the canonical fresh band (\`cclean${k}\`) -/
  hfree : NoBigSt (fun i => ((mlxOf ${sc}.ffi).next : Int) ≤ i ∧ i < ${X}.Pw.E) ${sc}.trace ${sc}
  /-- \`Conv.Map.compact_num_lt\` at ${A4(`kappa${k}`)} -/
  hκn : ∀ j, j < ${T0}.tab.length → κ.num j = .ref j
  /-- \`Conv.Map.compact_lt\` at \`fixA\` (the route's, below the canonical counter) -/
  hκa : ∀ a ∈ fixA, κ.a a = a
  /-- **A3/A4**: the compaction's nodes below the template start's -/
  hκv : ∀ j, j < (mlxOf ${t0}.ffi).nnext → κ.node j = j
  /-- A4: \`SiteL${k}\`'s \`arr${k}_<fwd>\` at \`A := addrPrompt\` -/
  hfwd : ∃ o, ${sm}.heap.get A.fwd = some (.obj o) ∧ o.kind = .array (arrOf ${t0} A.fwd ++ f)
  /-- A4: \`SiteL${k}\`'s \`arr${k}_<emit>\` -/
  hemit : ∃ o, ${sm}.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf ${t0} A.emit ++ eN ${j})
  /-- A4: \`SiteL${k}\`'s further frames' arrays (their prefixes) -/
  hkeep : KeepsAtW Fr ${sm}
  /-- A4: \`SiteL${k}\`'s \`arrR${k}_<emit>\` -/
  heN : NumRefs ${T0}.tab.length (eN ${j})
  /-- kernel -/
  hm0 : ∀ p ∈ ${R}, Conv.idx? p.1 cws = none ∧ ws.contains p.1 = false
  /-- kernel -/
  hndc : cws.Nodup
  /-- kernel -/
  hlenc : cws.length = nr.length
  /-- ${A4(`cnrLo${k}`)} -/
  hnrLo : nr.all (Nat.ble ${Sa}.tab.length) = true
  /-- ${A4(`cderived${k}`)} -/
  hder : nr.map (fun r => nth? I.S2.tab r) = Es
  /-- A4: \`cqs${k}\`, the results' quantities (\`cderived${k}\`'s forms by \`Conv.decQ\`) -/
  qs : List Q
  /-- kernel -/
  hlq : qs.length = cws.length
  /-- kernel: each result at the offset or the end position -/
  hqs : qs.all (fun q => decide (q = .o ∨ q = .e)) = true
  /-- \`Conv.hEs_of_decQ\` with A4's \`cdq${k}\` (\`decI\`'s \`n = 1\`, the offset below \`2 ^ 31\`) -/
  hEs : ∀ (i : Cls.Inst) (ν : Nat → F64), DecAt L T tk i → MapOk ν i ${R} → VBOkF loopVB ν →
    ∀ j o, nth? Es j = some o → ∃ E q, o = some E ∧ nth? qs j = some q ∧ E.eval ν = F64.ofNat (i.get q)
  /-- kernel: the next cut's variables -/
  hR' : ∀ p ∈ ${R2}, p ∈ ${R} ++ cws.zip qs

`;
    callsF += `  c${j} : ${X}.Call${j} b0 NB W A Fr fixA L T tk θ eN\n`;
    const cj = `Cs.c${j}`;
    const field = (n: string) => `(${n} := ${cj}.${n})`;
    links += `  ${cl.name} := callLink ${cj}.I ${cj}.O hW ${cj}.chk ${cj}.hO ${sub(m, R)} ${["hs0", "htab", "hfoot", "hnd", "hbd", "htr", "hmer",
      "hmtab", "hwsl", "hwsnd", "hfresh"].map(field).join(" ")}
    (hlen := Nat.le_of_ble_eq_true ${X}.len${a}) ${["hgtab", "hgθ"].map(field).join(" ")}
    (hgrow := call_ngrow hW ${cj}.I ${cj}.hs0 ${cj}.hfoot ${cj}.hnd ${cj}.hbd ${cj}.htr) ${["hctab", "hdis", "hshift", "hffi", "hbig", "hfree"].map(field).join(" ")}
    (hband := band_of (Nat.le_of_ble_eq_true ${X}.bandLo${j}) (Nat.le_of_ble_eq_true ${X}.bandHi) (by decide))
    ${["hκn", "hκa", "hκv", "hfwd", "hemit", "hkeep", "heN"].map(field).join(" ")}
    (hJ := Nat.le_of_ble_eq_true ${X}.cJm${j}) (hJc := Nat.le_of_ble_eq_true ${X}.cJc${j})
    (hH := Nat.le_of_ble_eq_true ${X}.cHm${j}) (hHE := Nat.blt_eq.mp ${X}.cHE${j})
    (hN := Nat.le_of_ble_eq_true ${X}.cNm${j}) ${["hm0", "hndc", "hlenc", "hlq", "hnrLo", "hder", "hEs", "hR'"].map(field).join(" ")}
    (hq := qs_le ${cj}.hqs) (dJ := ${dJ}) (dH := ${dH}) (dN := ${dN}) (hdJ := hdJ) (hdH := hdH)
    (hdN := hdN) (hcJ := Nat.le_of_ble_eq_true ${X}.cRJ${j}) (hcH := Nat.le_of_ble_eq_true ${X}.cRH${j})
    (hcN := Nat.le_of_ble_eq_true ${X}.cRN${j}) (hs0E := Nat.le_of_ble_eq_true ${X}.s0E)
    (hscE := Nat.le_of_ble_eq_true ${X}.scE${j}) (hs0N := Nat.le_of_ble_eq_true ${X}.s0N)
    (hscN := Nat.le_of_ble_eq_true ${X}.scN${j})\n`;
    // the glue piece after the call
    const lean = gl.lean;
    if (typeof lean !== "string") fail(`${X}: glue ${gl.glue}: one run segment expected`);
    const rn = lean.split(".").pop()!, run = runs.get(rn) ?? fail(`${X}: ${rn} not in Run.lean`);
    if (run.a !== gl.from || run.b !== gl.to) fail(`${X}: ${rn}: ${run.a} → ${run.b}, chain.json ${gl.from} → ${gl.to}`);
    if (gl.from !== a + 2) fail(`${X}: glue ${gl.glue} from ${gl.from}, the canonical state ${a + 2}`);
    if (answers.slice(j + 2).some(n => n > 0)) fail(`${X}: glue ${gl.glue}: a later glue piece consumes answers (needs runOk's oracle prefix)`);
    const meta = JSON.parse(readFileSync(join(sdir, gl.meta), "utf8"));
    const o0 = +((String(meta.oracle).match(/List\.drop (\d+) /) ?? fail(`${X}: ${gl.meta}: oracle`))[1]!);
    const O = `(List.drop ${o0} ${c("O")})`, f = gl.from as number, t = gl.to as number, n = gl.steps as number;
    const mA = mapOf(gl);
    facts += `-- glue \`${gl.glue}\`: \`${X}.${rn}\` (${n} steps) from \`s${f}\`${last ? ", the chain's end" : `, then \`${X}.${steps.get(t)?.name}\` into the call at \`s${t + 1}\``}
kernel_rfl ${X}.ok${f} : ${c(run.ok)} ${c(`s${f}`)} ${c(`S${f}`)} = true
kernel_rfl ${X}.srv${f} : ${c(`S${f}`)}.oracle = List.drop ${o0} ${c("O")}
kernel_rfl ${X}.len${f} : Nat.ble ${T0}.tab.length ${c(`S${f}`)}.tab.length = true
theorem ${X}.chk_${gl.glue} : ∀ r ∈ ${rows}, goodLin r.ps (varsOf r.V ${mA}) ${O} = true := by
  decide +kernel
`;
    runsS += `  ${rn} : runOk ${c("F")} ${c(run.ok)} ${n} ${c(`s${f}`)} ${c(`S${f}`)} = some (${c(`s${t}`)}, ${c(`S${t}`)})\n`;
    runsV.push(`${c(rn)}`);
    grow += `  ${gl.glue} : ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VBOkF loopVB c.ν →
    Disp.Kp ${DJ} c.K → RelB FF (FLRb b0 ${X}.Pw NB r) W [] c.M c.ν c.K ${c(`s${f}`)} ${c(`S${f}`)} c.t c.C →
    runC FF ${last ? n : `(${n} + 1)`} c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi)\n`;
    if (!last) {
      const st = steps.get(t) ?? fail(`${X}: no entry step from s${t}`);
      if (st.b !== t + 1 || ia[j + 1] !== t + 1) fail(`${X}: ${st.name}: s${t} → s${st.b}, the next call at ${ia[j + 1]}`);
      facts += `kernel_rfl ${X}.halt${t} : isHalt ${c(`s${t}`)}.ctl = false
kernel_rfl ${X}.top${t + 1} : noRetBlock ${c(`s${t + 1}`)} = true\n\n`;
      runsS += `  ${st.name} : interpS (step ${c("F")} ${c(`s${t}`)}).run ${c(`S${t}`)} = some (${c(`s${t + 1}`)}, ${c(`S${t + 1}`)})\n`;
      runsV.push(`${c(st.name)}`);
      links += `  ${gl.glue} := glueLinkCall ${O} hW ${X}.chk_${gl.glue} ${X}.srv${f} ${X}.ok${f} R.${rn}
    (runOk_ok_end ${n - 1} R.${rn} ${X}.halt${t}) ${X}.halt${t} R.${st.name} ${X}.top${t + 1}
    (Nat.le_of_ble_eq_true ${X}.len${f}) ${sub(cutB[2 * j + 2]![2], mA)} Gw.${gl.glue}\n`;
      growV.push(`fun r _ _ _ hν hK hr ht => Full.glueCall_ngrow (decSimQ b0 NB ${X}.Pw ${X}.fr ${X}.wd W hW r []) ${X}.ok${f} R.${rn}
    (runOk_ok_end ${n - 1} R.${rn} ${X}.halt${t}) ${X}.halt${t} R.${st.name} hν hK hr ht`);
    } else {
      facts += `kernel_rfl ${X}.top${t} : noRetBlock ${c(`s${t}`)} = true\n\n`;
      const der = (meta.derived as [number, string, string][]);
      const us = [...new Set(der.flatMap(([, , ex]) => [...ex.matchAll(/v(\d+)/g)].map(mm => mm[1]!)))];
      if (us.length > 1) fail(`${X}: ${gl.glue}: results of several variables ${us}`);
      dec = der.length ? { vs: der.map(([v]) => v), u: +us[0]!, m: mA } : undefined;
      links += dec
        ? `  ${gl.glue} := glueLinkEndD ${O} hW ${X}.chk_${gl.glue} ${X}.srv${f} ${X}.ok${f} R.${rn}
    ${X}.top${t} ${c("dvs")} ${c("des")} ${dec.u} (e := Ed.e.toFb b0) Ed.he1 Ed.hS1 (decQ_hvs ${X}.hvsB) (by decide +kernel)
    (Nat.le_of_ble_eq_true ${X}.len${f}) Gw.${gl.glue}\n`
        : `  ${gl.glue} := glueLinkEnd ${O} hW ${X}.chk_${gl.glue} ${X}.srv${f} ${X}.ok${f} R.${rn}
    ${X}.top${t} (e := Ed.e.toFb b0) Ed.he1 Ed.hS1 (Nat.le_of_ble_eq_true ${X}.len${f}) Gw.${gl.glue}\n`;
      growV.push(`fun r _ _ _ hν hK hr ht => Full.glue_ngrow (decSimQ b0 NB ${X}.Pw ${X}.fr ${X}.wd W hW r []) ${X}.ok${f} R.${rn}
    hν hK hr ht`);
    }
  }
  const end = pieces[pieces.length - 1].to as number;
  const gE = ghostK(nCalls), sE = c(`s${end}`);
  const ghosts = ia.map((a, j) => `/-- The ghost's data after call ${j}'s compaction (merged \`s${a + 1}\`, canonical \`s${a + 2}\`). -/
noncomputable def ${X}.g${j + 1} (b0 : BSt) (NB : Nat) (eN : Nat → List Val) : GhostP :=
  GhostP.compact (fullWorldFb b0 NB) ${ghost(j)} ${c(`s${a + 1}`)} ${c(`s${a + 2}`)} (eN ${j})\n`).join("\n");
  const sigP = `(eN : Nat → List Val) (Ed : ${X}.End NB W A Fr fixA) (R : ${X}.Runs)
    (Cs : ${X}.Calls b0 NB W A Fr fixA L T tk Ed.e.θ eN) (hW : Disp.Wp ${DJ} W)
    (hfr : ∀ a, a ∈ A.fwd :: A.emit :: Fr.xs ↔ a ∈ ${X}.fr)
    (hVB : ∀ i nx, nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (hdJ : ${dJ} ≤ ΔJ) (hdH : ${dH} ≤ ΔH) (hdN : ${dN} ≤ ΔN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf ${t0}.ffi).next + T * ΔH + B.H + (${X}.Pw.E - (mlxOf ${t0}.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf ${t0}.ffi).nnext + T * ΔN + B.N + (${X}.Pw.NE - (mlxOf ${t0}.ffi).nnext) < 2 ^ 62)`;
  const s = `import host.sim.compose.CallGrow
import host.sim.compose.DecBundle
import host.load.run.prompt.Addr
import host.sim.template.EndGen
import ${mod}.H0
import ${mod}.OkB
${[...new Set([...(dec ? [desMod] : []), eRMod, ...(endMod ? [endMod] : [])])].map(m => `import ${mod}.${m}\n`).join("")}${withRun ? `import ${mod}.Run\n` : ""}set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace ${NS}
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers
  Host.Ts.Sim.Template

/-! # Decode case \`${kind}\`'s pieces from A4's chain \`${X}\` (generated by \`host/sim/compose/gen.ts fill\`)

Scratch, unregistered: it imports A4's chain modules (\`${mod}\`). The decode world: the target's bridge pinned to
\`b0\` (\`fullWorldFb b0 NB\`). \`${X}.pieces\`: \`DecPieces_${X}\` at the chain's boundaries (\`host.sim.compose.ChainFill\`'s \`bdCut\`, each at the variables known there, the ghost
\`${X}.g<j>\` after \`j\` compactions, absorbing \`emitted\`'s elements \`eN j\`); the start and glue links from A4's
runs (\`${X}.Runs\`${withRun ? `, \`${X}.runs\`` : ""}), the boundary facts below and the pinned decode world's growth along the runs
(\`${X}.Grow\`, A1's); the call links \`callLink\` (\`host.sim.compose.CallLink\`) from the calls' facts
(\`${X}.Call<j>\`, each field's owner in its doc) and the counters and band below. \`${X}.case\`: the case's
\`IterCaseW\` from the end facts (\`${X}.End\`, A4's in the full world at the prompt route's instance: \`${X}.EndAt\`${endMod ? `,
\`${X}.endAt\` from A4's \`${endMod}\`` : ""}; moved by \`IterEndW.toFb\`), the emitted token (\`${X}.emitTok\`) and the
counters (\`${X}.within\`: the ghost's \`dJ ${dJ}\`, \`dH ${dH}\`, \`dN ${dN}\`, the growth absorbed by the compactions
included; seg.json's canonical deltas \`${seg.counters.dJ}\`, \`${seg.counters.dH}\`, \`${seg.counters.dN}\`). -/

/-- The chain's acceptance parameters (its \`okB<k>\`'s \`Template.fullJSPP\`). -/
abbrev ${X}.Pw : LoadP := ${Pw}
abbrev ${X}.fr : List Nat := ${fr}
abbrev ${X}.wd : List (Nat × WFrame) := ${wd}
/-- The \`emitted\` elements each call's compaction absorbs (A4's merged states' \`emitted\` past the chain start's, the
canonical states resetting it). -/
def ${X}.eN : Nat → List Val
${eNs.map((l, j) => `  | ${j} => [${l.join(", ")}]`).join("\n")}
  | _ => []

/-- The pieces' variable maps (the chains' spec). -/
${maps.map((l, k) => `def ${X}.m${k} : List (Nat × Q) := ${l}`).join("\n")}

${dec ? `-- A4's end results (\`${X}.dvs\`) and terms (\`${X}.des\`): each a decode form of \`v${dec.u}\` (\`Conv.decQ\`) at a
-- quantity the last glue piece's map holds it
kernel_rfl ${X}.hvsB : (${c("dvs")}.zip ${c("des")}).all (fun p => match Conv.decQ ${dec.u} p.2 with
  | some q => ${dec.m}.contains (p.1, q) | none => false) = true

` : ""}
/-! ## The ghost -/

${ghosts}
/-! ## The boundary facts -/

kernel_rfl ${X}.bandHi : Nat.ble ${X}.Pw.E ${DJ}.hi = true
kernel_rfl ${X}.s0E : Nat.ble (mlxOf ${t0}.ffi).next ${X}.Pw.E = true
kernel_rfl ${X}.s0N : Nat.ble (mlxOf ${t0}.ffi).nnext ${X}.Pw.NE = true

${facts}/-- **A4's glue runs** (\`${mod}.Run\`'s segments, the \`K<j>\`'s entry steps). -/
structure ${X}.Runs : Prop where
${runsS}${withRun ? `
theorem ${X}.runs : ${X}.Runs := ⟨${runsV.join(", ")}⟩
` : ""}
/-- The pinned decode world's mlx growth along the glue runs (A1's \`Full.glueCall_ngrow\`, \`Full.glue_ngrow\` under \`decSimQ\`). -/
structure ${X}.Grow (b0 : BSt) (NB : Nat) (W : Nat → Option WFrame) : Prop where
${grow}
/-- **The glue runs' growth** from A4's runs. -/
theorem ${X}.grow {b0 : BSt} {NB : Nat} {W : Nat → Option WFrame} (R : ${X}.Runs) (hW : Disp.Wp ${DJ} W) :
    ${X}.Grow b0 NB W :=
  ⟨${growV.join(",\n  ")}⟩

/-! ## The counters -/

kernel_rfl ${X}.cJ0 : Nat.ble ${gE}.vJ ${sE}.next = true
kernel_rfl ${X}.cJ : Nat.ble (${gE}.dJ + (${sE}.next - ${gE}.vJ)) ${dJ} = true
kernel_rfl ${X}.cH0 : Nat.ble ${gE}.vH (mlxOf ${sE}.ffi).next = true
kernel_rfl ${X}.cH : Nat.ble (${gE}.dH + ((mlxOf ${sE}.ffi).next - ${gE}.vH)) ${dH} = true
kernel_rfl ${X}.cN0 : Nat.ble ${gE}.vN (mlxOf ${sE}.ffi).nnext = true
kernel_rfl ${X}.cN : Nat.ble (${gE}.dN + ((mlxOf ${sE}.ffi).nnext - ${gE}.vN)) ${dN} = true

/-- **The counters within the iteration's budget** at an end at \`s${end}\`. -/
theorem ${X}.within {b0 : BSt} {NB : Nat} {A : Addr} {fixA : List Nat} (eN : Nat → List Val)
    {e : IterEndW (fullWorldFb b0 NB) A ${X}.Pw ${t0} ${T0}.tab fixA} (he1 : e.s1 = ${sE}) {ΔJ ΔH ΔN : Nat}
    (hJ : ${dJ} ≤ ΔJ) (hH : ${dH} ≤ ΔH) (hN : ${dN} ≤ ΔN) : e.Within (${X}.g${nCalls} b0 NB eN) ΔJ ΔH ΔN := by
  unfold IterEndW.Within; rw [he1]
  exact ⟨Nat.le_of_ble_eq_true ${X}.cJ0, Nat.le_trans (Nat.le_of_ble_eq_true ${X}.cJ) hJ,
    Nat.le_of_ble_eq_true ${X}.cH0, Nat.le_trans (Nat.le_of_ble_eq_true ${X}.cH) hH,
    Nat.le_of_ble_eq_true ${X}.cN0, Nat.le_trans (Nat.le_of_ble_eq_true ${X}.cN) hN⟩

/-! ## The calls and the end -/

${calls}/-- **The calls' facts.** -/
structure ${X}.Calls (b0 : BSt) (NB : Nat) (W : Nat → Option WFrame) (A : Addr) (Fr : LoopFramesA A) (fixA : List Nat)
    (L T : Nat) (tk : Nat → Nat) (θ : Nat → SymE) (eN : Nat → List Val) where
${callsF}
/-- **The case's end facts** (A4's restart data at the chain's end \`s${end}\` in the full world, \`${X}.endB\`'s: the end
template \`e\`, its map \`σ\`, substitution \`θ\`, arrays and native shift, its \`emitted\` elements past the chain start's
\`eR\`; the shift under the frames, the kept frames). The pinned decode world's end is \`e.toFb b0\`. -/
structure ${X}.End (NB : Nat) (W : Nat → Option WFrame) (A : Addr) (Fr : LoopFramesA A) (fixA : List Nat) where
  e : IterEndW (fullWorld NB) A ${X}.Pw ${t0} ${T0}.tab fixA
  he1 : e.s1 = ${sE}
  hS1 : e.S1 = ${dec ? `⟨${c(`S${end}`)}.tab.map (·.subst (Conv.compactθ ${c("dvs")} ${c("des")})), ${c(`S${end}`)}.oracle⟩` : c(`S${end}`)}
  heR : e.eR = ${c("eR")}
  sh : e.ShiftFW Fr W
  keep : KeepsAtW Fr e.s1

/-- **The emitted token** after the compactions' absorbed elements and the end's. -/
theorem ${X}.emitTok (b0 : BSt) (NB : Nat) :
    (${X}.g${nCalls} b0 NB ${X}.eN).eA ++ ${c("eR")} = [.num (.ref Host.Load.Run.Prompt.addrPrompt.tok)] := rfl

/-- **A4's end facts at the prompt route's instance** (\`${X}.endB\`'s form): \`${X}.End\` under \`A := addrPrompt\`, the
route's frames \`framesP ${X}.s0 q\`, its wide frames \`wideP\` and fixed addresses \`fixP\`. -/
abbrev ${X}.EndAt (NB : Nat) : Type :=
  ∀ {W : Nat → Option WFrame} {A : Addr} {Fr : LoopFramesA A} {fixA : List Nat} (q : List Val),
    A = Host.Load.Run.Prompt.addrPrompt → HEq Fr (Template.framesP ${t0} q) → W = Template.wideP →
    fixA = Template.fixP → ${X}.End NB W A Fr fixA
${endMod ? `${dec ? `
-- A4's end server: the canonical results back to their terms
kernel_rfl ${X}.hS1D : ${c("S1D")} = ⟨${c(`S${end}`)}.tab.map (·.subst (Conv.compactθ ${c("dvs")} ${c("des")})), ${c(`S${end}`)}.oracle⟩
` : ""}
/-- **A4's end facts at the prompt route's instance** (\`${X}.iterEnd\`, \`${X}.shiftFW\`, \`${X}.keep\`, as \`${X}.endB\`). -/
noncomputable def ${X}.endAt (NB : Nat) : ${X}.EndAt NB := fun q hA hFr hWP hfix => by
  subst hA hWP hfix
  cases hFr
  exact ⟨${c("iterEnd")} NB, rfl, ${dec ? `${X}.hS1D` : "rfl"}, rfl, ${c("shiftFW")} NB q, ${c("keep")} q⟩
` : ""}
section
variable {b0 : BSt} {NB : Nat} {W : Nat → Option WFrame} {A : Addr} {Fr : LoopFramesA A} {fixA : List Nat} {toks : List NumV}
  {L T : Nat} {tk : Nat → Nat} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}

/-- **Decode case \`${kind}\`'s pieces from chain \`${X}\`.** -/
noncomputable def ${X}.pieces ${sigP} :
    DecPieces_${X} (fullWorldFb b0 NB) A W ${X}.Pw Fr ${t0} ${T0}.tab fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN L T
      (Ed.e.toFb b0) (${X}.g${nCalls} b0 NB eN) :=
  let θ := Ed.e.θ
  let Gw : ${X}.Grow b0 NB W := ${X}.grow R hW
  { ${cutB.map(([b, j, m], k) => `c${k + 1} := ${cut(b, j, m)}`).join("\n    ")}
${links.replace(/^ {2}/gm, "    ")}  }

/-- **Decode case \`${kind}\` from chain \`${X}\`** (\`IterCaseW\`), with A4's end facts at the prompt route's instance. -/
noncomputable def ${X}.case (EdA : ${X}.EndAt NB) (q : List Val) (hA : A = Host.Load.Run.Prompt.addrPrompt)
    (hFr : HEq Fr (Template.framesP ${t0} q)) (hWP : W = Template.wideP) (hfix : fixA = Template.fixP)
    (hW : Disp.Wp ${DJ} W) (hfr : ∀ a, a ∈ A.fwd :: A.emit :: Fr.xs ↔ a ∈ ${X}.fr)
    (R : ${X}.Runs) (Cs : ${X}.Calls b0 NB W A Fr fixA L T tk (EdA q hA hFr hWP hfix).e.θ ${X}.eN)
    (hVB : ∀ i nx, nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : ${dJ} ≤ ΔJ) (hH : ${dH} ≤ ΔH) (hN : ${dN} ≤ ΔN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf ${t0}.ffi).next + T * ΔH + B.H + (${X}.Pw.E - (mlxOf ${t0}.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf ${t0}.ffi).nnext + T * ΔN + B.N + (${X}.Pw.NE - (mlxOf ${t0}.ffi).nnext) < 2 ^ 62) :
    IterCaseW (fullWorldFb b0 NB) A W ${X}.Pw Fr ${t0} ${T0}.tab fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DecSel T L tk .${kind}) where
  e := (EdA q hA hFr hWP hfix).e.toFb b0
  g := ${X}.g${nCalls} b0 NB ${X}.eN
  chain := (${X}.pieces (E0 := E0) (B := B) ${X}.eN (EdA q hA hFr hWP hfix) R Cs hW hfr hVB hJ hH hN hJb hHb hNb).chain h1 hctx
  sh := (EdA q hA hFr hWP hfix).sh
  keep := (EdA q hA hFr hWP hfix).keep
  emit := (congrArg (_ ++ ·) (EdA q hA hFr hWP hfix).heR).trans (by subst hA; exact ${X}.emitTok b0 NB)
  within := ${X}.within (e := (EdA q hA hFr hWP hfix).e.toFb b0) ${X}.eN (EdA q hA hFr hWP hfix).he1 hJ hH hN

end

end ${NS}
`;
  mkdirSync(dirname(outFile), { recursive: true });
  writeFileSync(outFile, s);
  console.log(`${X}: ${outFile}`);
}

if (process.argv[2] === "fill") genFill(process.argv.slice(3));
