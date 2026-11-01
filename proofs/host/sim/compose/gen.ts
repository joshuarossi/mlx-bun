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
 *   bun proofs/host/sim/compose/gen.ts prefill --out <file> [--spec <file>] <chain>:<case-dir>
 *     emits actual template boundaries, row checks and checked site constructors; the compiled
 *     backends also emit concrete piece fills (--sites-only skips the backend). --typed-body
 *     uses parametric typed-buffer templates; --oracles-only checks every internal oracle over
 *     the enclosing forward's uses (--piece overrides that inferred owner).
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
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";

const HERE = dirname(new URL(import.meta.url).pathname);
const LIN = join(HERE, "../lin");
const NS = "Host.Ts.Sim.Compose";
const fail = (m: string): never => { throw new Error(m); };
const writeBundle = (file: string, text: string) => {
  if (process.argv[2] === undefined) writeFileSync(file, text);
};

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
interface Piece { name: string; kind: Kind; A: string; B: string; real: Obl[]; uses: string[] }
/** A link of a row's chain: the piece and how its obligations are discharged at the row. */
interface Link { p: Piece; mem: number; obls: string[] }
type Spec = ({ glue: string } | { stage: string; real?: Obl[] } | { fwd: string; real: Obl[] })[];

const NPS_M = "[(0, .L), (1, .o), (2, .C)]", KV_M = "[(0, .o), (1, .cap), (2, .n)]";
const KV2_M = "[(0, .e), (1, .cap1), (2, .n)]", PLAN_M = "[(0, .n)]", CHUNK_M = "[(0, .L)]";
const GROUP = 200;

class Bundle {
  pieces = new Map<string, Piece>();
  bounds = new Set<string>();
  eqs: string[] = [];
  /** `route`: route pieces (over route rows, at the run's steps `RunAt T tk`). */
  constructor(readonly var_: string, readonly route: boolean) {}
  groupOf(p: Piece) { return `q${Math.floor([...this.pieces.keys()].indexOf(p.name) / GROUP) + 1}`; }
  at(p: Piece) { return `${this.var_}.${this.groupOf(p)}.${p.name}`; }
  use(name: string, kind: Kind, A: string, B: string, row: string, real: Obl[] = []): Link {
    let p = this.pieces.get(name);
    if (!p) this.pieces.set(name, p = { name, kind, A, B, real, uses: [] });
    if (p.A !== A || p.B !== B || p.kind !== kind) fail(`piece ${name}: used between different cuts`);
    if (JSON.stringify(p.real.map(o => [o.m, o.O])) !== JSON.stringify(real.map(o => [o.m, o.O]))) fail(`piece ${name}: obligations differ`);
    let k = p.uses.indexOf(row);
    if (k < 0) { k = p.uses.length; p.uses.push(row); }
    const mem = k;
    const obls = [
      `obl_of_row hin (${this.at(p)}.chk _ (mem_at (k := ${k}) rfl))`,
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
      return p.kind === "glue" ? `RGluePiece F (RunAt T tk) ${uses} ${ends}`
        : p.kind === "fwd" ? `RFwdPiece F (RunAt T tk) ${uses} ${real} ${ends}`
        : `RStagePiece F (RunAt T tk) ${uses} ${real} ${ends}`;
    }
    if (p.kind === "glue") return `GluePiece F ${uses} ${ends}`;
    if (p.kind === "stageP" || p.kind === "stageR") return `StagePiece F ${uses} ${real} ${ends}`;
    return `FwdPiece F ${uses} ${real} ${ends}`;
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

const chainsOf = (PB: Bundle, RB: Bundle, classes: any[], warmSrcs: string[]): ClassChains[] => {
const out: ClassChains[] = [];
for (const c of classes) {
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
    for (const src of c.key.kind === "cold" ? ["first"] : warmSrcs) {
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
return out;
};
const PB = new Bundle("P", false), RB = new Bundle("H", true);
const out = chainsOf(PB, RB, table.classes, ["drained", "tailed"]);

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
writeBundle(join(HERE, "Bundle.lean"), HEADER(["host.sim.compose.Steps", "host.sim.compose.Pieces", "host.sim.lin.Cover", "host.sim.lin.checks.Nps",
  "host.sim.lin.checks.Kv", "host.sim.lin.checks.Chunk", "host.sim.lin.checks.Plan"],
`# The pieces of the prefill classes (generated by \`host/sim/compose/gen.ts\`)

\`Pieces F I\`: the boundary cuts between pieces (\`b_<glue>_i\`, \`b_<glue>_o\`), every piece the
classes' rows use (\`host.sim.compose.Pieces\`: \`GluePiece\`, \`StagePiece\`, \`FwdPiece\`, each with
its template's variable map and oracle over the rows that use it; a call is named
\`<stage>__<glue before>__<glue after>\`), and the length
equalities between the rows of a class. A field is filled by the piece's theorem once its template
exists (tpl_chain, A3's conversions). Stage sites have their own checked oracle as well as
the existing standalone stage obligations (\`host.sim.lin.checks\`).`) + PB.structures("Pieces", "", "") + `\nend ${NS}\n`);
for (const [mod, s] of classMods)
  writeBundle(join(HERE, `${mod}.lean`), HEADER(["host.sim.compose.Bundle"],
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
writeBundle(join(HERE, "Route.lean"), HEADER(["host.sim.compose.ClassA", "host.sim.compose.ClassT1", "host.sim.compose.ClassT2"],
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
writeBundle(join(HERE, "RouteBundle.lean"), HEADER(["host.sim.compose.Route", "host.sim.compose.RoutePieces", "host.sim.lin.CoverR"],
`# The route pieces (generated by \`host/sim/compose/gen.ts\`)

\`RoutePieces F I T tk\`: POST's pieces and the short budgets' paths' prefixes to their cuts
\`b_pA_cut\`, \`b_pB_cut\`, \`b_pC_cut\`, each over the route classes' rows that use it
(\`host.sim.lin.CoverR\`; \`host.sim.compose.RoutePieces\`) with its own variable map, oracle and
its checks, at the steps of the run at budget \`T\` with tokens \`tk\` (\`RunAt T tk\`); the KV append's
oracle at the step's offset is discharged by the rows' checks.`) +
  RB.structures("RoutePieces", "(T : Nat) (tk : Nat → Nat)", "T tk") + `\nend ${NS}\n`);
const post = routeCs.filter(cc => cc.kind === "post");
const pathCs = (k: string) => routeCs.filter(cc => cc.kind === k);
writeBundle(join(HERE, "RouteSteps.lean"), HEADER(["host.sim.compose.RouteBundle"],
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
writeBundle(join(HERE, "chains.json"), JSON.stringify(chainsOut, null, 1) + "\n");

/* ---------- The restricted bundle: the prompts with no Neural Engine forward ---------- */

// `L ≤ 224` (`first_tail_x22` starts at L = 225): chunk 2048, no drains; the row boxes stay whole, the statement clips.
if (process.argv[2] === "restricted") {
  const inGpu = (c: any) => ["setup_early", "setup_h0", "first_final", "final_cold", "final_ord",
      "route_post_other", "route_pathA_other", "route_pathB_other", "route_pathC_other"].includes(c.id) ||
    (c.pos === "first" && c.key.kind === "tail" && c.key.X <= 21);
  const GP = new Bundle("P", false), GR = new Bundle("H", true);
  const gout = chainsOf(GP, GR, table.classes.filter(inGpu), ["tailed"]);
  const NSG = `${NS}.Gpu`;
  const H = (imports: string[], doc: string) => HEADER(imports, doc).replace(`namespace ${NS}`, `namespace ${NSG}`).replace("open Host.Ts ", `open ${NS} Host.Ts `);
  const gpre = gout.filter(cc => !cc.kind), groute = gout.filter(cc => cc.kind);
  const G = (n: string, t: string) => writeFileSync(join(HERE, `${n}.lean`), t + `\nend ${NSG}\n`);
  const cls = gpre.map(cc => classTheorem(GP, cc, "PiecesR F I") + "\n").join("");
  const setups = gpre.filter(cc => cc.cls.pos === "setup"), tails = gpre.filter(cc => cc.cls.pos === "first" && cc.cls.key.kind === "tail");
  const finOf = (id: string) => gpre.find(cc => cc.cls.id === id) ?? fail(`no ${id}`);
  G("BundleR", H(["host.sim.compose.Steps", "host.sim.compose.Pieces", "host.sim.lin.Cover", "host.sim.lin.checks.Nps",
    "host.sim.lin.checks.Kv", "host.sim.lin.checks.Chunk", "host.sim.lin.checks.Plan"],
`# The pieces of the prompts with no Neural Engine forward (generated by \`host/sim/compose/gen.ts restricted\`)

\`PiecesR F I\`: the fields of \`Pieces\` these prompts reach (\`L ≤ 224\`), each over the rows they reach.`) + GP.structures("PiecesR", "", ""));
  G("ClassR", H(["host.sim.compose.BundleR"],
`# The steps of the prompts with no Neural Engine forward (generated by \`host/sim/compose/gen.ts restricted\`)

\`classStepsR P\`: the classes those prompts reach, from \`PiecesR\`.`) + sect("{F : Ffi} {I : PrefInvsW F}", cls + `theorem range22 : List.range 22 = [${[...Array(22).keys()].join(", ")}] := by decide +kernel

variable (I) in
/-- **The steps of the prompts with no Neural Engine forward.** The quantifiers are \`ClassSteps\`'s. -/
structure ClassStepsR where
  nSetup : SetupClass → Nat
  setup : ∀ c ∈ ([.early, .h0] : List SetupClass), SetupS I c (nSetup c)
  nFirstTail : Nat → Nat
  firstTail : ∀ X ∈ List.range 22, FirstTailS I X (nFirstTail X)
  nCold : Nat
  finalCold : FinalS I .first .cold nCold
  nOrd : Nat
  finalOrd : FinalS I .tailed (.warm .ord) nOrd

/-- **The classes' steps from the pieces.** -/
def classStepsR (P : PiecesR F I) : ClassStepsR I where
  nSetup := countOf ${countList(setups, keyOf, "P")}
  setup := ${chainAll(setups, "P")}
  nFirstTail := countOf ${countList(tails, cc => String(cc.cls.key.X), "P")}
  firstTail := by
    rw [range22]
    exact ${chainAll(tails, "P")}
  nCold := ${thmName(finOf("final_cold"))}.total P
  finalCold := ${thmName(finOf("final_cold"))}.steps P
  nOrd := ${thmName(finOf("final_ord"))}.total P
  finalOrd := ${thmName(finOf("final_ord"))}.steps P

`));
  const gT = "RoutePiecesR F I T tk";
  const grs = groute.map(cc => classTheorem(GR, cc, gT) + "\n").join("");
  G("RouteBundleR", H(["host.sim.compose.Steps", "host.sim.compose.RoutePieces", "host.sim.lin.CoverR", "host.sim.lin.checks.Kv"],
`# The route pieces of the prompts with no Neural Engine forward (generated by \`host/sim/compose/gen.ts restricted\`)

\`RoutePiecesR F I T tk\`: the fields of \`RoutePieces\` the post class \`other\` uses, the same cuts' names.`) +
    GR.structures("RoutePiecesR", "(T : Nat) (tk : Nat → Nat)", "T tk"));
  const one = (k: string) => groute.find(cc => cc.kind === k) ?? fail(`no ${k}`);
  const cutOf = (k: string) => `b_${({ pathA: "pA", pathB: "pB", pathC: "pC" } as Record<string, string>)[k]}_cut`;
  G("RouteStepsR", H(["host.sim.compose.RouteBundleR"],
`# POST and the short paths' prefixes in the post class \`other\` (generated by \`host/sim/compose/gen.ts restricted\`)

\`postStepR\`, \`path*Pre\`: POST and a short path's prefix at every length of the class.`) + sect("{F : Ffi} {I : PrefInvsW F} {T : Nat} {tk : Nat → Nat}", grs + `/-- **POST in the class \`other\`.** -/
theorem postStepR (H : ${gT}) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) (hq : RouteKind.post.Holds L T (tk 1) (tk 2))
    (ha : PostClass.other.Applies L) : CutStep (I.ps L) (I.dec L) (${thmName(one("post"))}.total H) :=
  ${thmName(one("post"))}.steps H L h1 h2 hq ha

${["pathA", "pathB", "pathC"].map(k => `/-- **The ${k} prefix in the class \`other\`.** -/
theorem ${k}Pre (H : ${gT}) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) (hq : RouteKind.${k}.Holds L T (tk 1) (tk 2))
    (ha : PostClass.other.Applies L) :
    CutStep (I.ps L) (H.cuts.${cutOf(k)} (routeI L T (tk 1) (tk 2))) (${thmName(one(k))}.total H) :=
  ${thmName(one(k))}.steps H L h1 h2 hq ha
`).join("\n")}`));
  console.log(`restricted: ${GP.pieces.size} prefill pieces, ${GP.bounds.size} cuts, ${GP.eqs.length} equalities; ${GR.pieces.size} route pieces, ${GR.bounds.size} cuts, ${GR.eqs.length} equalities`);
}

const nP = PB.pieces.size, nR = RB.pieces.size;
if (process.argv[2] === undefined)
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
    const parts = a.split("@");
    const name = parts[0] ?? fail(`decode: ${a}: <chain>@<kind>`);
    const kind = parts[1] ?? fail(`decode: ${a}: <chain>@<kind>`);
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
 * (`<chain>.Grow`, A1's); the call links `callLink` (`host.sim.compose.CallLink`) from A4's site modules
 * (`Site*<k>`, `JClAll`), A3's `Conv.callShift` and kernel checks here, what A4 does not state yet in `<chain>.Calls`;
 * the case's `IterCaseW` at A4's end (`<chain>.iterEnd`, moved by `IterEndW.toFb`), the emitted token
 * (`<chain>.emitTok`) and the counters (`<chain>.within`), all at the prompt route's instance. A
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
  const Pw = jsps[0]![0] ?? fail(`${X}: missing acceptance parameters`);
  const fr = jsps[0]![1] ?? fail(`${X}: missing acceptance frames`);
  const wd = jsps[0]![2] ?? fail(`${X}: missing acceptance wide frames`);
  // the decode loop's frames: `forwarded`, `emitted`, the further ones (every wide frame's address among them)
  const frs = JSON.parse(fr) as number[], wides = [...wd.matchAll(/\((\d+), /g)].map(m => +m[1]!);
  if (wides.some(w => !frs.includes(w))) console.warn(`${X}: the okB frames ${fr} miss the wide frames ${wides} (IterEndW.ShiftFW needs them in Fr.xs)`);
  // the absorbed `emitted` elements of each call: the merged state's array past the chain start's
  const eNs: string[][] = (seg.bridges as any[]).filter(b => b.kind === "stage").map(b => {
    const e = (b.arrs as { a: number; prefix: boolean; els: string[] }[] | undefined)?.find(x => x.a === frs[1])
      ?? fail(`${X}: bridge ${b.ia}: no emitted array past the chain start's`);
    if (!e.prefix) fail(`${X}: bridge ${b.ia}: no emitted array past the chain start's`);
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
  // the prompt route's instance: its addresses, wide frames, further frames (the target's prompt `q`), fixed addresses
  const AP = "Host.Load.Run.Prompt.addrPrompt", WP = "Template.wideP", FP = `(Template.framesP ${t0} q)`, XP = "Template.fixP";
  const P = `b0 NB ${X}.Pw ${X}.fr ${X}.wd ${WP} ${AP} ${FP} ${t0} ${T0}.tab ${XP} toks ΔJ ΔH ΔN`;
  const [fwdA, emitA] = [frs[0]!, frs[1]!];
  // A4's site modules' sources (their data's literals)
  const srcOf = (f: string) => readFileSync(join(tdir, `${f}.lean`), "utf8");
  // the ghost's data (`b0`'s world); its closed form for the kernel's counter checks (the data reads no bridge)
  const ghost = (j: number, nb = "NB", en = `${X}.eN`, bb = "b0") =>
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
  const imps = new Set<string>();
  // a growing case's results: the decode forms of the offset `v9` and the capacity `v16` plus a page (`Conv.decQC`)
  const grows = kind === "grow" || kind === "clearGrow";
  const dQ = grows ? "Conv.decQC 9 16" : "Conv.decQ 9";
  let facts = "", runsS = "", runsV: string[] = [], growV: string[] = [], grow = "", calls = "", callsF = "", links = "";
  links += `  start := startLink [] (by decide +kernel) rfl rfl (${X}.hfr q) hVB
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
    // A4's site data: the compaction map's counters and table length, the results and their forms
    const kap = srcOf(`SiteC${k}`).match(new RegExp(`def ${X}\\.kappa${k} : Map :=\\s*Conv\\.Map\\.compact (\\d+) (\\d+) (\\d+) `)) ??
      fail(`${X}: SiteC${k}: kappa${k} is not \`Conv.Map.compact n0 n1 nS …\``);
    const [kn0, , knS] = [+kap[1]!, +kap[2]!, +kap[3]!];
    const cwsL = JSON.parse((srcOf(`SiteC${k}`).match(new RegExp(`def ${X}\\.cws${k} : List Nat := (\\[[^\\]]*\\])`)) ??
      fail(`${X}: SiteC${k}: cws${k}`))[1]!) as number[];
    const gmeta = JSON.parse(readFileSync(join(sdir, gl.meta), "utf8"));
    const decForm = (e: string) => /^\(v9 add 1\)$|^int32\(v9\)$|^int32\(\(v9 add 1\)\)$|^\(int32\(\(v9 add 1\)\) sub 0\)$/.test(e) ||
      (grows && e === "(v16 add 256)");
    const resOk = ((gmeta.derived ?? []) as [number, string, string][]).every(([v, , e]) => !cwsL.includes(v) || decForm(e));
    if (!varsOf(pieces[2 * j]).some(([v, q]) => v === 9 && q === "o")) fail(`${X}: call ${j}: v9 not at the offset before it`);
    const st = c(`st${k}`), tpl = `${st}.tpl`, cn = (n: string) => c(`${n}${k}`), θ = c("θ");
    const hasKeep = new RegExp(`^theorem ${X}\\.keep${k} `, "m").test(srcOf(`SiteL${k}`));
    // A4's native shift from the call's relation, once built (in `DEVOUT` when given)
    const built = (f: string) => !process.env.DEVOUT || existsSync(join(process.env.DEVOUT, "host/sim/template", dir, `${f}.olean`));
    const hasShR = existsSync(join(tdir, `SiteR${k}.lean`)) && built(`SiteR${k}`) &&
      new RegExp(`^theorem ${X}\\.cshiftR${k} `, "m").test(srcOf(`SiteR${k}`));
    // the canonical state's counters (its roots check's; the bookkeeping's `jcl<b>` at or below them, `JClean.mono`)
    const jclC = srcOf(`SiteZ${k}`).match(new RegExp(`kernel_rfl ${X}\\.zroots2${k} : noBigRootsP \\(fun i => !Conv\\.oldBigB \\(⟨(\\d+), `)) ??
      fail(`${X}: SiteZ${k}: zroots2${k}`);
    if (hasShR) imps.add(`SiteR${k}`);
    facts += `-- call \`${cl.name}\`'s data (A4's site ${k}) in \`callLink\`'s forms
kernel_rfl ${X}.wsl${j} : ${cn("ws")}.length = ${tpl}.S2.tab.length - ${Sa}.tab.length
kernel_rfl ${X}.wsnd${j} : Template.nodupT ${cn("ws")} PTrie.nil = true
kernel_rfl ${X}.fresh${j} : (${Sa}.tab.all fun e => ${cn("ws")}.all fun w => e.noVar w) = true
kernel_rfl ${X}.gtab${j} : (${T0}.tab.all fun e => (${cn("cws")} ++ ${cn("ws")}).all fun w => e.noVar w) = true
kernel_rfl ${X}.gth${j} : (${T0}.tab.all fun e => (${cn("cws")} ++ ${cn("ws")}).all fun w => w == 17 || (e.subst ${θ}).noVar w) = true
kernel_rfl ${X}.big${j} : bigsOutB (mlxOf ${sc}.ffi).next ${X}.Pw.E (mlxOf ${sc}.ffi) = true
kernel_rfl ${X}.kn${j} : Nat.ble ${T0}.tab.length ${knS} = true
kernel_rfl ${X}.ka${j} : (${XP}.all fun a => Nat.blt a ${kn0}) = true
kernel_rfl ${X}.m0_${j} : (${R}.all fun p => (Conv.idx? p.1 ${cn("cws")}).isNone && !${cn("ws")}.contains p.1) = true
kernel_rfl ${X}.ndc${j} : Template.nodupT ${cn("cws")} PTrie.nil = true
kernel_rfl ${X}.lenc${j} : ${cn("cws")}.length = ${cn("nr")}.length
kernel_rfl ${X}.nrLo${j} : ${cn("nr")}.all (Nat.ble ${Sa}.tab.length) = true
kernel_rfl ${X}.xn${j} : Nat.ble ${jclC[1]} (mlxOf ${sc}.ffi).next = true
theorem ${X}.chk${j} : ∀ r ∈ ${rows}, goodLin r.ps (varsOf r.V ${m}) ${st}.O = true := by
  decide +kernel
${resOk ? `/-- Call ${j}'s results' entries and their quantities (\`Conv.decQ\` at the offset \`v9\`). -/
noncomputable def ${X}.Es${j} : List (Option SymE) := ${cn("nr")}.map fun r => nth? ${tpl}.S2.tab r
noncomputable def ${X}.qs${j} : List Q := ${X}.Es${j}.map fun o => (o.bind (${dQ})).getD .o
kernel_rfl ${X}.dq${j} : ${X}.Es${j}.all (fun o => (o.bind (${dQ})).isSome) = true
kernel_rfl ${X}.lq${j} : ${X}.qs${j}.length = ${cn("cws")}.length
kernel_rfl ${X}.qsOk${j} : ${X}.qs${j}.all (fun q => decide (q = .o ∨ q = .e${grows ? " ∨ q = .cap1" : ""})) = true
kernel_rfl ${X}.R'${j} : (${R2}.all fun p => (${R} ++ ${cn("cws")}.zip ${X}.qs${j}).contains p) = true
` : ""}
`;
    const nshift = `Conv.FullShiftQ ${X}.Pw ${Sc}.tab.length ${cn("kappa")} ${sc}.ffi ${sm}.ffi`;
    const res = (f: string) => `${f} : ${f === "hffi"
      ? `∀ (r : List NumV) (M : Map) (y : FF.S), FLRb b0 ${X}.Pw NB r M ${Sa}.tab.length ${sa}.ffi y → ${nshift}`
      : `KeepsAtW ${FP} ${sm}`}`;
    const isOpen = !hasShR || !hasKeep || !resOk;
    if (isOpen) calls += `/-- **Call \`${cl.name}\`'s open facts** (\`${cl.fn}\`, ${cl.steps} target steps; A4's site ${k}): what A4's site
modules do not state yet (the native shift from the call state's relation, the merged state's further frames)${resOk ? "" : `,
the results' quantities (their forms beyond \`Conv.decQ\`'s)`}. -/
structure ${X}.Call${j} (b0 : BSt) (NB : Nat) (q : List Val) (L T : Nat) (tk : Nat → Nat) where
${hasShR ? "" : `  /-- A4's \`cshiftR${k}\` (\`cshift${k}\` at \`ncl${a}\` and the call state's native relation) -/
  ${res("hffi")}
`}${hasKeep ? "" : `  /-- A4's \`keep${k}\` -/
  ${res("hkeep")}
`}${resOk ? "" : `  qs : List Q
  hlq : qs.length = ${cn("cws")}.length
  hqs : qs.all (fun q => decide (q = .o ∨ q = .e)) = true
  hEs : ∀ (i : Cls.Inst) (ν : Nat → F64), DecAt L T tk i → MapOk ν i ${R} → VBOkF loopVB ν →
    ∀ j o, nth? (${cn("nr")}.map fun r => nth? ${tpl}.S2.tab r) j = some o → ∃ E q, o = some E ∧ nth? qs j = some q ∧
      E.eval ν = F64.ofNat (i.get q)
  hR' : ∀ p ∈ ${R2}, p ∈ ${R} ++ ${cn("cws")}.zip qs
`}
`;
    if (isOpen) callsF += `  c${j} : ${X}.Call${j} b0 NB q L T tk\n`;
    const cj = `Cs.c${j}`;
    links += `  ${cl.name} := callLink ${tpl} ${st}.O hW ${X}.chk${j} ${cn("srvO")} ${sub(m, R)}
    (hs0 := ${cn("iso")}) (htab := ${c(`tab0_${k}`)}) (hfoot := ${cn("stFoot")}) (hnd := ${cn("wrNodup")})
    (hbd := ${cn("wrBound")}) (htr := ${cn("trace")}) (hmer := fun _ => ${cn("merged")}) (hmtab := ${cn("mergeTab")})
    (hwsl := ${X}.wsl${j}) (hwsnd := (Template.nodupT_sound ${X}.wsnd${j}).2) (hfresh := noVar_of_all ${X}.fresh${j})
    (hlen := Nat.le_of_ble_eq_true ${X}.len${a}) (hgtab := noVar_nth_of_all ${X}.gtab${j})
    (hgθ := noVarθ_nth_of_all ${X}.gth${j})
    (hgrow := call_ngrow hW ${tpl} ${cn("iso")} ${cn("stFoot")} ${cn("wrNodup")} ${cn("wrBound")} ${cn("trace")})
    (hctab := ${cn("ctab")}) (hdis := disj_of_all ${cn("cwsDisj")}) (hshift := fun x0 x hcf hfq hK hB => ${cn("ctab")} ▸ Conv.callShift ${cn("zkap")}
      (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) ${c(`jcl${a}`)}) ${cn("cfix")} hfq
      rfl rfl ${cn("zpl")} ${cn("zplnd")} ${cn("zn1")} ${cn("zfirst")} ${cn("zscn")} ${cn("zsmn")} ${cn("zgrow")} ${cn("mergeTab")}
      ${cn("zfresh")} ${cn("zcnd")} ${X}.lenc${j} ${cn("znrHi")} ${cn("znC")} ${cn("zfrlt")} xs_wideP wfr_wideP (hX_framesP ${X}.arr4910)
      (kept_of fun a ha => by
        simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
        rcases ha with rfl | rfl | rfl
        ${frs.slice(0, 3).map(fa => `· exact ⟨${c(`zg${k}_${fa}`)}, ${c(`zk${k}_${fa}`)}, ${c(`zm${k}_${fa}`)}⟩`).join("\n        ")})
      (wp_present ${c(`zw${k}_4910`)}) wf_wideP ${cn("zclbd")} ${cn("cheap")}
      (hoff_of ${cn("mheap")} ${cn("stFoot")} ${cn("iso")} ${cn("zwr")}) ${cn("ckeepP")} ${cn("csupp")} ${cn("cbound")} ${cn("zimg")}
      ${cn("zctl")} ${cn("zstack")} ${cn("zjobs")} ${cn("zstores")} ${cn("zroots")} x0 x hcf hK hB.ofFb)
    (hffi := ${hasShR ? `fun _ _ _ h => ${cn("cshiftR")} h rfl` : `${cj}.hffi`})
    (hbig := ${X}.big${j}) (hfree := Conv.jclean_noBigSt (Conv.JClean.mono (Conv.Cnt.le_of_leB (by decide)) ${c(`jcl${a + 2}`)})
      (Nat.le_of_ble_eq_true ${X}.xn${j}) (by decide) ${cn("zroots2")})
    (hband := band_of (Nat.le_of_ble_eq_true ${X}.bandLo${j}) (Nat.le_of_ble_eq_true ${X}.bandHi) (by decide))
    (hκn := compact_num_of ${X}.kn${j}) (hκa := compact_fix_of ${X}.ka${j}) (hκv := Conv.node_of_fixOld ${cn("cfix")} (Nat.le_of_ble_eq_true ${cn("zhm")}))
    (hfwd := ${c(`arr${k}_${fwdA}`)}) (hemit := ${c(`arr${k}_${emitA}`)}) (hkeep := ${hasKeep ? `${cn("keep")} q` : `${cj}.hkeep`})
    (heN := ${c(`arrR${k}_${emitA}`)})
    (hJ := Nat.le_of_ble_eq_true ${X}.cJm${j}) (hJc := Nat.le_of_ble_eq_true ${X}.cJc${j})
    (hH := Nat.le_of_ble_eq_true ${X}.cHm${j}) (hHE := Nat.blt_eq.mp ${X}.cHE${j})
    (hN := Nat.le_of_ble_eq_true ${X}.cNm${j}) (hm0 := m0_of_all ${X}.m0_${j}) (hndc := (Template.nodupT_sound ${X}.ndc${j}).2)
    (hlenc := ${X}.lenc${j}) (hnrLo := ${X}.nrLo${j}) (hder := rfl)
    ${resOk ? `(qs := ${X}.qs${j}) (hlq := ${X}.lq${j}) (hEs := ${grows ? `hEs_of_allC dec_${kind}.capRow (by decide) (by decide)`
      : "hEs_of_all (by decide)"} ${X}.dq${j})
    (hq := ${grows ? `qs_leC dec_${kind}.capRow` : "qs_le"} ${X}.qsOk${j}) (hR' := sub_of_all ${X}.R'${j})`
      : `(qs := ${cj}.qs) (hlq := ${cj}.hlq) (hEs := ${cj}.hEs) (hq := qs_le ${cj}.hqs) (hR' := ${cj}.hR')`}
    (dJ := ${dJ}) (dH := ${dH}) (dN := ${dN}) (hdJ := hdJ) (hdH := hdH)
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
      if (us.some(u => u !== "9" && !(grows && u === "16"))) fail(`${X}: ${gl.glue}: results of variables ${us}`);
      dec = der.length ? { vs: der.map(([v]) => v), u: 9, m: mA } : undefined;
      links += dec
        ? `  ${gl.glue} := glueLinkEndD ${O} hW ${X}.chk_${gl.glue} ${X}.srv${f} ${X}.ok${f} R.${rn}
    ${X}.top${t} ${c("dvs")} ${c("des")} (e := (${c("iterEnd")} NB).toFb b0) rfl ${X}.hS1D
    ${grows ? `(hde_of_decC dec_${kind}.capRow ${X}.hvsB (by decide) (by decide))` : `(hde_of_dec ${X}.hvsB (by decide))`}
    (Nat.le_of_ble_eq_true ${X}.len${f}) Gw.${gl.glue}\n`
        : `  ${gl.glue} := glueLinkEnd ${O} hW ${X}.chk_${gl.glue} ${X}.srv${f} ${X}.ok${f} R.${rn}
    ${X}.top${t} (e := (${c("iterEnd")} NB).toFb b0) rfl rfl (Nat.le_of_ble_eq_true ${X}.len${f}) Gw.${gl.glue}\n`;
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
${[...new Set([...(dec ? [desMod] : []), eRMod, ...(endMod ? [endMod] : [])])].map(m => `import ${mod}.${m}\n`).join("")}${withRun ? `import ${mod}.Run\n` : ""}${ia.map((_, k) => `import ${mod}.st${k}.Tpl\nimport ${mod}.SiteL${k}\nimport ${mod}.SiteD${k}\nimport ${mod}.SiteZ${k}\n`).join("")}import ${mod}.JClAll
${[...imps].map(m => `import ${mod}.${m}\n`).join("")}set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace ${NS}
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers
  Host.Ts.Sim.Template

/-! # Decode case \`${kind}\`'s pieces from A4's chain \`${X}\` (generated by \`host/sim/compose/gen.ts fill\`)

Scratch, unregistered: it imports A4's chain modules (\`${mod}\`). The decode world: the target's bridge pinned to
\`b0\` (\`fullWorldFb b0 NB\`). \`${X}.pieces\`: \`DecPieces_${X}\` at the chain's boundaries (\`host.sim.compose.ChainFill\`'s \`bdCut\`, each at the variables known there, the ghost
\`${X}.g<j>\` after \`j\` compactions, absorbing \`emitted\`'s elements \`eN j\`); the start and glue links from A4's
runs (\`${X}.Runs\`${withRun ? `, \`${X}.runs\`` : ""}), the boundary facts below and the pinned decode world's growth along the runs
(\`${X}.Grow\`, A1's); the call links \`callLink\` (\`host.sim.compose.CallLink\`) from A4's site modules, A3's
\`Conv.callShift\` and the kernel checks below${callsF ? `, the calls' open facts in \`${X}.Calls\`` : ""}. All at the prompt route's instance
(\`addrPrompt\`, \`wideP\`, the frames \`framesP ${X}.s0 q\`, \`fixP\`). \`${X}.case\`: the case's \`IterCaseW\` at A4's end
(\`${X}.iterEnd\` in the full world, moved by \`IterEndW.toFb\`; \`${X}.shiftFW\`, \`${X}.keep\`), the emitted token
(\`${X}.emitTok\`) and the counters (\`${X}.within\`: the ghost's \`dJ ${dJ}\`, \`dH ${dH}\`, \`dN ${dN}\`, the growth absorbed by the compactions
included; seg.json's canonical deltas \`${seg.counters.dJ}\`, \`${seg.counters.dH}\`, \`${seg.counters.dN}\`). -/

/-- The chain's acceptance parameters (its \`okB<k>\`'s \`Template.fullJSPP\`). -/
abbrev ${X}.Pw : LoadP := ${Pw}
abbrev ${X}.fr : List Nat := ${fr}
abbrev ${X}.wd : List (Nat × WFrame) := ${wd}
/-- The \`emitted\` elements each call's compaction absorbs (A4's merged states' \`emitted\` past the chain start's, the
canonical states resetting it). -/
def ${X}.eN : Nat → List Val
${eNs.map((_, j) => `  | ${j} => ${c(`arrEl${j}_${emitA}`)}`).join("\n")}
  | _ => []

/-- The pieces' variable maps (the chains' spec). -/
${maps.map((l, k) => `def ${X}.m${k} : List (Nat × Q) := ${l}`).join("\n")}

${dec ? `-- A4's end results (\`${X}.dvs\`) and terms (\`${X}.des\`): each a decode form of \`v${dec.u}\` (\`Conv.decQ\`) at a
-- quantity the last glue piece's map holds it
kernel_rfl ${X}.hvsB : (${c("dvs")}.zip ${c("des")}).all (fun p => match ${dQ} p.2 with
  | some q => ${dec.m}.contains (p.1, q) | none => false) = true

` : ""}
/-! ## The ghost -/

${ghosts}
/-! ## The boundary facts -/

kernel_rfl ${X}.bandHi : Nat.ble ${X}.Pw.E ${DJ}.hi = true
kernel_rfl ${X}.arr4910 : arrOf ${t0} 4910 = []
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

${callsF ? `${calls}/-- **The calls' open facts.** -/
structure ${X}.Calls (b0 : BSt) (NB : Nat) (q : List Val) (L T : Nat) (tk : Nat → Nat) where
${callsF}
` : ""}${dec ? `-- A4's end server: the canonical results back to their terms
kernel_rfl ${X}.hS1D : ${c("S1D")} = ⟨${c(`S${end}`)}.tab.map (·.subst (Conv.compactθ ${c("dvs")} ${c("des")})), ${c(`S${end}`)}.oracle⟩

` : ""}/-- **The emitted token** after the compactions' absorbed elements and the end's. -/
theorem ${X}.emitTok (b0 : BSt) (NB : Nat) :
    (${X}.g${nCalls} b0 NB ${X}.eN).eA ++ ${c("eR")} = [.num (.ref ${AP}.tok)] := rfl

/-- The prompt route's wide frames are the acceptance's. -/
theorem ${X}.hW : Disp.Wp ${DJ} ${WP} := fun _ _ h => h

/-- The decode loop's frames at the prompt route's: the chain's acceptance's. -/
theorem ${X}.hfr (q : List Val) : ∀ a, a ∈ ${AP}.fwd :: ${AP}.emit :: ${FP}.xs ↔ a ∈ ${X}.fr := fun _ => Iff.rfl

section
variable {b0 : BSt} {NB : Nat} {toks : List NumV} {L T : Nat} {tk : Nat → Nat} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}

/-- **Decode case \`${kind}\`'s pieces from chain \`${X}\`** at the prompt route's instance (\`addrPrompt\`, \`wideP\`, the
frames \`framesP ${X}.s0 q\`, \`fixP\`), A4's end (\`${X}.iterEnd\`). -/
noncomputable def ${X}.pieces (q : List Val) (R : ${X}.Runs)${callsF ? ` (Cs : ${X}.Calls b0 NB q L T tk)` : ""}
    (hVB : ∀ i nx, nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (hdJ : ${dJ} ≤ ΔJ) (hdH : ${dH} ≤ ΔH) (hdN : ${dN} ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf ${t0}.ffi).next + T * ΔH + B.H + (${X}.Pw.E - (mlxOf ${t0}.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf ${t0}.ffi).nnext + T * ΔN + B.N + (${X}.Pw.NE - (mlxOf ${t0}.ffi).nnext) < 2 ^ 62) :
    DecPieces_${X} (fullWorldFb b0 NB) ${AP} ${WP} ${X}.Pw ${FP} ${t0} ${T0}.tab ${XP} (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      L T ((${c("iterEnd")} NB).toFb b0) (${X}.g${nCalls} b0 NB ${X}.eN) :=
  let θ := ${c("θ")}
  let hW := ${X}.hW
  let Gw : ${X}.Grow b0 NB ${WP} := ${X}.grow R hW
  { ${cutB.map(([b, j, m], k) => `c${k + 1} := ${cut(b, j, m)}`).join("\n    ")}
${links.replace(/^ {2}/gm, "    ")}  }

/-- **Decode case \`${kind}\` from chain \`${X}\`** (\`IterCaseW\`) at the prompt route's instance, A4's end facts
(\`${X}.iterEnd\`, \`${X}.shiftFW\`, \`${X}.keep\`). -/
noncomputable def ${X}.case (q : List Val)${withRun ? "" : ` (R : ${X}.Runs)`}${callsF ? ` (Cs : ${X}.Calls b0 NB q L T tk)` : ""}
    (hVB : ∀ i nx, nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ : ${dJ} ≤ ΔJ) (hH : ${dH} ≤ ΔH) (hN : ${dN} ≤ ΔN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf ${t0}.ffi).next + T * ΔH + B.H + (${X}.Pw.E - (mlxOf ${t0}.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf ${t0}.ffi).nnext + T * ΔN + B.N + (${X}.Pw.NE - (mlxOf ${t0}.ffi).nnext) < 2 ^ 62) :
    IterCaseW (fullWorldFb b0 NB) ${AP} ${WP} ${X}.Pw ${FP} ${t0} ${T0}.tab ${XP} (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DecSel T L tk .${kind}) where
  e := (${c("iterEnd")} NB).toFb b0
  g := ${X}.g${nCalls} b0 NB ${X}.eN
  chain := (${X}.pieces (E0 := E0) (B := B) q ${withRun ? `${X}.runs` : "R"}${callsF ? " Cs" : ""} hVB hJ hH hN hJb hHb hNb).chain h1 hctx
  sh := ${c("shiftFW")} NB q
  keep := ${c("keep")} q
  emit := ${X}.emitTok b0 NB
  within := ${X}.within (e := (${c("iterEnd")} NB).toFb b0) ${X}.eN rfl hJ hH hN

end

end ${NS}
`;
  mkdirSync(dirname(outFile), { recursive: true });
  writeFileSync(outFile, s);
  console.log(`${X}: ${outFile}`);
}

if (process.argv[2] === "fill") genFill(process.argv.slice(3));

/* ---------- Prefill boundaries and checked call sites ---------- */

/** A merged chain's members live in `m/<bundle>` (`template/genMerge.ts`, `m/members.json`). */
const memberMaps = new Map<string, Record<string, string> | null>();
const membersOf = (dir: string) => {
  let map = memberMaps.get(dir);
  if (map === undefined) {
    const f = join(HERE, "../template", dir, "m/members.json");
    map = existsSync(f) ? JSON.parse(readFileSync(f, "utf8")) as Record<string, string> : null;
    memberMaps.set(dir, map);
  }
  return map;
};
const bundled = (imp: string): string => {
  const m = imp.match(/^host\.sim\.template\.(a4pre_[^.]+)\.(.+)$/);
  const b = m && membersOf(m[1]!)?.[m[2]!.replaceAll(".", "/")];
  return b ? `host.sim.template.${m![1]}.m.${b}` : imp;
};
/** A member's text: its file, or its section of its bundle; `Run` was never bundled (`m/Run.txt`). */
const memberSrc = (dir: string, f: string): string => {
  const tdir = join(HERE, "../template", dir), map = membersOf(dir);
  if (f === "Run" && existsSync(join(tdir, "m/Run.txt"))) return readFileSync(join(tdir, "m/Run.txt"), "utf8");
  const b = map?.[f];
  if (!b) return readFileSync(join(tdir, `${f}.lean`), "utf8");
  const text = readFileSync(join(tdir, "m", `${b}.lean`), "utf8");
  const at = text.indexOf(`section -- ${f}\n`);
  if (at < 0) fail(`${dir}: no section ${f} in ${b}`);
  const end = text.indexOf("\nsection -- ", at + 1);
  return end < 0 ? text.slice(at) : text.slice(at, end);
};

function genSetupFill(output: string, X: string, mod: string, h: number, stage: any, bridge: any) {
  const cp = bridge.compaction;
  const C = 2048 / 2 ** h;
  if (!cp || cp.pl.length || cp.nr.length || cp.ws.length || cp.n0 !== 2673336 || cp.nS !== 10 ||
      cp.xn0 !== 18155 || cp.xn1 !== 18155 || cp.nn0 !== 15235 || cp.nn1 !== 15235 ||
      cp.n1 <= cp.n0 || cp.n1 - cp.n0 > 4096)
    fail("prefill: setup fill needs the shared fixed-load chunk seam and empty compacted results");
  const root = resolve(HERE, "../../..");
  const outFile = resolve(output), rel = relative(root, outFile);
  if (rel.startsWith("..") || !rel.endsWith(".lean"))
    fail("prefill: setup fills need --out under proofs/; use --sites-only for another destination");
  const outMod = rel.slice(0, -5).replaceAll("/", "."), dirMod = outMod.slice(0, outMod.lastIndexOf("."));
  const outDir = dirname(outFile), cls = `SetupH${h}`;
  // These are checked Lean proof templates. Substitute exact names and whole
  // decimal literals, preserving the old K8 reference proof used at the seam.
  const render = (source: string) => source
    .replaceAll("host.sim.compose.a4b.PrefillSetupH1", outMod)
    .replaceAll("host.sim.compose.a4b.SetupH1Data", `${dirMod}.${cls}Data`)
    .replaceAll("host.sim.compose.a4b.SetupH1", `${dirMod}.${cls}`)
    .replaceAll("host.sim.template.a4pre_setup_h1_chunk", mod)
    .replaceAll("PRE_setup_h1_chunk", X)
    .replaceAll("setup_h1", `setup_h${h}`)
    .replaceAll("SetupH1", cls)
    .replaceAll("K1024", `K${C}`)
    .replace(/\b1024\b/g, String(C))
    .replace(/\b2674514\b/g, String(cp.n1))
    .replace(/\b1178\b/g, String(cp.n1 - cp.n0))
    .replaceAll(`${X}.st0.S3`, `${X}.st0.S${stage.T1}`)
    .replace(new RegExp(`${X.replaceAll(".", "\\.")}\\.(s|S)([012])\\b`, "g"),
      (_, s, k) => `${X}.${s}${bridge.ia + +k}`);
  const files = ["SetupH1Data", "SetupH1", "FillSetupH1"].map(name => ({
    name: name.replace("SetupH1", cls), source: render(readFileSync(join(HERE, `a4b/${name}.lean`), "utf8")),
  }));
  if (h === 0) {
    const data = files[0]!;
    data.source = data.source.replace(`${mod}.Canonical`, `${mod}.SharedStart`)
      .replace(/theorem startEq[\s\S]*?(?=theorem callClean)/, `theorem startEq : (${X}.s4 : St FF.S) = PRE_setup_early_r0.s4 :=
  ${X}.call0_eq
theorem startTab : ${X}.S4.tab = PRE_setup_early_r0.S4.tab := ${X}.call0_tab_eq
private theorem ret_same {S : Type} {s : St S} {v : Val} (hc : s.ctl = .ret v) : s.ret v = s := by
  cases s
  cases hc
  rfl
theorem canonicalEq : (${X}.s6 : St FF.S) =
    (PRE_setup_early_r0.s6 : St FF.S).ret (.num (.lit (F64.ofNat 2048))) :=
  (show (${X}.s6 : St FF.S) = PRE_setup_early_r0.s6 from ${X}.chunk0_eq).trans
    (ret_same SetupChunk.chunkLiteral6).symm
theorem canonicalTab : ${X}.S6.tab = PRE_setup_early_r0.S6.tab := ${X}.chunk0_tab_eq

`);
    const main = files[1]!;
    main.source = main.source
      .replace("kernel_rfl sourcePromptEmpty :", `kernel_rfl chainPromptEmpty : arrOf ${X}.s0 2665 = []\n\nkernel_rfl sourcePromptEmpty :`)
      .replace(`[${X}.zk0_2665, sourcePromptEmpty]`, `[${X}.zk0_2665, chainPromptEmpty]`)
      .replaceAll("[sourcePromptEmpty,", "[chainPromptEmpty, sourcePromptEmpty,");
  }
  for (const f of files) writeFileSync(join(outDir, `${f.name}.lean`), f.source);
  const check = join(root, "check.ts");
  const paths = [rel, ...files.map(f => relative(root, join(outDir, `${f.name}.lean`)))];
  const registry = readFileSync(check, "utf8");
  const missing = paths.filter(p => !registry.includes(JSON.stringify(p)));
  if (missing.length) {
    const anchor = '  "host/sim/compose/a4b/FillSetupH1.lean",';
    if (!registry.includes(anchor)) fail("prefill: missing setup registration anchor in check.ts");
    writeFileSync(check, registry.replace(anchor, `${anchor}\n${missing.map(p => `  ${JSON.stringify(p)},`).join("\n")}`));
  }
  console.log(`${X}: concrete ${cls}.chunk_K${C}__g0a__g0b emitted in ${files[2]!.name}.lean`);
}

function genSingletonFill(output: string, X: string, stages: any[]) {
  if (X !== "D1StageSplit" || stages.length !== 2 ||
      stages[0].stage.name !== "nps_FIN_first__start__g1_FIN_first" ||
      stages[1].stage.name !== "disp_D1__g1_FIN_first__g2_fin_first") return;
  const file = join(dirname(output), "FillD1First.lean");
  writeFileSync(file, `import host.sim.compose.a4b.D1G3f
namespace Host.Ts.Sim.Compose.FillD1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def pc0 := SetupCommon.nextCut
noncomputable def b_g1_FIN_first_i := D1First.g1Cut
noncomputable def b_g1_FIN_first_o := D1First.dispatchCut
noncomputable def b_g2_fin_first_i := D1First.g2Cut
noncomputable def b_g2_fin_first_o := D1First.forwardCut
noncomputable def b_g3f_first_i (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (Mem : Nat → SegInst FF → Prop) : ICut FF :=
  withMem (Mem 1) (D1First.returnedPromptCut NB T tk π)

noncomputable def nps_FIN_first__start__g1_FIN_first := D1First.nps_FIN_first__start__g1_FIN_first
noncomputable def g1_FIN_first := D1First.g1_FIN_first
noncomputable def disp_D1__g1_FIN_first__g2_fin_first := D1First.disp_D1__g1_FIN_first__g2_fin_first
noncomputable def g2_fin_first := D1First.g2_fin_first
noncomputable def fwd_D1_cold_DFirst__g2_fin_first__g3f_first := D1First.fwd_D1_cold_DFirst__g2_fin_first__g3f_first
noncomputable def g3f_first := D1First.g3f_first
end Host.Ts.Sim.Compose.FillD1First
`);
  const root = resolve(HERE, "../../..");
  const rel = relative(root, file);
  const check = join(root, "check.ts");
  const registry = readFileSync(check, "utf8");
  if (!registry.includes(JSON.stringify(rel))) {
    const anchor = '  "host/sim/compose/a4b/D1G2.lean",';
    if (!registry.includes(anchor)) fail("prefill: missing singleton registration anchor in check.ts");
    writeFileSync(check, registry.replace(anchor, anchor + "\n  " + JSON.stringify(rel) + ","));
  }
  console.log(X + ": concrete singleton prefix fills emitted in " + file);
}

function genVWPrefixFill(output: string, X: string, stages: any[]) {
  if (X !== "PRE_first_tail_x15_r0" || stages.length !== 3 ||
      String(stages[1].stage.name).replace("__g0b__", "__start__") !== "nps_DTtail_first__start__g1_DTtail_first" ||
      stages[2].stage.name !== "disp_VW__g1_DTtail_first__g2_first") return;
  const file = join(dirname(output), "FillVWFirst.lean");
  writeFileSync(file, `import host.sim.compose.a4b.VWDispatch
import host.sim.compose.a4b.VWG2
namespace Host.Ts.Sim.Compose.FillVWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def pc0 := SetupCommon.nextCut
noncomputable def b_g1_DTtail_first_i := VWFirst.afterNpsCut
noncomputable def b_g1_DTtail_first_o := VWFirst.dispatchCut
noncomputable def b_g2_first_i := VWFirst.g2Cut
noncomputable def b_g2_first_o := VWFirst.forwardCut

noncomputable def nps_DTtail_first__start__g1_DTtail_first := VWFirst.nps_DTtail_first__start__g1_DTtail_first
noncomputable def g1_DTtail_first := VWFirst.g1_DTtail_first
noncomputable def disp_VW__g1_DTtail_first__g2_first := VWFirst.disp_VW__g1_DTtail_first__g2_first
noncomputable def g2_first := VWFirst.g2_first
end Host.Ts.Sim.Compose.FillVWFirst
`);
  const root = resolve(HERE, "../../..");
  const rel = relative(root, file);
  const check = join(root, "check.ts");
  const registry = readFileSync(check, "utf8");
  if (!registry.includes(JSON.stringify(rel))) {
    const anchor = '  "host/sim/compose/a4b/VWG2.lean",';
    if (!registry.includes(anchor)) fail("prefill: missing VW registration anchor in check.ts");
    writeFileSync(check, registry.replace(anchor, anchor + "\n  " + JSON.stringify(rel) + ","));
  }
  console.log(X + ": concrete first-tail prefix fills emitted in " + file);
}

function genPrefill(args: string[]) {
  const oracleAt = args.indexOf("--oracles-only"), oraclesOnly = oracleAt >= 0;
  if (oraclesOnly) args.splice(oracleAt, 1);
  const onlyAt = args.indexOf("--sites-only"), sitesOnly = onlyAt >= 0 || oraclesOnly;
  if (onlyAt >= 0) args.splice(onlyAt, 1);
  const typedAt = args.indexOf("--typed-body"), typedBody = typedAt >= 0;
  if (typedBody) args.splice(typedAt, 1);
  const take = (flag: string) => {
    const i = args.indexOf(flag);
    if (i < 0) return undefined;
    if (!args[i + 1]) fail(`prefill: ${flag} needs a value`);
    return args.splice(i, 2)[1];
  };
  const output = take("--out") ?? fail("prefill: --out <file>");
  const specFile = take("--spec");
  const ownerName = take("--piece");
  const rowsArg = take("--rows")?.split(",");
  const siteArg = take("--site");
  const oneSite = siteArg === undefined ? undefined : Number(siteArg);
  if (oneSite !== undefined && (!Number.isSafeInteger(oneSite) || oneSite < 0))
    fail("prefill: --site requires a nonnegative integer");
  const streams = take("--streams") ?? process.env.HOST_STREAM_DIR ?? join(HERE, "../../../.host-stream");
  if (args.length !== 1) fail("prefill: <chain>:<case-dir>");
  const match = args[0]!.match(/^([^:]+):(.+)$/) ?? fail("prefill: <chain>:<case-dir>");
  const [, inputName, dir] = match;
  const fullName = inputName!.startsWith("Host.") ? inputName! : `Host.Load.Run.Tpl.${inputName}`;
  const stream = join(streams, fullName);
  const chain = JSON.parse(readFileSync(join(stream, "chain.json"), "utf8"));
  const seg = JSON.parse(readFileSync(join(stream, "seg.json"), "utf8"));
  if (chain.world !== "full" || seg.world !== "full") fail("prefill: a full-world chain is required");
  if (chain.chain !== fullName) fail(`prefill: stream belongs to ${chain.chain}, not ${fullName}`);
  const forwardOwners = [...PB.pieces.values()].filter(p => p.kind === "fwd" && p.uses.includes(chain.row));
  const owner = ownerName ? PB.pieces.get(ownerName) : chain.stop === "ret" && forwardOwners.length === 1 ? forwardOwners[0] : undefined;
  if (ownerName && !owner) fail(`prefill: unknown bundle piece ${ownerName}`);
  if (owner && !owner.uses.includes(chain.row)) fail(`prefill: ${owner.name} does not use ${chain.row}`);
  const defaultRows = rowsArg ?? owner?.uses ?? [chain.row];
  const X = fullName.split(".").pop()!;
  const c = (name: string) => `${fullName}.${name}`;
  const mod = `host.sim.template.${dir!.replaceAll("/", ".")}`;
  const spec = specFile ? JSON.parse(readFileSync(specFile, "utf8")) : undefined;
  const maps = new Map<string, [number, string][]>((spec?.pieces ?? []).map((p: any) => [p.id, p.vars]));
  const enums = new Set<string>(spec?.enum ?? []);
  const skippedDerived = new Set<number>();
  const row = table.classes.flatMap((c: any) => c.rows).find((r: any) => r.id === chain.row);
  type Affine = { c: number; cs: number[] };
  const normalize = (a: Affine): Affine => {
    const cs = [...a.cs];
    while (cs.at(-1) === 0) cs.pop();
    if (![a.c, ...cs].every(Number.isSafeInteger)) fail("prefill: affine expression exceeds exact integer arithmetic; supply --spec");
    return { c: a.c, cs };
  };
  const derivedMap = (meta: any): [number, string][] => {
    const vars: [number, string][] = [...(meta.vars ?? [])];
    if (!(meta.derived?.length)) return vars;
    if (!row) fail(`prefill: no class-table row ${chain.row}; supply --spec`);
    const env = new Map<number, Affine>(vars.map(([v, q]) => [v, normalize(row.forms[q] ?? fail(`prefill: no form for ${q}`))]));
    const combine = (a: Affine, b: Affine, sign: number): Affine => normalize({
      c: a.c + sign * b.c,
      cs: Array.from({ length: Math.max(a.cs.length, b.cs.length) }, (_, j) => (a.cs[j] ?? 0) + sign * (b.cs[j] ?? 0)),
    });
    const parse = (source: string): Affine => {
      const tokens = source.match(/v\d+|-?\d+|[A-Za-z][A-Za-z0-9]*|[()]/g) ?? [];
      let at = 0;
      const expr = (): Affine => {
        const token = tokens[at++];
        if (token === "int32" || token === "trunc") {
          if (tokens[at++] !== "(") fail(`prefill: invalid derived expression ${source}`);
          const a = expr();
          if (tokens[at++] !== ")") fail(`prefill: invalid derived expression ${source}`);
          return a;
        }
        if (token === "(") {
          const a = expr(), op = tokens[at++], b = expr();
          if (tokens[at++] !== ")") fail(`prefill: invalid derived expression ${source}`);
          if (op === "add") return combine(a, b, 1);
          if (op === "sub") return combine(a, b, -1);
          if (op === "mul" && (!a.cs.length || !b.cs.length)) {
            const scale = a.cs.length ? b.c : a.c;
            const term = a.cs.length ? a : b;
            return normalize({ c: scale * term.c, cs: term.cs.map(c => scale * c) });
          }
          fail(`prefill: non-affine derived expression ${source}; supply --spec`);
        }
        if (token && /^v\d+$/.test(token)) return env.get(+token.slice(1)) ?? fail(`prefill: unmapped ${token} in ${source}; supply --spec`);
        if (token && /^-?\d+$/.test(token)) return { c: +token, cs: [] };
        fail(`prefill: unsupported derived expression ${source}; supply --spec`);
      };
      const a = expr();
      if (at !== tokens.length) fail(`prefill: trailing derived expression ${source}; supply --spec`);
      return a;
    };
    const quantities = ["n", "e", "C", "cap1", "o", "L", "cap", "k", "T", "t1", "t2", "kp"];
    for (const [v, , expression] of meta.derived as [number, string, string][]) {
      let a: Affine;
      try { a = parse(expression); }
      catch { skippedDerived.add(v); continue; }
      env.set(v, a);
      const q = quantities.find(q => row.forms[q] && JSON.stringify(normalize(row.forms[q])) === JSON.stringify(a));
      // A canonical value can be a constant or another derived expression,
      // rather than one of the schedule's quantities. The emitted oracle
      // check verifies whether the retained quantity map is sufficient.
      if (!q) { skippedDerived.add(v); continue; }
      const old = vars.findIndex(([w]) => w === v);
      if (old < 0) vars.push([v, q]); else vars[old] = [v, q];
    }
    return vars;
  };
  const mapped = (name: string, fallback: [number, string][]) => {
    const vars = maps.get(`${X}.${name}`) ?? fallback;
    if (vars.some(([v, q]) => !Number.isInteger(v) || v < 9 || !/^[A-Za-z][A-Za-z0-9]*$/.test(q)))
      fail(`prefill: ${name}: quantity variables must be >=9`);
    if (new Set(vars.map(([v]) => v)).size !== vars.length) fail(`prefill: ${name}: duplicate variable`);
    return `[${vars.map(([v, q]) => `(${v}, Q.${q})`).join(", ")}]`;
  };
  const imports = new Set(["host.sim.compose.PreCall", "host.sim.lin.Table", `${mod}.States`]);
  const bridges = seg.bridges.filter((b: any) => b.kind === "stage");
  const stages = chain.pieces.filter((p: any) => p.stage);
  if (stages.length !== bridges.length) fail("prefill: stage/bridge count mismatch");
  if (oneSite !== undefined && !stages.some((p: any) => p.stage.site === oneSite))
    fail(`prefill: no site ${oneSite} in ${X}`);
  const bundlePiece = (stage: any) => {
    const exact = PB.pieces.get(stage.name);
    if (exact) return exact;
    if (stage.piece === "chunk") return PB.pieces.get(`${stage.stage}__g0a__g0b`);
    // A chain starting at load still calls the first nps after g0b; the bundle
    // starts that step at I.pc0 and calls the preceding glue `start`.
    const atStart = String(stage.name).replace("__g0b__", "__start__");
    return PB.pieces.get(atStart);
  };
  const oracleBlocks: { code: string; imports: string[] }[] = [];
  let code = "", previousVars: [number, string][] = [];
  let emittedSites = 0, emittedGlues = 0;
  for (const p of chain.pieces) {
    if (p.glue !== undefined) {
      const meta = JSON.parse(readFileSync(join(stream, p.meta), "utf8"));
      previousVars = maps.get(`${X}.${p.glue}`) ?? derivedMap(meta);
      if (oneSite !== undefined) continue;
      emittedGlues++;
      const m = mapped(p.glue, previousVars);
      const piece = PB.pieces.get(p.glue);
      const rows = `[${(rowsArg ?? piece?.uses ?? defaultRows).join(", ")}]`;
      // The actual call boundary is the bridge's ia; glue metadata ends before its entry step.
      const call = bridges.find((b: any) => b.ia === p.to + 1);
      const end = call ? call.ia : p.to;
      code += `def ${X}.map_${p.glue} : List (Nat × Q) := ${m}\n\n`;
      for (const [side, boundary] of (oraclesOnly ? [] : [["i", p.from], ["o", end]]) as readonly (readonly [string, number])[]) {
        code += `noncomputable def ${X}.cut_${p.glue}_${side}
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W ${X}.map_${p.glue} ${c(`s${boundary}`)} ${c(`S${boundary}`)} i with B := book i }\n\n`;
      }
      const check = enums.has(`${X}.${p.glue}`) ? "goodEnum" : "goodLin";
      code += `kernel_rfl ${X}.chk_${p.glue} : (${rows}.all fun r =>
  ${check} r.ps (varsOf r.V ${X}.map_${p.glue}) (${meta.oracle})) = true\n\n`;
      if (oraclesOnly) { oracleBlocks.push({ code, imports: [] }); code = ""; }
      continue;
    }
    const stage = p.stage;
    const b = bridges.find((b: any) => b.site === stage.site) ?? fail(`prefill: no bridge for site ${stage.site}`);
    const k = stage.site as number, a = b.ia as number;
    if (oneSite !== undefined && k !== oneSite) continue;
    emittedSites++;
    for (const file of (oraclesOnly ? [`st${k}.H0`] : [`SiteL${k}`, `st${k}.${typedBody ? "TypedTpl" : "Tpl"}`])) imports.add(`${mod}.${file}`);
    const stageName = c(`st${k}`);
    const ok = typedBody ? `(${stageName}.bodyOkL bytes rows)` : `${stageName}.okL`;
    const tpl = typedBody ? `(${stageName}.bodyTpl bytes rows)` : `${stageName}.tpl`;
    const local = typedBody ? `${stageName}.bodyLocal bytes rows` : `${stageName}.loc`;
    const fullMap = mapped(stage.name, previousVars);
    const piece = bundlePiece(stage);
    const rows = `[${(rowsArg ?? piece?.uses ?? defaultRows).join(", ")}]`;
    const check = stage.piece === "plan" || enums.has(`${X}.site${k}`) ? "goodEnum" : "goodLin";
    // Enumeration follows the first parameter read by the map. An unrelated
    // prompt variable can have a huge range while this site's rows are fixed.
    const m = check === "goodEnum" ? `(${fullMap}).filter (fun p => ${c(`st${k}`)}.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))` : fullMap;
    code += `${check === "goodEnum" ? "noncomputable " : ""}def ${X}.map_site${k} : List (Nat × Q) := ${m}

kernel_rfl ${X}.chk_site${k} : (${rows}.all fun r =>
  ${check} r.ps (varsOf r.V ${X}.map_site${k}) ${c(`st${k}`)}.S0.oracle) = true

`;
    if (oraclesOnly) { oracleBlocks.push({ code, imports: [`${mod}.st${k}.H0`] }); code = ""; continue; }
    code += `noncomputable def ${X}.site${k}
${typedBody ? "    (bytes : List Byte) (rows : Nat)\n" : ""}\
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR ${ok} Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W ${ok} ${c(`s${a}`)} ${c(`s${a + 1}`)} ${c(`S${a}`)} ${c(`ws${k}`)} where
  tpl := ${tpl}
  wr := ${c(`st${k}`)}.wr
  start := ${c(`iso${k}`)}
  tab := ${c(`tab0_${k}`)}
  sim := hsim
  localOk := ${local}
  foot := ${c(`stFoot${k}`)}
  nodup := ${c(`wrNodup${k}`)}
  bound := ${c(`wrBound${k}`)}
  trace := ${c(`trace${k}`)}
  merged := ${c(`merged${k}`)}
  len := by
    change ${c(`ws${k}`)}.length = ${tpl}.S2.tab.length - ${c(`S${a}`)}.tab.length
    rw [← ${c(`tab0_${k}`)}]
    exact ${c(`mergeLen${k}`)}.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := ${c(`fresh${k}`)}
    simp only [Bool.and_eq_true] at h
    exact h.1)

`;
  }
  if (chain.row === "setup_early.r0" && stages.length === 1 && stages[0].stage.name === "chunk_K8__g0a__g0b") {
    imports.add("host.sim.compose.a4b.FillSetupEarly");
    code += `/-- The bundle uses the shared PRE_g0b template after the zero-step C seam. -/
noncomputable def ${X}.b_g0a_o (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  withMem (Mem i.L) (withSetupPin T tk π (SetupChunk.chunkCallFixedCut NB T tk i.L))
noncomputable def ${X}.b_g0b_i (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (Mem : Nat → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  withMem (Mem i.L) (SetupCommon.cut NB T tk π Host.Load.Run.Tpl.PRE_g0b.s0 Host.Load.Run.Tpl.PRE_g0b.S0 i)
noncomputable def ${X}.pc0 := SetupCommon.nextCut

noncomputable def ${X}.g0a := FillSetupEarly.g0a
noncomputable def ${X}.chunk_K8__g0a__g0b := FillSetupEarly.chunk_K8__g0a__g0b
noncomputable def ${X}.g0b := FillSetupEarly.g0b
`;
  }
  const render = (deps: Iterable<string>, body: string) => `${[...new Set([...deps].map(bundled))].map(x => `import ${x}`).join("\n")}
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace ${oraclesOnly ? `${NS}.Oracles` : NS}
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

${body}
end ${oraclesOnly ? `${NS}.Oracles` : NS}
`;
  mkdirSync(dirname(output), { recursive: true });
  if (oraclesOnly) {
    const root = resolve(HERE, "../../..");
    const leaves: string[] = [];
    for (let at = 0; at < oracleBlocks.length; at += 8) {
      const batch = oracleBlocks.slice(at, at + 8);
      const leaf = output.replace(/\.lean$/, `_${at / 8}.lean`);
      const deps = new Set(["host.sim.compose.PreCall", "host.sim.lin.Table", `${mod}.States`, ...batch.flatMap(b => b.imports),
        ...(batch.some(b => b.imports.length) ? [] : [`${mod}.H0`])]);
      writeFileSync(leaf, render(deps, batch.map(b => b.code).join("")));
      leaves.push(relative(root, leaf).replaceAll("/", ".").replace(/\.lean$/, ""));
    }
    writeFileSync(output, leaves.map(m => `import ${m}\n`).join(""));
    const outputRel = relative(root, resolve(output));
    if (!outputRel.startsWith("..") && !outputRel.startsWith("/")) {
      const check = join(root, "check.ts");
      const registry = readFileSync(check, "utf8");
      const paths = [...leaves.map(m => m.replaceAll(".", "/") + ".lean"), outputRel];
      const missing = paths.filter(p => !registry.includes(JSON.stringify(p)));
      const anchor = '  "host/sim/compose/PreCall.lean",';
      if (missing.length) {
        if (!registry.includes(anchor)) fail("prefill: missing link registration anchor in check.ts");
        writeFileSync(check, registry.replace(anchor, anchor + "\n" + missing.map(p => "  " + JSON.stringify(p) + ",").join("\n")));
      }
    }
  } else writeFileSync(output, render(imports, code));
  console.log(`${X}: ${emittedSites} site checks, ${emittedGlues} glue boundaries: ${output}`);
  if (skippedDerived.size) console.log(`${X}: ${skippedDerived.size} derived values outside the quantity map`);
  if (!sitesOnly && oneSite === undefined) {
    genSingletonFill(output, X, stages);
    genVWPrefixFill(output, X, stages);
    for (const p of stages) {
      const uses = bundlePiece(p.stage)?.uses;
      const setup = uses?.length === 1 && uses[0]!.match(/^setup_h([0-5])\.r0$/);
      if (p.stage.piece === "chunk" && setup) {
        const b = bridges.find((b: any) => b.site === p.stage.site)!;
        genSetupFill(output, X, mod, +setup[1]!, p.stage, b);
      }
    }
  }
}

if (process.argv[2] === "prefill") genPrefill(process.argv.slice(3));

// `prefill-body`: the VW forward's body from its typed chain. Each call site names the facts its generated site
// modules state (`VWFirst.BodySiteFacts`), each glue its typed runs and size bridges; `bodySite`, `bodyToCall`,
// `bodySize` are proved once. Each chain lives in `a4b/<tag>` and `VWFirst.<Tag>`, over the rows it serves.
// Usage: prefill-body <chain>:<case-dir> --tag <tag> --rows <r,...> [--site k]... [--glue j]...
// With --suffix-of <body chain>:<body case-dir>:<D,H,N>, the chain after that body: `a4b/<tag>/sfx`, its cuts carrying
// the retained property (`Tr`), and `VWForward`, the forward from the prefix's end to this chain's start.
// --bundle <n>: merge each `n` sites' modules into `B<j>`: most of a small module's cost is its import.
function genBodyFill(args: string[]) {
  const take = (flag: string) => {
    const out: string[] = [];
    for (let i = args.indexOf(flag); i >= 0; i = args.indexOf(flag)) out.push(args.splice(i, 2)[1]!);
    return out;
  };
  const bundleSites = +(take("--bundle")[0] ?? 0);
  const tag = take("--tag")[0] ?? fail("prefill-body: --tag <tag>");
  const fwdRowList = (take("--rows")[0] ?? fail("prefill-body: --rows <r,...>")).split(",");
  const sfxArg = take("--suffix-of")[0];
  const pfArg = take("--pf")[0];
  const sfx = sfxArg?.split(":") as [string, string, string] | undefined;
  const outDir = join(HERE, "a4b", tag, sfx ? "sfx" : ""), outMod = `host.sim.compose.a4b.${tag}${sfx ? ".sfx" : ""}`;
  const bodyMod = `host.sim.compose.a4b.${tag}`;
  const Tag = tag.toUpperCase(), NSV = `${NS}.VWFirst.${Tag}${sfx ? ".Sfx" : ""}`;
  const cutOf = (o: string, s: string, S: string) => sfx ? `(withMem Tr (bodyCore NB T tk π i bodyΘ ${o} bodyM ${s} ${S}))` : `(bodyCut NB T tk π i x0 bodyΘ ${o} bodyM ${s} ${S})`;
  const trBinders = sfx ? "(Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y)" : "(x0 : SegInst FF)";
  const trApp = sfx ? "Tr hT" : "x0", trNamed = sfx ? "(Tr := Tr)" : "(Tr := BodyTrail x0)", trHyp = sfx ? "hT" : "(BodyTrail.ofTrack x0)";
  const onlySites = take("--site").map(Number), onlyGlues = take("--glue").map(Number);
  const streams = take("--streams")[0] ?? process.env.HOST_STREAM_DIR ?? join(HERE, "../../../.host-stream");
  const [, X0, dir] = args[0]?.match(/^([^:]+):(.+)$/) ?? fail("prefill-body: <chain>:<case-dir>");
  const X = X0!, full = `Host.Load.Run.Tpl.${X}`, stream = join(streams, full);
  const seg = JSON.parse(readFileSync(join(stream, "seg.json"), "utf8"));
  const tdir = join(HERE, "../template", dir!), mod = `host.sim.template.${dir!.replaceAll("/", ".")}`;
  const src = (f: string) => memberSrc(dir!, f);
  // a chain whose rows are rebound has its oracle under `OR` (`tpl_stream_bind_rows`), else under `O`
  const orName = existsSync(join(tdir, "Rebind.lean")) ? "OR" : "O";
  const oracleFiles = readdirSync(outDir).filter(f => /^VWBodyOracles_\d+\.lean$/.test(f));
  const oracleOf = new Map<string, { file: string; map: string; check: string }>();
  for (const f of oracleFiles) for (const m of readFileSync(join(outDir, f), "utf8")
      .matchAll(/def \S+\.map_((?:g|site)\w*) : List \(Nat × Q\) := (.*)\n\nkernel_rfl \S+\.chk_\S+ : \(.*\n  (goodLin|goodEnum) /g))
    oracleOf.set(m[1]!, { file: f.slice(0, -5), map: m[2]!, check: m[3]! });
  const bridges = seg.bridges as any[];
  const stages = bridges.filter(b => b.kind === "stage").sort((a, b) => a.site - b.site);
  const parseMap = (s: string): [number, string][] =>
    [...s.matchAll(/\((\d+), Q\.(\w+)\)/g)].map(m => [+m[1]!, m[2]!]);
  const head = (imports: string[]) => `${[...new Set(imports.map(bundled))].map(i => `import ${i}`).join("\n")}
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace ${NSV}
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open ${NS}.SetupEarly ${NS}.SetupChunk

`;
  const tail = `\nend ${NSV}\n`;
  mkdirSync(outDir, { recursive: true });
  // One map for the whole chain: its last glue's cumulative map holds every variable the oracle reads.
  const chain = JSON.parse(readFileSync(join(stream, "chain.json"), "utf8"));
  const lastGlue = chain.pieces.filter((p: any) => p.glue !== undefined).at(-1).glue as string;
  const allMap = oracleOf.get(lastGlue) ?? fail(`no map_${lastGlue}`);
  const bodyQ = new Map(parseMap(allMap.map));
  // a suffix starts where its body ends: the body's last compaction and last glue
  const bodyEnd = sfx && (() => {
    const [Xb, dirb] = sfx;
    const streamB = join(streams, `Host.Load.Run.Tpl.${Xb}`);
    const segB = JSON.parse(readFileSync(join(streamB, "seg.json"), "utf8")), chainB = JSON.parse(readFileSync(join(streamB, "chain.json"), "utf8"));
    const stagesB = segB.bridges.filter((b: any) => b.kind === "stage").sort((a: any, b: any) => a.site - b.site);
    const nB = stagesB.length as number, lastB = nB - 1;
    return { Xb, tplB: `host.sim.template.${dirb.replaceAll("/", ".")}`, endB: chainB.T1 as number, nB, lastB, aB: stagesB[lastB].ia as number };
  })();
  // a module of the body, or its bundle
  const bodyModule = (m: string) => {
    const dirB = join(HERE, "a4b", tag);
    if (existsSync(join(dirB, `${m}.lean`))) return `${bodyMod}.${m}`;
    const b = readdirSync(dirB).find(f => /^B\d+\.lean$/.test(f) && readFileSync(join(dirB, f), "utf8").includes(`section -- ${m}\n`));
    return `${bodyMod}.${(b ?? fail(`no ${m} in ${dirB}`)).slice(0, -5)}`;
  };
  const startCounters = (src("GlueN0").match(new RegExp(`theorem ${X}\\.gjcl0 \\(h : Conv\\.JClean \\((⟨[^⟩]*⟩) : Conv\\.Cnt\\)`)) ?? fail("GlueN0: gjcl0"))[1]!;
  const startJsN = bodyEnd ? `${bodyEnd.Xb}.s${bodyEnd.aB}.next` : "2673488";
  if (bodyEnd) {
    const { Xb, tplB, endB, nB, lastB } = bodyEnd;
    writeFileSync(join(outDir, "VWBodyChain.lean"), head(["host.sim.compose.a4b.VWBodyBase", `${mod}.H0`, `${mod}.S0Eq`,
      bodyModule(`VWBodyJ${lastB}`), `${tplB}.GlueN${nB}`, `${tplB}.H${Math.floor(endB / 32)}`, "host.sim.lin.Table", "host.sim.template.CallGen"]) +
    `/-- The rows this chain serves. -/
def fwdRows : List Row := [${fwdRowList.join(", ")}]

/-- No canonical results: the body's end table is already de-canonicalized. -/
noncomputable def bodyΘ : List Nat × List SymE := ([], [])

kernel_rfl tokensEnd : (mlxOf ${Xb}.s${endB}.ffi).tokens = [.ref 1, .ref 2]

theorem bodyStartEq : (${X}.s0 : St FF.S) = ${Xb}.s${endB} := startEqOf tokensEnd ${X}.s0_tok

theorem bodyStartClean : Conv.JClean (${startCounters} : Conv.Cnt) ${X}.s0 := by
  rw [bodyStartEq]
  exact ${Xb}.gjcl${nB} (${Xb}.cjcl${lastB} ${NS}.VWFirst.${Tag}.bodyClean${lastB})

kernel_rfl bodyJsEnd : ${Xb}.gjh${nB}.all (noBigAtP (jsAboveB ${startJsN}) ${Xb}.s${endB}) = true

theorem bodyStartJs : JsHeapAbove ${startJsN} ${X}.s0 := by
  rw [bodyStartEq]
  exact ${NS}.VWFirst.${Tag}.bodyJs${lastB}.step (Nat.le_refl _)
    (Conv.heap_off_setAll ${Xb}.gjk${nB}
      (fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp ${Xb}.gjbd${nB} b hb))) bodyJsEnd

kernel_rfl bodyEndBridge : bridgeOf ${Xb}.s${endB}.ffi = bridgeOf ${Xb}.s0.ffi

theorem bodyInactive0 : (bridgeOf ${X}.s0.ffi).active = false := by
  rw [bodyStartEq]
  exact (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyEndBridge).trans ${NS}.VWFirst.${Tag}.bodyInactive0

kernel_rfl bodyStart2665 : arrOf ${X}.s0 2665 = []
kernel_rfl bodyStartChunk : arrOf ${X}.s0 VWFrames.chunk = []
` + tail);
  } else
  writeFileSync(join(outDir, "VWBodyChain.lean"), head(["host.sim.compose.a4b.VWBodyBase", `${mod}.H0`, `${mod}.S0Eq`, `${mod}.BoundaryData`, "host.sim.lin.Table", "host.sim.template.CallGen"]) +
    `/-- The rows this chain's forward serves. -/
def fwdRows : List Row := [${fwdRowList.join(", ")}]

/-- The chain's canonical results and their terms. -/
noncomputable def bodyΘ : List Nat × List SymE := (${X}.dws, ${X}.drs)

theorem bodyStartEq : (${X}.s0 : St FF.S) = PRE_first_tail_x15_r0.s41 := bodyStartEqOf ${X}.s0_tok

theorem bodyStartClean : Conv.JClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) ${X}.s0 := by
  rw [bodyStartEq]
  exact startClean41

theorem bodyStartJs : JsHeapAbove 2673488 ${X}.s0 := by
  rw [bodyStartEq]
  exact startJs41

theorem bodyInactive0 : (bridgeOf ${X}.s0.ffi).active = false := by
  rw [bodyStartEq]
  exact inactive41

kernel_rfl bodyStart2665 : arrOf ${X}.s0 2665 = []
kernel_rfl bodyStartChunk : arrOf ${X}.s0 VWFrames.chunk = []
` + tail);
  writeFileSync(join(outDir, "VWBodyMap.lean"), head([`${outMod}.VWBodyChain`, `${mod}.States`, `${mod}.H0`, "host.sim.lin.Table"]) +
    `def bodyM : List (Nat × Q) := ${allMap.map}

kernel_rfl bodyGoodAll : (fwdRows.all fun r => goodLin r.ps (varsOf r.V bodyM) ${X}.${orName}) = true

theorem bodyGoodDrop {r : Row} {i : Cls.Inst} {ν : Nat → F64} (hr : r ∈ fwdRows) (hi : InRow r i)
    (hν : MapOk ν i bodyM) (d : Nat) : Good ν (List.drop d ${X}.${orName}) :=
  fun q hq => good_of_row (List.all_eq_true.mp bodyGoodAll r hr) hi hν q (List.mem_of_mem_drop hq)
` + tail);
  const cnt = (s: string) => s.replace(/\s/g, "");
  // the offsets: 3571 at the start, each compaction adds its discarded addresses and its canonical results
  const startOff = sfx ? sfx[2].split(",").map(Number) as [number, number, number] : [3571, 0, 0] as [number, number, number];
  let [D, H, N] = startOff, J = 0;
  const Ds = new Map<number, string>([[0, `⟨${D}, ${H}, ${N}, ${J}⟩`]]);
  for (const b of stages) {
    const k = b.site as number, a = b.ia as number, m = a + 1, cn = a + 2;
    const c = b.compaction;
    const siteZ = src(`SiteZ${k}`), glue = src(`GlueN${k}`);
    const counters = glue.match(new RegExp(`theorem ${X}\\.gjcl${k} \\(h : Conv\\.JClean \\((⟨[^⟩]*⟩) : Conv\\.Cnt\\) ${X}\\.s(\\d+)\\) : Conv\\.JClean \\((⟨[^⟩]*⟩)`)) ?? fail(`${X}: GlueN${k}: gjcl`);
    const cAfter = siteZ.match(new RegExp(`theorem ${X}\\.cjcl${k} \\(h : Conv\\.JClean \\(⟨[^⟩]*⟩ : Conv\\.Cnt\\) ${X}\\.s${a}\\) : Conv\\.JClean \\((⟨[^⟩]*⟩)`)) ?? fail(`${X}: SiteZ${k}: cjcl`);
    const nC = +(siteZ.match(new RegExp(`znC${k} : .* = (\\d+)`)) ?? fail("znC"))[1]!;
    const n1 = +(siteZ.match(new RegExp(`zsmn${k} : .* = (\\d+)`)) ?? fail("zsmn"))[1]!;
    const tpl = src(`st${k}/TypedTpl`);
    const nSteps = +(tpl.match(/\n  n := (\d+)/) ?? fail(`st${k}: n`))[1]!;
    const T1 = +(tpl.match(new RegExp(`S2 := ${X}\\.st${k}\\.S(\\d+)`)) ?? fail(`st${k}: S2`))[1]!;
    const site = oracleOf.get(`site${k}`) ?? fail(`no map_site${k}`);
    const cws = c.ws as number[];
    const qs = cws.map(v => bodyQ.has(v) ? `some Q.${bodyQ.get(v)}` : "none");
    const drop = n1 - +(src(`SiteC${k}`).match(new RegExp(`cnext${k} : .* = (\\d+)`)) ?? fail("cnext"))[1]!;
    const [cxn, cnn] = cAfter[1]!.slice(1, -1).split(",").map(Number) as [number, number];
    const Dnext = D + drop, Hnext = H + (c.xn1 - cxn), Nnext = N + (c.nn1 - cnn), Jnext = J + cws.length;
    const off = `⟨${D}, ${H}, ${N}, ${J}⟩`, offNext = `⟨${Dnext}, ${Hnext}, ${Nnext}, ${Jnext}⟩`;
    const sel = !onlySites.length && !onlyGlues.length || onlySites.includes(k);
    if (sel) {
      const prevJs = k === 0 ? "bodyStartJs" : `bodyJs${k - 1}`, prevN = k === 0 ? startJsN : `${X}.s${stages[k - 1].ia}.next`;
      const prevClean = k === 0 ? "bodyStartClean" : `(${X}.cjcl${k - 1} bodyClean${k - 1})`;
      const prevNcl = k === 0 ? `${X}.ncl0` : `(${X}.cncl${k - 1} bodyNcl${k - 1})`;
      const cshift = (src(`SiteR${k}`).match(new RegExp(`theorem ${X}\\.cshiftR${k} [\\s\\S]*?(?=\\nend Host)`)) ?? fail(`SiteR${k}`))[0]!
        .replace(`${X}.cshiftR${k} `, `bodyCshift${k} `).replaceAll(`${X}.ncl${a} `, `bodyNcl${k} `);
      writeFileSync(join(outDir, `VWBodyJ${k}.lean`), head([
        k === 0 ? `${outMod}.VWBodyChain` : `${outMod}.VWBodyJ${k - 1}`,
        ...(k === 0 ? [`${mod}.NCl0`] : []), `${mod}.GlueN${k}`, `${mod}.SiteZ${k}`,
      ]) + `theorem bodyNcl${k} : Conv.NClean (${counters[3]} : Conv.Cnt) (Host.Load.Layers.toLoad ${X}.s${a}.ffi).mlx :=
  ${X}.gncl${k} ${prevNcl}

theorem bodyClean${k} : Conv.JClean (${counters[3]} : Conv.Cnt) ${X}.s${a} :=
  ${X}.gjcl${k} ${prevClean}

kernel_rfl bodyJsLe${k} : Nat.ble ${prevN} ${X}.s${a}.next = true
kernel_rfl bodyJsList${k} : (${X}.gjh${k} ++ ${X}.cl${k}).all (noBigAtP (jsAboveB ${X}.s${a}.next) ${X}.s${cn}) = true
theorem bodyJs${k} : JsHeapAbove ${X}.s${a}.next ${X}.s${cn} :=
  JsHeapAbove.glueSite ${prevJs} (Nat.le_of_ble_eq_true bodyJsLe${k}) ${X}.gjk${k} ${X}.gjbd${k} ${X}.cheap${k} ${X}.zclbd${k} bodyJsList${k}
` + tail);
      writeFileSync(join(outDir, `VWBodyS${k}.lean`), head([
        `${outMod}.VWBodyJ${k}`, `${outMod}.VWBodySite${k}`,
        `${outMod}.${site.file}`, `${outMod}.VWBodyMap`,
        `${mod}.SiteD${k}`, `${mod}.SiteZ${k}`, "host.sim.template.CallGen",
      ]) + `${cshift}

kernel_rfl bodyFramesEmpty${k} : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].all (fun a => (arrOf ${X}.s${m} a).isEmpty) = true
kernel_rfl bodyJsRoots${k} : noBigRootsP (jsAboveB ${X}.s${a}.next) ${X}.s${cn}.trace ${X}.s${cn} = true
kernel_rfl bodyJsNative${k} : bigsOutB jsLoN jsHiN (mlxOf ${X}.s${cn}.ffi) = true
kernel_rfl bodyLow${k} : (${X}.cws${k} ++ ${X}.ws${k}).all (Nat.ble 9) = true
kernel_rfl bodyCntM${k} : countersOkB ${X}.s${a} ${X}.s${m} = true
kernel_rfl bodyHi${k} : Nat.ble (mlxOf ${X}.s${cn}.ffi).next setupP.E = true
kernel_rfl bodyNhi${k} : Nat.ble (mlxOf ${X}.s${cn}.ffi).nnext setupP.NE = true
kernel_rfl bodyBridge${k} : bridgeOf ${X}.s${m}.ffi = bridgeOf ${X}.s${a}.ffi
kernel_rfl bodyNN${k} : Nat.ble (mlxOf ${X}.s${a}.ffi).nnext ${X}.P${k}.NL = true
kernel_rfl bodyXn${k} : Nat.ble (${cAfter[1]} : Conv.Cnt).xn (mlxOf ${X}.s${cn}.ffi).next = true
kernel_rfl bodyLo${k} : Nat.ble setupP.lo (mlxOf ${X}.s${cn}.ffi).next = true
theorem bodyFacts${k} : BodySiteFacts ${X}.s${a} ${X}.s${m} ${X}.s${cn} ${X}.s0 ${X}.S${a} ${X}.S${m} ${X}.S${cn}
    ${X}.ws${k} ${X}.cws${k} ${X}.nr${k} ${X}.pl${k} ${X}.cl${k} ${n1} ${nC} ${X}.kd${k} ${X}.kappa${k} ${X}.P${k}
    ${counters[3]} ${cAfter[1]} where
  zkap := ${X}.zkap${k}
  clean := bodyClean${k}
  cfix := ${X}.cfix${k}
  zpl := ${X}.zpl${k}
  zplnd := ${X}.zplnd${k}
  zn1 := ${X}.zn1${k}
  zfirst := ${X}.zfirst${k}
  zscn := ${X}.zscn${k}
  zsmn := ${X}.zsmn${k}
  zgrow := ${X}.zgrow${k}
  mergeTab := ${X}.mergeTab${k}
  zfresh := ${X}.zfresh${k}
  zcnd := ${X}.zcnd${k}
  lenc := by rfl
  znrHi := ${X}.znrHi${k}
  zfrlt := ${X}.zfrlt${k}
  zgP := ${X}.zg${k}_2665
  zkP := ${X}.zk${k}_2665
  zmP := ${X}.zm${k}_2665
  zgC := ${X}.zg${k}_2673467
  zkC := ${X}.zk${k}_2673467
  zmC := ${X}.zm${k}_2673467
  start2665 := bodyStart2665
  startChunk := bodyStartChunk
  zwB := ${X}.zw${k}_2673472
  zwV := ${X}.zw${k}_2673473
  cheap := ${X}.cheap${k}
  zclbd := ${X}.zclbd${k}
  hml := hoff_of ${X}.mheap${k} ${X}.stFoot${k} ${X}.iso${k} ${X}.zwr${k}
  ckeepP := ${X}.ckeepP${k}
  csupp := ${X}.csupp${k}
  cbound := ${X}.cbound${k}
  zimg := ${X}.zimg${k}
  zctl := ${X}.zctl${k}
  zstack := ${X}.zstack${k}
  zjobs := ${X}.zjobs${k}
  zstores := ${X}.zstores${k}
  zroots := ${X}.zroots${k}
  znC := ${X}.znC${k}
  ctab := ${X}.ctab${k}
  zbin := ${X}.zbin${k}
  cbridge := ${X}.cbridge${k}
  sbridge := bodyBridge${k}
  cwsDisj := ${X}.cwsDisj${k}
  cshiftR := fun h hNL => bodyCshift${k} h hNL
  nnextLe := Nat.le_of_ble_eq_true bodyNN${k}
  raised := ${X}.raised${k}
  cbigs := ${X}.cbigs${k}
  cjcl := ${X}.cjcl${k}
  xnLe := Nat.le_of_ble_eq_true bodyXn${k}
  loLe := Nat.le_of_ble_eq_true bodyLo${k}
  zroots2 := ${X}.${/\.zrootsB\d+ :/.test(src(`SiteZ${k}`)) ? "zrootsB" : "zroots2"}${k}
  cntM := bodyCntM${k}
  hiLe := Nat.le_of_ble_eq_true bodyHi${k}
  nhiLe := Nat.le_of_ble_eq_true bodyNhi${k}
  jsHeap := bodyJs${k}
  jsRoots := bodyJsRoots${k}
  jsNative := bodyJsNative${k}
  framesEmpty := bodyFramesEmpty${k}
  trailOld := by decide
  lowVars := bodyLow${k}

def bodyQs${k} : List (Option Q) := [${qs.join(", ")}]
noncomputable def bodyEs${k} : List (Option SymE) := ${X}.nr${k}.map fun r => nth? ${X}.st${k}.S${T1}.tab r
kernel_rfl bodyResChk${k} : (fwdRows.all fun r =>
  resChkAll r bodyM bodyEs${k} bodyQs${k}) = true
kernel_rfl bodyLq${k} : bodyQs${k}.length = ${X}.cws${k}.length
kernel_rfl bodyNrLo${k} : ${X}.nr${k}.all (Nat.ble ${X}.S${a}.tab.length) = true
kernel_rfl bodySub${k} : (Oracles.${X}.map_site${k}.all fun p => bodyM.contains p) = true
kernel_rfl bodyPost${k} : postSubB bodyM ${X}.ws${k} ${X}.cws${k} bodyQs${k} = true
kernel_rfl bodyDrop${k} : Nat.ble (${D} + (${X}.s${m}.next - ${X}.s${cn}.next)) ${Dnext} = true
kernel_rfl bodyDropH${k} : Nat.ble (${H} + ((mlxOf ${X}.s${m}.ffi).next - (mlxOf ${X}.s${cn}.ffi).next)) ${Hnext} = true
kernel_rfl bodyDropN${k} : Nat.ble (${N} + ((mlxOf ${X}.s${m}.ffi).nnext - (mlxOf ${X}.s${cn}.ffi).nnext)) ${Nnext} = true
kernel_rfl bodyDv${k} : bodyΘ.1.take ${Jnext} = bodyΘ.1.take ${J} ++ ${X}.cws${k}
kernel_rfl bodyDe${k} : bodyΘ.2.take ${Jnext} = bodyΘ.2.take ${J} ++ ${X}.nr${k}.map (fun r =>
  ((nth? ${X}.st${k}.S${T1}.tab r).getD (.lit (F64.zero false))).subst (Conv.compactθ (bodyΘ.1.take ${J}) (bodyΘ.2.take ${J})))
kernel_rfl bodyDl${k} : (bodyΘ.1.take ${J}).length = (bodyΘ.2.take ${J}).length
kernel_rfl bodyDold${k} : (bodyΘ.1.take ${J}).all (fun v => (Conv.idx? v ${X}.cws${k}).isNone && !${X}.ws${k}.contains v) = true
kernel_rfl bodyDfree${k} : (bodyΘ.2.take ${Jnext}).all (fun e => (${X}.cws${k} ++ ${X}.ws${k}).all fun w => e.noVar w) = true

${sfx ? `kernel_rfl bodyKeepNN${k} : ${X}.kd${k}.nn0 = ${X}.kd${k}.nn1
kernel_rfl bodyKeepNK${k} : PTrie.keys ${X}.kd${k}.node = []

` : ""}theorem bodyStep${k} (NB T : Nat) (tk : Nat → Nat) (π : List Nat) ${trBinders} {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep ${cutOf(off, `${X}.s${a}`, `${X}.S${a}`)}
      ${cutOf(offNext, `${X}.s${cn}`, `${X}.S${cn}`)} (${nSteps} + 1) :=
  ${sfx ? `memSite hT (fun j => by rw [${X}.zkap${k}]; exact compact_node_id bodyKeepNN${k} bodyKeepNK${k} j)` : `bodySite bodyFacts${k}.cfix bodyFacts${k}.trailOld`} fun x hR hB =>
  bodySiteCore (Θ := bodyΘ) (n := ${nSteps}) (S2 := ${X}.st${k}.S${T1}.tab) (Es := bodyEs${k}) (qs := bodyQs${k})
    (ok := ${X}.st${k}.bodyOkL)
    (fun bs rows => ${NS}.${X}.site${k} bs rows (bodyLocalSim NB T tk bs rows))
    (fun bs rows stk y0 => bodyGrowLocalSim NB T tk bs rows stk y0)
    (fun _ _ => rfl) (fun _ _ => rfl) bodyFacts${k}
    (fun _ _ ν hm => ${site.check === "goodEnum" ? "good_of_row_enum" : "good_of_row"}
      (List.all_eq_true.mp Oracles.${X}.chk_site${k} r hr) hi (MapOk.sub hm (sub_of_all bodySub${k})))
    (fun _ hm _ _ _ ho hq => resChkAll_sound (List.all_eq_true.mp bodyResChk${k} r hr) hi hm ho hq)
    bodyLq${k} rfl bodyNrLo${k} (postSub_sound bodyPost${k})
    (Nat.le_of_ble_eq_true bodyDrop${k}) (by decide) (Nat.le_of_ble_eq_true bodyDropH${k}) (by decide)
    (Nat.le_of_ble_eq_true bodyDropN${k}) (by decide)
    bodyDv${k} bodyDe${k} bodyDl${k} bodyDold${k} bodyDfree${k} hR hB
` + tail);
      console.log(`${X}: site ${k} (${a}): ${off} -> ${offNext}, ${nSteps} + 1 steps`);
    }
    D = Dnext; H = Hnext; N = Nnext; J = Jnext;
    Ds.set(k + 1, offNext);
  }
  // the glue stretches: typed runs and size bridges between the calls
  const stepsAt = new Map<string, { name: string; file: string }>();
  const memberNames = membersOf(dir!) ? Object.keys(membersOf(dir!)!) : readdirSync(tdir).filter(f => f.endsWith(".lean")).map(f => f.slice(0, -5));
  for (const f of memberNames.filter(f => /^TypedSteps\d+$/.test(f)))
    for (const m of src(f).matchAll(new RegExp(`boot_rfl ${X}\\.(body(?:StepA|StepB|PatchB)\\d*) from ${X}\\.s(\\d+) to ${X}\\.s(\\d+)`, "g")))
      stepsAt.set(`${m[2]}->${m[3]}`, { name: m[1]!, file: f });
  const ranges = [...src("Run").matchAll(/^sim_chain_range \S+ \S+ (\d+) (\d+) runSeg(\d+)$/gm)]
    .map(m => ({ a: +m[1]!, b: +m[2]!, r: +m[3]! }));
  const sizeIdx = new Map<number, number>();
  for (const m of src("Bridge").matchAll(new RegExp(`kernel_rfl ${X}\\.sizeA(\\d+) : Host\\.Ts\\.Sim\\.Disp\\.sizeParts ${X}\\.s(\\d+)`, "g")))
    sizeIdx.set(+m[2]!, +m[1]!);
  const foldParts: string[] = [];
  let foldN = 0;
  for (const [j, p] of (chain.pieces.filter((p: any) => p.glue !== undefined) as any[]).entries()) {
    if (onlySites.length || onlyGlues.length) { if (!onlyGlues.includes(j)) continue; }
    const stage = stages.find(b => b.site === j);
    const start = p.from as number, last = stage ? stage.ia as number : p.to as number;
    const inside = bridges.filter(b => (b.kind === "size" || b.kind === "len") && b.ia > start && b.ia <= last).sort((x, y) => x.ia - y.ia);
    const Dj = Ds.get(j) ?? fail(`no offset at glue ${j}`);
    const imports = new Set<string>(["host.sim.compose.a4b.VWBodyGlue", `${outMod}.VWBodyChain`,
      `${outMod}.VWBodyMap`, `${mod}.Bridge`]);
    const hOf = (k: number) => imports.add(`${mod}.H${Math.floor(k / 32)}`);
    let facts = "", proof = "";
    const steps = (p.steps as number) + (stage ? 1 : 0);
    const brEq = (k: number) => { facts += `kernel_rfl bodyBr${k} : bridgeOf ${X}.s${k}.ffi = bridgeOf ${X}.s0.ffi\n`; };
    const good = (k: number) => {
      facts += `kernel_rfl bodyO${k} : ${X}.S${k}.oracle = List.drop (${X}.${orName}.length - ${X}.S${k}.oracle.length) ${X}.${orName}\n`;
      brEq(k);
      return `(fun _ hm => bodyO${k} ▸ bodyGoodDrop hr hi hm _)`;
    };
    const acc = (k: number) => {
      facts += `kernel_rfl bodyAcc${k} : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows ${X}.s${k} ${X}.S${k}) = fun _ _ => true\n`;
      return `bodyAcc${k}`;
    };
    const cnt = (x: number, y: number) => {
      facts += `kernel_rfl bodyCnt${x} : countersOkB ${X}.s${x} ${X}.s${y} = true\n`;
      return `bodyCnt${x}`;
    };
    const active = (k: number) => `((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr${k}).trans bodyInactive0)`;
    const pieces: string[] = [];
    const seg = (a: number, b: number) => {
      const rg = ranges.find(r => r.a === a && r.b === b) ?? fail(`no range ${a}..${b}`);
      imports.add(`${mod}.TypedSeg${rg.r}`);
      hOf(a); hOf(b);
      return `${X}.bodyRunSeg${rg.r}`;
    };
    let a = start;
    const toCall = (b: number) => {
      const st = stepsAt.get(`${b}->${b + 1}`) ?? fail(`no step ${b}->${b + 1}`);
      imports.add(`${mod}.${st.file}`); hOf(b + 1);
      const brIn = good(a), acA = acc(a), acB = acc(b), run = seg(a, b);
      facts += `kernel_rfl bodyBr${b + 1} : bridgeOf ${X}.s${b + 1}.ffi = bridgeOf ${X}.s0.ffi\nkernel_rfl bodyHalt${b} : isHalt ${X}.s${b}.ctl = false\nkernel_rfl bodyTop${b + 1} : noRetBlock ${X}.s${b + 1} = true\n`;
      pieces.push(`bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) ${trNamed} (O := ${Dj}) ${acA} ${run} ${acB} bodyHalt${b} ${X}.${st.name} bodyTop${b + 1} ${brIn} ${active(a)} (bodyBr${b + 1}.trans bodyBr${a}.symm) ${cnt(a, b + 1)} ${trHyp}`);
    };
    for (const br of inside) {
      if (br.ia === last) continue;
      toCall(br.ia - 1);
      const patch = stepsAt.get(`${br.ia}->${br.ia + 1}`) ?? fail(`no patch ${br.ia}`);
      imports.add(`${mod}.${patch.file}`); hOf(br.ia + 1);
      const g0 = good(br.ia);
      brEq(br.ia + 1);
      if (br.kind === "len") {
        const n = (src("Bridge").match(new RegExp(`kernel_rfl ${X}\\.ctlA(\\d+) : ${X}\\.s${br.ia}\\.ctl`)) ?? fail(`no length bridge at ${br.ia}`))[1];
        facts += `kernel_rfl bodyLenSt${br.ia} : ${X}.s${br.ia}.stack = .e (.member kLength false) :: ${X}.s${br.ia}.stack.tail\nkernel_rfl bodyLenArr${br.ia} : arrOf ${X}.s${br.ia} 2665 = []\n`;
        pieces.push(`bodyLen (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) ${trNamed} (O := ${Dj}) (by simp [bodyM]) ${X}.ctlA${n} bodyLenSt${br.ia} ${X}.objA${n} (by rw [${X}.kindA${n}, bodyLenArr${br.ia}]; rfl) (Option.some.inj ${X}.${patch.name}) ${g0} ${active(br.ia)} (bodyBr${br.ia + 1}.trans bodyBr${br.ia}.symm) ${cnt(br.ia, br.ia + 1)} ${trHyp}`);
        a = br.ia + 1;
        continue;
      }
      const n = sizeIdx.get(br.ia) ?? fail(`no size bridge at ${br.ia}`);
      pieces.push(`bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) ${trNamed} (O := ${Dj}) ${X}.sizeA${n} ${X}.sizeArgsA${n} ${X}.sizeSymA${n} ${X}.sizeMlxA${n} ${X}.sizePayA${n} ${X}.sizeTaA${n} ${X}.sizeDecA${n} ${X}.sizePreA${n} ${X}.${patch.name} ${g0} ${active(br.ia)} (bodyBr${br.ia + 1}.trans bodyBr${br.ia}.symm) ${cnt(br.ia, br.ia + 1)} ${trHyp}`);
      a = br.ia + 1;
    }
    if (stage) toCall(last - 1);
    else {
      const brIn = good(a), acA = acc(a), run = seg(a, last);
      facts += `kernel_rfl bodyBr${last} : bridgeOf ${X}.s${last}.ffi = bridgeOf ${X}.s0.ffi\nkernel_rfl bodyTop${last} : noRetBlock ${X}.s${last} = true\n`;
      pieces.push(`bodyGlue (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) ${trNamed} (O := ${Dj}) ${acA} ${run} bodyTop${last} ${brIn} ${active(a)} (bodyBr${last}.trans bodyBr${a}.symm) ${cnt(a, last)} ${trHyp}`);
    }
    const dedup = [...new Set(facts.split("\n"))].join("\n");
    proof = pieces.reduce((acc0, q) => acc0 ? `(${acc0}).trans (${q})` : q, "");
    writeFileSync(join(outDir, `VWBodyG${j}.lean`), head([...imports]) + `${dedup}
theorem bodyGlue${j} (NB T : Nat) (tk : Nat → Nat) (π : List Nat) ${trBinders} {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep ${cutOf(Dj, `${X}.s${start}`, `${X}.S${start}`)}
      ${cutOf(Dj, `${X}.s${last}`, `${X}.S${last}`)} ${steps} :=
  (${proof}).cast rfl rfl rfl
` + tail);
    console.log(`${X}: glue ${j} (${start}..${last}): ${pieces.length} pieces, ${steps} steps`);
    foldParts.push(`bodyGlue${j} NB T tk π ${trApp} hr hi`);
    foldN += steps;
    if (stage) {
      const n = +(src(`st${j}/TypedTpl`).match(/\n  n := (\d+)/) ?? fail(`st${j}: n`))[1]!;
      foldParts.push(`bodyStep${j} NB T tk π ${trApp} hr hi`);
      foldN += n + 1;
    }
  }
  if (!onlySites.length && !onlyGlues.length && bodyEnd && pfArg) {
    // the step's end at the shared pre-final template: `<link>:<walk>:<template>:<c30>:<c31>`
    const [PF, PW, PT, c30, c31] = pfArg.split(":") as [string, string, string, string, string];
    const endK = chain.T1 as number, endO = Ds.get(stages.length) ?? fail("no end offset");
    const [, , endH, endN] = endO.match(/⟨(\d+), (\d+), (\d+), /)!;
    const rowNames = fwdRowList.join(", ");
    writeFileSync(join(outDir, "VWPfEnd.lean"), head(["host.sim.compose.a4b.VWPf", `host.sim.compose.a4b.${PF}`, `${outMod}.VWBodyChain`,
      `${outMod}.VWBodyMap`, "host.sim.compose.a4b.VWFirstRows", `${mod}.H0`]) + `kernel_rfl pfKeys : (${PW}.R.theta ++ ${PF}.thetaX).map Prod.fst = [11, 14, 16, 30, 31]
kernel_rfl pf14 : ${PF}.θ 14 = .var 17
kernel_rfl pf30 : (fun ν : Nat → F64 => (${PF}.θ 30).eval ν) = fun _ => F64.ofNat ${c30}
kernel_rfl pf31 : (fun ν : Nat → F64 => (${PF}.θ 31).eval ν) = fun _ => F64.ofNat ${c31}
kernel_rfl pfRow11 : (fwdRows.all fun r => resChk r bodyM (${PF}.θ 11) (some Q.n)) = true
kernel_rfl pfRow16 : (fwdRows.all fun r => resChk r bodyM (${PF}.θ 16) (some Q.cap1)) = true
kernel_rfl pfNN : ${PW}.R.data.nn0 = ${PW}.R.data.nn1
kernel_rfl pfNK : PTrie.keys ${PW}.R.data.node = []
kernel_rfl pfNext : ${X}.s${endK}.next = ${PT}.s0.next
kernel_rfl pfH : (mlxOf ${X}.s${endK}.ffi).next = (mlxOf ${PT}.s0.ffi).next
kernel_rfl pfNodes : (mlxOf ${X}.s${endK}.ffi).nnext = (mlxOf ${PT}.s0.ffi).nnext
kernel_rfl pfBelow : Nat.ble (mlxOf ${X}.s${endK}.ffi).nnext ${PF}.P0.NL = true
kernel_rfl pfA : ${PW}.R.data.a 2590 = 2590
kernel_rfl pfB : ${PW}.R.data.a 2586 = 2586
kernel_rfl pfC : ${PW}.R.data.a 2589 = 2589

/-- The rows' last quantities. -/
theorem rowCap {r : Row} {i : Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) : i.cap1 = capL (i.L - 1) := by
  simp only [fwdRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  ${fwdRowList.length > 1 ? `rcases hr with ${fwdRowList.map(() => "rfl").join(" | ")}` : "subst hr"}
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [${rowNames}, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    unfold capL
    omega

/-- **The step's end at the pre-final cut.** -/
theorem toPfEnd (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap : Nat) (hcap : ${endO.match(/⟨(\d+)/)![1]} ≤ cap)
    (hbound : cap < Sim.bound) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y)
    {r : Row} {i : Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) (htail : r ∈ firstTailRows) :
    CutConv (withMem Tr (bodyCore NB T tk π i bodyΘ ${endO} bodyM ${X}.s${endK} ${X}.S${endK}))
      (withMem Tr (Pf.cut NB T tk π cap ${endH} ${endN} ${PT}.s0 ${PT}.S0)) := by
  obtain ⟨hL, hLmax, hn, _⟩ := firstTailFacts htail hi
  have hcapR := rowCap hr hi
  have h9 : ∀ ν, MapOk ν i bodyM → ν 9 = F64.ofNat i.L := fun ν hm =>
    (Conv.mapOk_iff'.1 hm) (9, Q.L) (by simp [bodyM])
  have h10n : ∀ ν, MapOk ν i bodyM → ν 10 = F64.ofNat i.n := fun ν hm =>
    (Conv.mapOk_iff'.1 hm) (10, Q.n) (by simp [bodyM])
  exact toPf (c30 := ${c30}) (c31 := ${c31}) ${PF}.facts hT hLmax (Nat.le_of_ble_eq_true pfBelow) pfNN pfNK pfNext pfH pfNodes
    (fun j h1 h2 h3 h4 h5 => Pf.thetaOf_off (by
      rw [pfKeys]
      simp only [List.mem_cons, List.not_mem_nil, or_false]
      omega))
    pf14 h9 (fun ν hm => by rw [h10n ν hm, hn])
    (fun ν hm => by
      rw [← hn]
      exact (resChk_sound (List.all_eq_true.mp pfRow11 r hr) hi hm).2 Q.n rfl)
    (fun ν hm => by
      rw [← hcapR]
      exact (resChk_sound (List.all_eq_true.mp pfRow16 r hr) hi hm).2 Q.cap1 rfl)
    (fun ν => congrFun pf30 ν) (fun ν => congrFun pf31 ν) (by decide) (by decide) pfA pfB pfC hcap hbound
` + tail);
  }
  if (!onlySites.length && !onlyGlues.length && bodyEnd) {
    const { Xb, endB } = bodyEnd, Tn = `${NS}.VWFirst.${Tag}`;
    const off0 = `⟨${startOff.join(", ")}, 0⟩`;
    writeFileSync(join(outDir, "VWForward.lean"), head([`${bodyMod}.VWBodyFold`, `${outMod}.VWBodyChain`, `${mod}.S0Eq`,
      "host.sim.compose.a4b.VWFirstRows", "host.sim.compose.a4b.VWBodyEntry"]) + `/-- This chain's start: the forward's return. -/
noncomputable def startCore (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst) : ICut FF :=
  bodyCore NB T tk π i bodyΘ ${off0} bodyMap ${X}.s0 ${X}.S0

kernel_rfl bodyEndJv : ${Tn}.bodyΘ.1.take ${Tn}.bodyJEnd = ${Tn}.bodyΘ.1
kernel_rfl bodyEndJe : ${Tn}.bodyΘ.2.take ${Tn}.bodyJEnd = ${Tn}.bodyΘ.2

theorem endTabEq : ${Xb}.S${endB}.tab.map (·.subst (Conv.compactθ ${Tn}.bodyΘ.1 ${Tn}.bodyΘ.2)) = ${X}.S0.tab :=
  ${Xb}.endTab.trans ${X}.s0_tab.symm

/-- **The forward from every start**, with what its end knows about it. -/
theorem forwardAll (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {r : Row} {i : Cls.Inst}
    (hr : r ∈ ${Tn}.fwdRows) (hi : InRow r i) (hn : i.n ≤ 2 ^ 20) (x0 : SegInst FF) :
    CutStep (withMem (BodyTrail x0) (forwardCut NB T tk π i)) (withMem (BodyTrail x0) (startCore NB T tk π i))
      (0 + ${Tn}.bodyN) :=
  (FwdCall.warm ((toBody ${Tn}.bodyStartEq ${Xb}.s0_tab hn).trans (${Tn}.bodyEnter hn))
    (${Tn}.bodyAll NB T tk π x0 hr hi)
    (endConv (vs := ${Tn}.bodyΘ.1) (es := ${Tn}.bodyΘ.2) bodyEndJv bodyEndJe bodyStartEq endTabEq (fun p hp => by
      simp only [bodyMap, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> simp [${Tn}.bodyM]))).step

/-- **The first tail's forward** over rows of this body. \`hfwd\`: the graph, from what the forward's end knows. -/
noncomputable def fwdPiece (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (uses : List Row)
    (hu : ∀ r ∈ uses, r ∈ ${Tn}.fwdRows) (htail : ∀ r ∈ ${Tn}.fwdRows, r ∈ firstTailRows) (obls : List Obl)
    (Mem Mem' : Nat → SegInst FF → Prop)
    (hfwd : ∀ r ∈ uses, ∀ i, InRow r i → ∀ x y, (forwardCut NB T tk π i).R x (forwardCut NB T tk π i).s0
        ⟨(forwardCut NB T tk π i).tab0, []⟩ → (forwardCut NB T tk π i).B x →
      (startCore NB T tk π i).R y (startCore NB T tk π i).s0 ⟨(startCore NB T tk π i).tab0, []⟩ →
      (∀ k, k < bodyN0 → y.M.node k = x.M.node k) → runC FF (0 + ${Tn}.bodyN) x.t x.C = some (y.t, y.C) →
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens →
      Mem i.L x → Mem' i.L y) :
    FwdPiece FF uses obls (fun i => withMem (Mem i.L) (forwardCut NB T tk π i))
      (fun i => withMem (Mem' i.L) (startCore NB T tk π i)) where
  m := [(9, .L)]
  np := 0
  nb := 0 + ${Tn}.bodyN
  O := []
  chk _ _ := rfl
  ok r hr i hi _ := by
    obtain ⟨hL, hLmax, hn, _⟩ := firstTailFacts (htail r (hu r hr)) hi
    exact FwdCall.warm (CutConv.refl _)
      (forwardMem (forwardAll NB T tk π (hu r hr) hi (by omega)) (hfwd r hr i hi)) (CutConv.refl _)
` + tail);
  }
  if (!onlySites.length && !onlyGlues.length && !bodyEnd) {
    const end = chain.T1 as number, Dend = Ds.get(stages.length) ?? fail("no final offset");
    const fold = foldParts.reduce((acc0, q) => acc0 ? `(${acc0}).trans (${q})` : `(${q})`, "");
    const rest = [...bodyQ.entries()].filter(([v]) => v !== 9 && v !== 10).map(([v, q]) => `(${v}, Q.${q})`);
    writeFileSync(join(outDir, "VWBodyFold.lean"), head([
      ...foldParts.map(p => `${outMod}.${p.startsWith("bodyGlue") ? "VWBodyG" : "VWBodyS"}${p.match(/\d+/)![0]}`),
      "host.sim.compose.a4b.VWBodyEntry",
    ]) + `abbrev bodyN : Nat := ${foldN}
abbrev bodyJEnd : Nat := ${J}

/-- **The forward's flat body**, in ${foldN} steps. -/
theorem bodyAll (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ${Ds.get(0)} bodyM ${X}.s0 ${X}.S0)
      (bodyCut NB T tk π i x0 bodyΘ ${Dend} bodyM ${X}.s${end} ${X}.S${end}) bodyN :=
  (${fold}).cast rfl rfl rfl

def bodyRest : List (Nat × Q) := [${rest.join(", ")}]
kernel_rfl bodySplit : bodyMap ++ bodyRest = bodyM
kernel_rfl bodyRestFree : ${X}.S0.tab.all (fun e => bodyRest.all fun p => e.noVar p.1) = true
kernel_rfl bodyRestNd : nodupT (bodyRest.map Prod.fst) PTrie.nil = true
kernel_rfl bodyRestDisj : bodyRest.all (fun p => bodyMap.all fun q => !Nat.beq q.1 p.1) = true
kernel_rfl bodyRestLow : bodyRest.all (fun p => Nat.ble 9 p.1) = true
kernel_rfl bodyRestQ : bodyRest.all (fun p => decide (p.2 = Q.n)) = true

/-- The forward's start at the chain's one map. -/
theorem bodyEnter {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {x0 : SegInst FF} (hn : i.n ≤ 2 ^ 20) :
    CutConv (withMem (BodyTrail x0) (bodyStartCut NB T tk π i ${X}.s0 ${X}.S0))
      (bodyCut NB T tk π i x0 bodyΘ ${Ds.get(0)} bodyM ${X}.s0 ${X}.S0) := by
  have h := bindRest (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (x0 := x0) (Θ := bodyΘ) (hJ := rfl) (O := ${Ds.get(0)}) (m := bodyMap)
    (rest := bodyRest) (s := ${X}.s0) (S := ${X}.S0)
    (fun e he p hp => List.all_eq_true.mp (List.all_eq_true.mp bodyRestFree e he) p hp)
    (nodupT_sound bodyRestNd).2
    (fun p hp q hq he => by
      have hc := List.all_eq_true.mp (List.all_eq_true.mp bodyRestDisj p hp) q hq
      rw [he] at hc
      simp at hc)
    (fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp bodyRestLow p hp))
    (fun p hp => by
      have hq : p.2 = Q.n := of_decide_eq_true (List.all_eq_true.mp bodyRestQ p hp)
      rw [hq]
      exact hn)
  rw [bodySplit] at h
  exact fromStart.trans h
` + tail);
    console.log(`${X}: fold of ${foldParts.length} pieces, ${foldN} steps, end ${Dend}`);
  }
  if (bundleSites > 0 && !onlySites.length && !onlyGlues.length) {
    // each oracle module holds four sites' checks, in order
    const oracleLeaves = readdirSync(outDir).filter(f => /^VWBodyOracles_\d+\.lean$/.test(f)).map(f => +f.match(/\d+/)![0]).sort((a, b) => a - b);
    const groups: string[][] = [];
    for (let b = 0; b * bundleSites < stages.length + 1; b++) {
      const g: string[] = [];
      for (let k = b * bundleSites; k < (b + 1) * bundleSites && k <= stages.length; k++) {
        if (k % 4 === 0 && oracleLeaves.includes(k / 4)) g.push(`VWBodyOracles_${k / 4}`);
        if (k < stages.length) g.push(`VWBodySite${k}`, `VWBodyJ${k}`);
        g.push(`VWBodyG${k}`);
        if (k < stages.length) g.push(`VWBodyS${k}`);
      }
      groups.push(g);
    }
    const bundleOf = new Map<string, string>();
    groups.forEach((g, b) => g.forEach(m => bundleOf.set(m, `B${b}`)));
    const mapImp = (i: string) => {
      const m = i.startsWith(`${outMod}.`) ? bundleOf.get(i.slice(outMod.length + 1)) : undefined;
      return m ? `${outMod}.${m}` : i;
    };
    const merged = (text: string) => text.split("\n").filter(l => !l.startsWith("import ")).join("\n");
    groups.forEach((g, b) => {
      const self = `${outMod}.B${b}`, imports = new Set<string>();
      let body = "";
      for (const m of g) {
        const text = readFileSync(join(outDir, `${m}.lean`), "utf8");
        for (const l of text.split("\n")) if (l.startsWith("import ")) { const i = mapImp(l.slice(7).trim()); if (i !== self) imports.add(i); }
        body += `\nsection -- ${m}\n${merged(text)}\nend\n`;
      }
      writeFileSync(join(outDir, `B${b}.lean`), [...imports].map(i => `import ${i}`).join("\n") + "\n" + body);
    });
    for (const m of bundleOf.keys()) rmSync(join(outDir, `${m}.lean`));
    for (const f of readdirSync(outDir).filter(f => f.endsWith(".lean") && !/^B\d+\.lean$/.test(f))) {
      const text = readFileSync(join(outDir, f), "utf8");
      const seen = new Set<string>();
      writeFileSync(join(outDir, f), text.split("\n").flatMap(l => {
        if (!l.startsWith("import ")) return [l];
        const i = mapImp(l.slice(7).trim());
        if (seen.has(i)) return [];
        seen.add(i);
        return [`import ${i}`];
      }).join("\n"));
    }
    console.log(`${X}: ${bundleOf.size} modules in ${groups.length} bundles`);
  }
}


// The link of a final's end into the L-general POST entry (host.sim.compose.PostLink): the walk's
// checks over the whole states.  The entry's own facts are written once with --template.
function genPostLink(args: string[]) {
  const take = (flag: string) => {
    const i = args.indexOf(flag);
    if (i < 0) return undefined;
    return args.splice(i, 2)[1]!;
  };
  const withTemplate = args.includes("--template");
  if (withTemplate) args.splice(args.indexOf("--template"), 1);
  const streams = take("--streams") ?? process.env.HOST_STREAM_DIR ?? join(HERE, "../../../.host-stream");
  const name = take("--name") ?? fail("post-link: --name <prefix>");
  const walk = take("--walk") ?? fail("post-link: --walk <walk prefix>"), walkMod = take("--walkmod") ?? fail("post-link: --walkmod <module>");
  const endMod = take("--endmod") ?? fail("post-link: --endmod <module>");
  // the walk, when this link writes its own (the tail's end to the pre-final template)
  const walkAt = take("--walkfrom");
  const [, X, Ti] = args[0]?.match(/^([^:]+):(\d+)$/) ?? fail("post-link: <chain>:<end>");
  // The entry's name and frames; with --drop, the pre-final link: only the prompt kept, the frames listed dropped.
  const T = take("--entry") ?? "PRE_pl_entry", E = take("--entryname") ?? "PLEntry";
  const entryMod = take("--entrymod") ?? "host.sim.template.a4pre_pl_entry.S";
  const framesLit = take("--frames") ?? "[2673479, 2673484, 2673485, 2665]";
  const dropList = take("--drop");
  const thetaExtra = take("--theta-extra") ?? "";
  const a4b = "host.sim.compose.a4b", out = join(HERE, "a4b"), NL = "\n";
  const tm = JSON.parse(readFileSync(join(streams, "Host.Load.Run.Tpl." + T, "template.json"), "utf8"));
  const st = tm.start as { n: number; next: number; mnext: number; nnext: number };
  const chunk = 2000, s0 = T + ".s0", S0 = T + ".S0", s1 = X + ".s" + Ti, S1 = X + ".S" + Ti;
  const mlx = (s: string) => "(Host.Load.Layers.toLoad " + s + ".ffi).mlx";
  const head = (...imps: string[]) => imps.map(i => "import " + i + NL).join("") +
    "set_option Elab.async false" + NL + "namespace Host.Load.Run.Tpl" + NL +
    "open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route" + NL +
    "set_option maxRecDepth 1000000" + NL + "set_option maxHeartbeats 0" + NL + NL;
  const put = (file: string, body: string) => writeFileSync(join(out, file + ".lean"), body + NL + "end Host.Load.Run.Tpl" + NL);
  if (withTemplate) {
    put(E + "Keys", head(entryMod, "host.sim.template.RestartCmd", "host.sim.template.BridgeLiteral", "host.sim.template.ServerData") + [
      "/-! The entry's address groups, listed on its bridge-free view: the bridge is not constructor data. -/",
      "bridge_empty " + E + "V.s0 from " + T + ".s0",
      "server_data " + E + "V.S0 := " + T + ".S0",
      "def " + E + "V.frames : List Nat := " + T + ".frames",
      "tpl_keys " + E + "V",
      "theorem " + T + ".cover : \u2200 a x, " + T + ".s0.heap.get a = some x \u2192 a \u2209 " + T + ".frames \u2192 \u2203 q \u2208 " + E + "V.gks, a \u2208 q.2 :=",
      "  " + E + "V.cover",
      ""].join(NL));
    put(E + "Closed", head(a4b + "." + E + "Keys", "host.sim.template.Check", "host.sim.template.NShiftGen") + [
      "abbrev T.n : Nat := " + st.n,
      "kernel_rfl T.tab_len : T.S0.tab.length = T.n",
      "kernel_rfl T.frames_eq : T.frames = " + framesLit,
      "noncomputable def T.suppAt (a : Nat) : Bool :=",
      "  match T.s0.heap.get a with",
      "  | some h => bHobj (presentB T.s0) T.n h",
      "  | none => true",
      "noncomputable def T.boundAt (a : Nat) : Bool := Nat.blt a T.s0.next",
      "",
      "tpl_all_blocks T.HS from T : T.suppAt",
      "kernel_rfl T.suppFramed : T.frames.all T.suppAt = true",
      "tpl_all_blocks T.BD from T : T.boundAt",
      "kernel_rfl T.boundFramed : T.frames.all T.boundAt = true",
      "kernel_rfl T.rootsSupp_check : checkRootsSupp T.s0 T.n = true",
      "",
      "theorem T.allPresent {p : Nat \u2192 Bool} (hb : \u2200 q \u2208 " + E + "V.gks, \u2200 a \u2208 q.2, p a = true) (hf : T.frames.all p = true) :",
      "    \u2200 a, Present T.s0 a \u2192 p a = true := by",
      "  intro a ha",
      "  obtain \u27E8h, hg\u27E9 := Present.get ha",
      "  by_cases hm : a \u2208 T.frames",
      "  \u00B7 exact List.all_eq_true.mp hf a hm",
      "  \u00B7 obtain \u27E8q, hq, haq\u27E9 := T.cover a h hg hm",
      "    exact hb q hq a haq",
      "",
      "theorem T.heapSupp : \u2200 a h, T.s0.heap.get a = some h \u2192 Supp.hobj (Present T.s0) T.n h := by",
      "  intro a h ha",
      "  have hp := T.allPresent T.HS.all T.suppFramed a (Present.of_get ha)",
      "  unfold T.suppAt at hp",
      "  rw [ha] at hp",
      "  exact bHobj_sound hp",
      "",
      "theorem T.rootsSupp : Supp.ctl (Present T.s0) T.n T.s0.ctl \u2227",
      "    (\u2200 f \u2208 T.s0.stack, Supp.frame (Present T.s0) T.n f) \u2227",
      "    (\u2200 j \u2208 T.s0.jobs, Supp.job (Present T.s0) T.n j) \u2227 Supp.stores (Present T.s0) T.n T.s0.stores :=",
      "  checkRootsSupp_sound T.rootsSupp_check",
      "",
      "theorem T.presentBound : \u2200 a, Present T.s0 a \u2192 a < T.s0.next := by",
      "  intro a ha",
      "  have := T.allPresent T.BD.all T.boundFramed a ha",
      "  unfold T.boundAt at this",
      "  simpa [Nat.blt_eq] using this",
      ""].join(NL).replaceAll("T.", T + ".").replaceAll(" from T ", " from " + E + "V "));
    put(E + "Fresh", head(a4b + "." + E + "Closed", "host.sim.BigFree", "host.sim.native.RebigR", "host.sim.compose.JsAbove") + [
      "kernel_rfl T.hnext : " + mlx("T.s0") + ".next = " + st.mnext,
      "noncomputable def T.freshAt (a : Nat) : Bool := noBigAtB " + st.mnext + " 131072 T.s0 a",
      "tpl_all_blocks T.FB from T : T.freshAt",
      "kernel_rfl T.freshFramed : T.frames.all T.freshAt = true",
      "kernel_rfl T.freshRoots : noBigRootsB " + st.mnext + " 131072 T.s0.trace T.s0 = true",
      "kernel_rfl T.nativeFresh : bigsOutB " + st.mnext + " 131072 " + mlx("T.s0") + " = true",
      "theorem T.noBigFresh : NoBigSt (fun i => (" + st.mnext + " : Int) \u2264 i \u2227 i < 131072) T.s0.trace T.s0 :=",
      "  NoBigSt.of_checks (fun a ha => T.allPresent T.FB.all T.freshFramed a ha) T.freshRoots",
      "",
      "noncomputable def T.jsAt (a : Nat) : Bool := noBigAtP (jsAboveB " + st.next + ") T.s0 a",
      "tpl_all_blocks T.JH from T : T.jsAt",
      "kernel_rfl T.jsFramed : T.frames.all T.jsAt = true",
      "kernel_rfl T.jsRoots : noBigRootsP (jsAboveB " + st.next + ") T.s0.trace T.s0 = true",
      "kernel_rfl T.jsNative : bigsOutB jsLoN jsHiN " + mlx("T.s0") + " = true",
      "theorem T.jsHeap : JsHeapAbove " + st.next + " T.s0 := by",
      "  intro a o ho",
      "  have hc := T.allPresent T.JH.all T.jsFramed a (Present.of_get ho)",
      "  unfold T.jsAt noBigAtP at hc",
      "  rw [ho] at hc",
      "  exact noBigHobjP_sound (fun _ hi => hi) hc",
      ""].join(NL).replaceAll("T.", T + ".").replaceAll(" from T ", " from " + E + "V "));
  }
  if (walkAt) {
    const wf = walkMod.split(".").pop()!;
    writeFileSync(join(out, wf + ".lean"), head(entryMod, endMod, "host.sim.template.RestartCmd", "host.sim.template.BridgeLiteral", "host.sim.template.ServerData") + [
      "/-! The map from the pre-final template into the tail's end, chosen natively on the bridge-free views",
      "of both states. Everything about it is a later kernel check. -/",
      "bridge_empty " + walk + ".s0 from " + s0,
      "server_data " + walk + ".S0 := " + S0,
      "bridge_empty " + walk + ".s" + Ti + " from " + s1,
      "server_data " + walk + ".S" + Ti + " := " + S1,
      "def " + walk + ".frames : List Nat := " + T + ".frames",
      "def " + walk + ".ghosts : List Nat := " + T + ".ghosts",
      "def " + walk + ".maps : List Nat := " + T + ".maps",
      "set_option interpreter.prefer_native true in",
      "tpl_restart " + walk + ".R : " + walk + ", " + walk + " " + Ti + " (\u00ABworld\u00BB := " + walkAt + ".nativeWorld)",
      ""].join(NL) + NL + "end Host.Load.Run.Tpl" + NL);
  }
  const R = walk + ".R", D = R + ".data", sg = D + ".map", P = name + ".P0", x0 = name + ".x0", x1 = name + ".x1";
  put(name + "Heap", head(walkMod, a4b + "." + E + "Keys") + "tpl_heap_blocks " + R + " from " + E + "V : " + sg + ", " + s0 + ", " + s1 + NL);
  const ck = (nm: string, stmt: string) => "kernel_rfl " + name + ".n" + nm + " : " + stmt + NL;
  const chunked = (nm: string, list: string, n: number, kind: "all" | "map", stmt: (l: string) => string, chunk: number = 2000) => {
    const m = Math.max(1, Math.ceil(n / chunk));
    let l = list;
    const ls: string[] = [];
    for (let j = 0; j <= m; j++) { ls.push(l); l = "(" + l + ").drop " + chunk; }
    const chunks = Array.from({ length: m }, (_, j) => "kernel_rfl " + name + ".n" + nm + "_" + j + " : " + stmt("(" + ls[j] + ").take " + chunk) + NL);
    const step = kind === "all" ? "all_take_drop" : "map_take_drop", nil = kind === "all" ? "all_of_nil" : "map_of_nil";
    let proof = nil + " " + name + ".n" + nm + "_end";
    for (let j = m - 1; j >= 0; j--) proof = step + " " + chunk + " " + name + ".n" + nm + "_" + j + " (" + proof + ")";
    return { chunks, assemble: "kernel_rfl " + name + ".n" + nm + "_end : " + ls[m] + " = []" + NL + "theorem " + name + ".n" + nm + " : " + stmt(list) + " :=" + NL + "  " + proof + NL };
  };
  const hs = chunked("handles", "handlesOfA " + x0, st.mnext + 4000, "all", l => "(" + l + ").all (handleOK " + sg + " " + P + ".lo " + x0 + " " + x1 + ") = true");
  const ns = chunked("nodes", "PTrie.keysA " + x0 + ".nodes", st.nnext, "all", l => "(" + l + ").all (nodeOKF " + sg + " " + P + " " + x0 + " " + x1 + ") = true");
  const ps = chunked("prims", "fullKeysF " + P + " " + x0, st.nnext, "map", l =>
    "(" + l + ").map (fun i => (" + x1 + ".nodes.get (" + sg + ".node i)).map Host.Mlx.Ffi.Node.prim) =" + NL + "  (" + l + ").map (fun i => (" + x0 + ".nodes.get i).map fun nd => " + sg + ".prim nd.prim)");
  // the template's table starts with the state's (one pass); only its new entries are looked up
  const nHead = Math.min(...(tm.entries as { ref: number }[]).map(e => e.ref));
  const fields = ["nh0", "nh1", "nn0", "nn1", "lo", "cnt", "nband", "hbelow", "handles", "hren", "band", "nh1pos", "objs", "objok",
    "nodes", "prims", "nren", "nlow", "nord", "items", "ssT", "abs0a", "abs0b", "tok1", "pend", "errh", "files", "arch", "sizes", "wired"];
  put(name + "Na", head(walkMod, a4b + "." + E + "Closed", "host.sim.template.NShiftOf", "host.sim.compose.PfLink") +
    "def " + P + " : LoadP := setupP.raise " + st.nnext + NL +
    "noncomputable abbrev " + name + ".y0 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad " + s0 + ".ffi)" + NL +
    "noncomputable abbrev " + name + ".y1 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad " + s1 + ".ffi)" + NL +
    "noncomputable abbrev " + x0 + " : NSt := " + name + ".y0.mlx" + NL +
    "noncomputable abbrev " + x1 + " : NSt := " + name + ".y1.mlx" + NL +
    "noncomputable def " + name + ".thetaX : List (Nat \u00D7 SymE) := [" + thetaExtra + "]" + NL +
    "noncomputable def " + name + ".\u03B8 : Nat \u2192 SymE := thetaOf (" + R + ".theta ++ " + name + ".thetaX)" + NL +
    "noncomputable def " + name + ".numAt (i : Nat) : Bool := match nth? " + S0 + ".tab i with" + NL +
    "  | some e => decide ((\u27E8" + S1 + ".tab, []\u27E9 : SSrv).val (" + sg + ".num i) = some (e.subst " + name + ".\u03B8))" + NL +
    "  | none => true" + NL + NL + [
    ck("nh0", D + ".nh0 = " + x0 + ".next"), ck("nh1", D + ".nh1 = " + x1 + ".next"), ck("nn0", D + ".nn0 = " + x0 + ".nnext"),
    ck("nn1", D + ".nn1 = " + x1 + ".nnext"),
    ck("lo", "(Nat.blt 0 " + P + ".lo && Nat.ble " + P + ".lo " + x0 + ".next && Nat.ble " + P + ".lo RData.bigHi && Nat.ble RData.bigHi " + P + ".E) = true"),
    ck("cnt", "(Nat.ble " + x0 + ".next " + x1 + ".next && Nat.ble " + x0 + ".nnext " + x1 + ".nnext) = true"),
    ck("nband", "(Nat.blt 0 " + P + ".NL && Nat.ble " + P + ".NL " + P + ".N0 && Nat.ble " + P + ".N0 " + x0 + ".nnext) = true"),
    ck("hbelow", D + ".checkHndBelow = true"),
    ck("hren", "checkRenG " + D + ".hnd " + R + ".hinv (phB " + x0 + ") = true"),
    ck("band", D + ".checkBand " + P + ".lo = true"), ck("nh1pos", "Nat.blt 0 " + D + ".nh1 = true"),
    ck("nren", "checkRenG " + D + ".node " + R + ".ninv (pnB " + x0 + ") = true"),
    ck("nlow", "(PTrie.keysA " + D + ".node).all (fun j => Nat.ble " + P + ".NL j && Nat.blt (" + D + ".nodeF j) " + x1 + ".nnext) = true"),
    ck("nord", "(fullAbove " + P + " " + x0 + ").all (fun i => Nat.ble i (" + D + ".nodeF i) &&" + NL + "  (PTrie.keysA " + D + ".node).all fun j => !Nat.blt j i || Nat.blt (" + D + ".nodeF j) (" + D + ".nodeF i)) = true"),
    ck("items", "(PTrie.keysA " + x0 + ".items).all (pnB " + x0 + ") = true"), ck("ssT", "checkSSt " + T + ".n " + x0 + " = true"),
    ck("abs0a", x0 + ".arrs.get 0 = none"), ck("abs0b", x0 + ".objs.get 0 = none"), ck("tok1", x1 + ".tokens = []"),
    ck("pend", x1 + ".pending = " + x0 + ".pending.map " + sg + ".pend"), ck("errh", x1 + ".errh = " + x0 + ".errh.map " + sg + ".arg"),
    ck("files", x1 + ".files = " + x0 + ".files"), ck("arch", x1 + ".arch = " + x0 + ".arch"),
    ck("sizes", x1 + ".deviceSizes = " + x0 + ".deviceSizes"), ck("wired", x1 + ".wired = " + x0 + ".wired"),
    ck("host", name + ".y1.host = " + name + ".y0.host")].join(""));
  const cks = [ck("objs", "(PTrie.keysA " + x0 + ".objs).map (fun h => " + x1 + ".objs.get (" + sg + ".handle h)) =" + NL + "  (PTrie.keysA " + x0 + ".objs).map (fun h => (" + x0 + ".objs.get h).map " + sg + ".nobj)") +
    ck("objok", "(PTrie.keysA " + x0 + ".objs).all (objOK " + sg + " " + P + ".NL " + x0 + ") = true"), ...hs.chunks, ...ns.chunks, ...ps.chunks];
  cks.forEach((body, j) => put(name + "Nc_" + j, head(a4b + "." + name + "Na") + body));
  put(name + "Nb", head(...cks.map((_, j) => a4b + "." + name + "Nc_" + j)) + hs.assemble + ns.assemble + ps.assemble + NL +
    "theorem " + name + ".nshift : NShift " + P + " " + T + ".n " + sg + " " + name + ".y0 " + name + ".y1 :=" + NL +
    "  nshift_of \u27E8rfl, rfl, rfl, " + fields.map(f => name + ".n" + f).join(", ") + "\u27E9 " + name + ".nhost fun _ => rfl" + NL);
  const fq = (a: string) => "(Host.Ts.Sim.Full.mlxOf " + a + ".ffi)";
  put(name + "Full", head(a4b + "." + name + "Nb", "host.sim.template.FullShiftGen") + [
    "kernel_rfl N.tokens : " + fq(s1) + ".tokens = " + fq(s0) + ".tokens.map " + sg + ".nv",
    "kernel_rfl N.tokSupp : " + fq(s0) + ".tokens.all (bSN " + T + ".n) = true",
    "kernel_rfl N.bridge : bridgeOf " + s1 + ".ffi = bridgeOf " + s0 + ".ffi",
    "kernel_rfl N.live : liveShiftB " + sg + " " + fq(s0) + " (freedOf " + s0 + ".ffi) (freedOf " + s1 + ".ffi) = true",
    "kernel_rfl N.kern : kernShiftB " + sg + " " + T + ".n " + fq(s0) + " (krecOf " + s0 + ".ffi) (krecOf " + s1 + ".ffi) = true",
    "kernel_rfl N.pendR : pendRegB " + sg + " " + fq(s0) + " = true",
    "kernel_rfl N.pendLe : Nat.ble " + fq(s0) + ".next " + fq(s1) + ".next = true",
    "",
    "theorem N.fullShift : Conv.FullShiftQ " + P + " " + T + ".n " + sg + " " + s0 + ".ffi " + s1 + ".ffi :=",
    "  \u27E8N.nshift, N.tokens, fun t ht => bSN_sound (List.all_eq_true.mp N.tokSupp t ht), N.bridge,",
    "    liveShift_of N.live, kernShift_of N.kern,",
    "    pendReg_of rfl N.nnh0 N.nnh1 (Nat.le_of_ble_eq_true N.pendLe) N.pendR\u27E9",
    ""].join(NL).replaceAll("N.", name + "."));
  const frs = dropList ? [["P", "2665"]] : [["P", "2665"], ["C", "D1Frames.chunk"]];
  const sf = dropList ? [] : [["B", "D1Frames.buffer"], ["V", "D1Frames.view"]];
  // one module per kind of whole-state check: a single check can need more memory than the rest together
  const kchecks: string[][] = [[
    "kernel_rfl N.numId : numIdB " + D + " " + nHead + " = true",
    "kernel_rfl N.numHead : (" + S0 + ".tab.take " + nHead + ").map (\u00B7.subst N.\u03B8) = " + S1 + ".tab.take " + nHead,
    "kernel_rfl N.numTail : (List.range' " + nHead + " (" + S0 + ".tab.length - " + nHead + ")).all N.numAt = true",
    "theorem N.num : checkNum " + sg + " N.\u03B8 \u27E8" + S0 + ".tab, []\u27E9 \u27E8" + S1 + ".tab, []\u27E9 = true :=",
    "  checkNum_split N.numId N.numHead N.numTail (fun i e he h => by",
    "    unfold N.numAt at h",
    "    rw [he] at h",
    "    exact of_decide_eq_true h)",
    ...[...frs, ...sf].map(([k, a]) => "kernel_rfl N.fix" + k + " : " + D + ".a " + a + " = " + a)], [
    ...frs.flatMap(([k, a]) => [
      "kernel_rfl N.get" + k + " : " + s0 + ".heap.get " + a + " = some (.obj (Template.objOf " + s0 + " " + a + "))",
      "kernel_rfl N.kind" + k + " : (Template.objOf " + s0 + " " + a + ").kind = .array []",
      "kernel_rfl N.img" + k + " : " + s1 + ".heap.get " + a + " = some (.obj { " + sg + ".obj (Template.objOf " + s0 + " " + a + ") with kind := .array ([] ++ arrOf " + s1 + " " + a + ") })"]),
    ...sf.flatMap(([k, a]) => [
      "kernel_rfl N.get" + k + " : (" + s0 + ".heap.get " + a + ").isSome = true",
      "kernel_rfl N.img" + k + " : " + s1 + ".heap.get " + a + " = (" + s0 + ".heap.get " + a + ").map " + sg + ".hobj"]),
    ...(dropList ? [
      "kernel_rfl N.emptyP : arrOf " + s1 + " 2665 = []",
      "noncomputable def N.ndAt (a : Nat) : Bool := [" + dropList + "].all fun b => !Nat.beq (" + D + ".a a) b",
      "tpl_all_blocks N.ND from " + E + "V : N.ndAt",
      "kernel_rfl N.ndFramed : " + T + ".frames.all N.ndAt = true"]
    : ["kernel_rfl N.framesEmpty : [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view].all (fun a => (arrOf " + s1 + " a).isEmpty) = true"])], [
    "kernel_rfl N.n0 : " + D + ".n0 = " + s0 + ".next",
    "kernel_rfl N.n1 : " + D + ".n1 = " + s1 + ".next",
    "kernel_rfl N.grows : Nat.ble " + s0 + ".next " + s1 + ".next = true",
    "kernel_rfl N.ren : checkRen " + s0 + " " + D + " " + R + ".inv = true"], [
    "kernel_rfl N.ctl : " + s1 + ".ctl = " + sg + ".ctl " + s0 + ".ctl",
    "kernel_rfl N.stack : " + s1 + ".stack = " + s0 + ".stack.map " + sg + ".frame",
    "kernel_rfl N.jobs : " + s1 + ".jobs = " + s0 + ".jobs.map " + sg + ".job",
    "kernel_rfl N.stores : " + s1 + ".stores = " + sg + ".stores " + s0 + ".stores"], [
    "kernel_rfl N.band : " + D + ".checkBand 18151 = true",
    "kernel_rfl N.nh0le : Nat.ble 18151 " + D + ".nh0 = true",
    "kernel_rfl N.intr : (List.range 40).all (fun a => Nat.beq (" + D + ".a a) a) = true",
    "kernel_rfl N.inactive : (bridgeOf " + s0 + ".ffi).active = false",
    "kernel_rfl N.lo : Nat.ble 18151 " + fq(s0) + ".next = true",
    "kernel_rfl N.hi0 : Nat.ble " + fq(s0) + ".next setupP.E = true",
    "kernel_rfl N.nhi0 : Nat.ble " + fq(s0) + ".nnext setupP.NE = true",
    "kernel_rfl N.hi1 : Nat.ble " + fq(s1) + ".next setupP.E = true",
    "kernel_rfl N.nhi1 : Nat.ble " + fq(s1) + ".nnext setupP.NE = true",
    "kernel_rfl N.jsKeys : (PTrie.keys " + D + ".heap).all (Nat.ble " + st.next + ") = true",
    "kernel_rfl N.jsLe : Nat.ble " + st.next + " " + D + ".n0 = true"]];
  kchecks.forEach((c, j) => put(name + "K" + j, head(a4b + "." + name + "Na", endMod, ...(j === 0 ? ["host.sim.compose.NumSplit"] : [])) + c.join(NL).replaceAll("N.", name + ".") + NL));
  put(name, head(a4b + "." + name + "Heap", a4b + "." + name + "Full", a4b + "." + E + "Fresh", ...kchecks.map((_, j) => a4b + "." + name + "K" + j)) + [
    (dropList
      ? "theorem N.facts : Pf.PfFacts " + s0 + " " + s1 + " " + S0 + ".tab " + S1 + ".tab " + D + " " + R + ".inv N.\u03B8 " + P + " " + st.next + " [" + dropList + "] where"
      : "theorem N.facts : Post.LinkFacts " + s0 + " " + s1 + " " + S0 + ".tab " + S1 + ".tab " + D + " " + R + ".inv N.\u03B8 " + P + " " + st.next + " where"),
    "  num := N.num",
    "  heap := by",
    "    intro a h ha hm",
    dropList
      ? "    obtain \u27E8q, hq, haq\u27E9 := " + T + ".cover a h ha (fun hf => hm (by rw [" + T + ".frames_eq] at hf; simpa using hf))"
      : "    obtain \u27E8q, hq, haq\u27E9 := " + T + ".cover a h ha (fun hf => hm (Post.frames_perm (by rw [" + T + ".frames_eq] at hf; exact hf)))",
    "    have he := " + R + ".heapAt q hq a haq",
    "    rw [ha] at he",
    "    exact he",
    ...[...frs, ...sf].map(([k]) => "  fix" + k + " := N.fix" + k),
    ...frs.flatMap(([k]) => ["  get" + k + " := N.get" + k, "  kind" + k + " := N.kind" + k, "  img" + k + " := N.img" + k]),
    ...sf.flatMap(([k]) => ["  get" + k + " := N.get" + k, "  img" + k + " := N.img" + k]),
    ...(dropList ? [
      "  emptyP := N.emptyP",
      "  notDrop := by",
      "    intro a ha b hb he",
      "    have hc := " + T + ".allPresent N.ND.all N.ndFramed a ha",
      "    unfold N.ndAt at hc",
      "    have h2 := List.all_eq_true.mp hc b hb",
      "    rw [he] at h2",
      "    simp at h2"] : ["  framesEmpty := N.framesEmpty"]),
    "  n0 := N.n0",
    "  n1 := N.n1",
    "  grows := Nat.le_of_ble_eq_true N.grows",
    "  ren := N.ren",
    "  bound := " + T + ".presentBound",
    "  ctl := N.ctl",
    "  stack := N.stack",
    "  jobs := N.jobs",
    "  stores := N.stores",
    "  heapSupp := by rw [" + T + ".tab_len]; exact " + T + ".heapSupp",
    "  ctlSupp := by rw [" + T + ".tab_len]; exact " + T + ".rootsSupp.1",
    "  stackSupp := by rw [" + T + ".tab_len]; exact " + T + ".rootsSupp.2.1",
    "  jobsSupp := by rw [" + T + ".tab_len]; exact " + T + ".rootsSupp.2.2.1",
    "  storesSupp := by rw [" + T + ".tab_len]; exact " + T + ".rootsSupp.2.2.2",
    "  band := N.band",
    "  nh0 := Nat.le_of_ble_eq_true N.nh0le",
    "  intr := by",
    "    intro a ha",
    "    have := N.intr",
    "    simp only [List.all_eq_true, List.mem_range, Nat.beq_eq] at this",
    "    exact this a ha",
    "  shift := by rw [" + T + ".tab_len]; exact N.fullShift",
    "  inactive := N.inactive",
    "  raised := .inr \u27E8" + st.nnext + ", rfl, by decide, rfl\u27E9",
    "  bigs := by",
    "    change bigsOutB " + mlx(s0) + ".next 131072 " + mlx(s0) + " = true",
    "    rw [" + T + ".hnext]",
    "    exact " + T + ".nativeFresh",
    "  free := by",
    "    change NoBigSt (fun i => (" + mlx(s0) + ".next : Int) \u2264 i \u2227 i < 131072) " + s0 + ".trace " + s0,
    "    rw [" + T + ".hnext]",
    "    exact " + T + ".noBigFresh",
    "  loLe := Nat.le_of_ble_eq_true N.lo",
    "  hi0 := Nat.le_of_ble_eq_true N.hi0",
    "  nhi0 := Nat.le_of_ble_eq_true N.nhi0",
    "  hi1 := Nat.le_of_ble_eq_true N.hi1",
    "  nhi1 := Nat.le_of_ble_eq_true N.nhi1",
    "  jsHeap := " + T + ".jsHeap",
    "  jsRoots := " + T + ".jsRoots",
    "  jsNative := " + T + ".jsNative",
    "  jsFix := Pf.jsFix_of_keys (Nat.le_of_ble_eq_true N.jsLe) N.jsKeys",
    ""].join(NL).replaceAll("N.", name + "."));
  console.log(name + ": link modules written, " + cks.length + " native check modules");
}

if (process.argv[2] === "post-link") genPostLink(process.argv.slice(3));
if (process.argv[2] === "prefill-body") genBodyFill(process.argv.slice(3));
