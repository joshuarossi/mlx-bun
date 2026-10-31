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
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
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
        exacts [${frs.slice(0, 3).map(fa => `⟨${c(`zg${k}_${fa}`)}, ${c(`zk${k}_${fa}`)}, ${c(`zm${k}_${fa}`)}⟩`).join(", ")}])
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
  writeFileSync(file, `import host.sim.compose.a4b.D1BodyFill
namespace Host.Ts.Sim.Compose.FillD1First
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

noncomputable def pc0 := SetupCommon.nextCut
noncomputable def b_g1_FIN_first_i (NB T : Nat) (tk : Nat → Nat) : Cls.Inst → ICut FF :=
  fun _ => D1First.g1Cut NB T tk
noncomputable def b_g1_FIN_first_o (NB T : Nat) (tk : Nat → Nat) : Cls.Inst → ICut FF :=
  fun _ => D1First.dispatchCut NB T tk
noncomputable def b_g2_fin_first_i (NB T : Nat) (tk : Nat → Nat) : Cls.Inst → ICut FF :=
  fun _ => D1First.g2Cut NB T tk
noncomputable def b_g2_fin_first_o (NB T : Nat) (tk : Nat → Nat) : Cls.Inst → ICut FF :=
  fun _ => D1First.forwardCut NB T tk
noncomputable def b_g3f_first_i (NB T : Nat) (tk : Nat → Nat) : Cls.Inst → ICut FF :=
  fun _ => D1First.returnedSavedCut NB T tk

noncomputable def nps_FIN_first__start__g1_FIN_first := D1First.nps_FIN_first__start__g1_FIN_first
noncomputable def g1_FIN_first := D1First.g1_FIN_first
noncomputable def disp_D1__g1_FIN_first__g2_fin_first := D1First.disp_D1__g1_FIN_first__g2_fin_first
noncomputable def g2_fin_first := D1First.g2_fin_first
noncomputable def fwd_D1_cold_DFirst__g2_fin_first__g3f_first := D1First.fwd_D1_cold_DFirst__g2_fin_first__g3f_first
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
  const defaultRows = owner?.uses ?? [chain.row];
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
      const rows = `[${(piece?.uses ?? defaultRows).join(", ")}]`;
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
    const rows = `[${(piece?.uses ?? defaultRows).join(", ")}]`;
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
noncomputable def ${X}.b_g0a_o (NB T : Nat) (tk : Nat → Nat) (i : Cls.Inst) : ICut FF :=
  withSetupInputs T tk (SetupChunk.chunkCallFixedCut NB T tk i.L)
noncomputable def ${X}.b_g0b_i (NB T : Nat) (tk : Nat → Nat) : Cls.Inst → ICut FF :=
  SetupCommon.cut NB T tk Host.Load.Run.Tpl.PRE_g0b.s0 Host.Load.Run.Tpl.PRE_g0b.S0
noncomputable def ${X}.pc0 := SetupCommon.nextCut

noncomputable def ${X}.g0a := FillSetupEarly.g0a
noncomputable def ${X}.chunk_K8__g0a__g0b := FillSetupEarly.chunk_K8__g0a__g0b
noncomputable def ${X}.g0b := FillSetupEarly.g0b
`;
  }
  const render = (deps: Iterable<string>, body: string) => `${[...deps].map(x => `import ${x}`).join("\n")}
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
// `bodySize` are proved once. Usage: prefill-body <chain>:<case-dir> --out <dir> [--site k]... [--glue j]...
function genBodyFill(args: string[]) {
  const take = (flag: string) => {
    const out: string[] = [];
    for (let i = args.indexOf(flag); i >= 0; i = args.indexOf(flag)) out.push(args.splice(i, 2)[1]!);
    return out;
  };
  const outDir = take("--out")[0] ?? fail("prefill-body: --out <dir>");
  const onlySites = take("--site").map(Number), onlyGlues = take("--glue").map(Number);
  const streams = take("--streams")[0] ?? process.env.HOST_STREAM_DIR ?? join(HERE, "../../../.host-stream");
  const [, X0, dir] = args[0]?.match(/^([^:]+):(.+)$/) ?? fail("prefill-body: <chain>:<case-dir>");
  const X = X0!, full = `Host.Load.Run.Tpl.${X}`, stream = join(streams, full);
  const seg = JSON.parse(readFileSync(join(stream, "seg.json"), "utf8"));
  const tdir = join(HERE, "../template", dir!), mod = `host.sim.template.${dir!.replaceAll("/", ".")}`;
  const src = (f: string) => readFileSync(join(tdir, `${f}.lean`), "utf8");
  const oracleFiles = readdirSync(join(HERE, "a4b")).filter(f => /^VWBodyOracles_\d+\.lean$/.test(f));
  const oracleOf = new Map<string, { file: string; map: string; check: string }>();
  for (const f of oracleFiles) for (const m of readFileSync(join(HERE, "a4b", f), "utf8")
      .matchAll(/def \S+\.map_((?:g|site)\d+) : List \(Nat × Q\) := (.*)\n\nkernel_rfl \S+\.chk_\S+ : \(.*\n  (goodLin|goodEnum) /g))
    oracleOf.set(m[1]!, { file: f.slice(0, -5), map: m[2]!, check: m[3]! });
  const bridges = seg.bridges as any[];
  const stages = bridges.filter(b => b.kind === "stage").sort((a, b) => a.site - b.site);
  const parseMap = (s: string): [number, string][] =>
    [...s.matchAll(/\((\d+), Q\.(\w+)\)/g)].map(m => [+m[1]!, m[2]!]);
  const head = (imports: string[]) => `${[...new Set(imports)].map(i => `import ${i}`).join("\n")}
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace ${NS}.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open ${NS}.SetupEarly ${NS}.SetupChunk

`;
  const tail = `\nend ${NS}.VWFirst\n`;
  mkdirSync(outDir, { recursive: true });
  // One map for the whole chain: its last glue's cumulative map holds every variable the oracle reads.
  const allMap = oracleOf.get(`g${stages.length}`) ?? fail(`no map_g${stages.length}`);
  const bodyQ = new Map(parseMap(allMap.map));
  writeFileSync(join(outDir, "VWBodyMap.lean"), head(["host.sim.compose.a4b.VWBodyBase", `${mod}.H0`, "host.sim.lin.Table"]) +
    `def bodyM : List (Nat × Q) := ${allMap.map}

kernel_rfl bodyGoodAll : (fwdRows.all fun r => goodLin r.ps (varsOf r.V bodyM) ${X}.OR) = true

theorem bodyGoodDrop {r : Row} {i : Cls.Inst} {ν : Nat → F64} (hr : r ∈ fwdRows) (hi : InRow r i)
    (hν : MapOk ν i bodyM) (d : Nat) : Good ν (List.drop d ${X}.OR) :=
  fun q hq => good_of_row (List.all_eq_true.mp bodyGoodAll r hr) hi hν q (List.mem_of_mem_drop hq)
` + tail);
  const cnt = (s: string) => s.replace(/\s/g, "");
  // the offsets: 3571 at the start, each compaction adds its discarded addresses
  let D = 3571, H = 0, N = 0;
  const Ds = new Map<number, string>([[0, `⟨${D}, ${H}, ${N}⟩`]]);
  for (const b of stages) {
    const k = b.site as number, a = b.ia as number, m = a + 1, cn = a + 2;
    const c = b.compaction;
    const siteZ = src(`SiteZ${k}`), glue = src(`GlueN${k}`);
    const counters = glue.match(new RegExp(`theorem ${X}\\.gjcl${k} \\(h : Conv\\.JClean \\((⟨[^⟩]*⟩) : Conv\\.Cnt\\) ${X}\\.s(\\d+)\\) : Conv\\.JClean \\((⟨[^⟩]*⟩)`)) ?? fail(`${X}: GlueN${k}: gjcl`);
    const cAfter = siteZ.match(new RegExp(`theorem ${X}\\.cjcl${k} \\(h : Conv\\.JClean \\(⟨[^⟩]*⟩ : Conv\\.Cnt\\) ${X}\\.s${a}\\) : Conv\\.JClean \\((⟨[^⟩]*⟩)`)) ?? fail(`${X}: SiteZ${k}: cjcl`);
    const nC = +(siteZ.match(new RegExp(`znC${k} : .* = (\\d+)`)) ?? fail("znC"))[1]!;
    const n1 = +(siteZ.match(new RegExp(`zsmn${k} : .* = (\\d+)`)) ?? fail("zsmn"))[1]!;
    const tpl = readFileSync(join(tdir, `st${k}/TypedTpl.lean`), "utf8");
    const nSteps = +(tpl.match(/\n  n := (\d+)/) ?? fail(`st${k}: n`))[1]!;
    const T1 = +(tpl.match(new RegExp(`S2 := ${X}\\.st${k}\\.S(\\d+)`)) ?? fail(`st${k}: S2`))[1]!;
    const site = oracleOf.get(`site${k}`) ?? fail(`no map_site${k}`);
    const cws = c.ws as number[];
    const qs = cws.map(v => bodyQ.has(v) ? `some Q.${bodyQ.get(v)}` : "none");
    const drop = n1 - +(src(`SiteC${k}`).match(new RegExp(`cnext${k} : .* = (\\d+)`)) ?? fail("cnext"))[1]!;
    const [cxn, cnn] = cAfter[1]!.slice(1, -1).split(",").map(Number) as [number, number];
    const Dnext = D + drop, Hnext = H + (c.xn1 - cxn), Nnext = N + (c.nn1 - cnn);
    const off = `⟨${D}, ${H}, ${N}⟩`, offNext = `⟨${Dnext}, ${Hnext}, ${Nnext}⟩`;
    const sel = !onlySites.length && !onlyGlues.length || onlySites.includes(k);
    if (sel) {
      const prevJs = k === 0 ? "bodyStartJs" : `bodyJs${k - 1}`, prevN = k === 0 ? "2673488" : `${X}.s${stages[k - 1].ia}.next`;
      const prevClean = k === 0 ? "bodyStartClean" : `(${X}.cjcl${k - 1} bodyClean${k - 1})`;
      const prevNcl = k === 0 ? `${X}.ncl0` : `(${X}.cncl${k - 1} bodyNcl${k - 1})`;
      const cshift = (src(`SiteR${k}`).match(new RegExp(`theorem ${X}\\.cshiftR${k} [\\s\\S]*?(?=\\nend Host)`)) ?? fail(`SiteR${k}`))[0]!
        .replace(`${X}.cshiftR${k} `, `bodyCshift${k} `).replaceAll(`${X}.ncl${a} `, `bodyNcl${k} `);
      writeFileSync(join(outDir, `VWBodyJ${k}.lean`), head([
        k === 0 ? "host.sim.compose.a4b.VWBodyBase" : `host.sim.compose.a4b.VWBodyJ${k - 1}`,
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
        `host.sim.compose.a4b.VWBodyJ${k}`, `host.sim.compose.a4b.VWBodySite${k}`,
        `host.sim.compose.a4b.${site.file}`, "host.sim.compose.a4b.VWBodyMap",
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
kernel_rfl bodyStart2665 : arrOf ${X}.s0 2665 = []
kernel_rfl bodyStartChunk : arrOf ${X}.s0 VWFrames.chunk = []

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
  zroots2 := ${X}.zroots2${k}
  cntM := bodyCntM${k}
  hiLe := Nat.le_of_ble_eq_true bodyHi${k}
  nhiLe := Nat.le_of_ble_eq_true bodyNhi${k}
  jsHeap := bodyJs${k}
  jsRoots := bodyJsRoots${k}
  jsNative := bodyJsNative${k}
  framesEmpty := bodyFramesEmpty${k}
  inputOld := by decide
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

theorem bodyStep${k} (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i ${off} bodyM ${X}.s${a} ${X}.S${a})
      (bodyCut NB T tk π i ${offNext} bodyM ${X}.s${cn} ${X}.S${cn}) (${nSteps} + 1) :=
  bodySite (n := ${nSteps}) (S2 := ${X}.st${k}.S${T1}.tab) (Es := bodyEs${k}) (qs := bodyQs${k})
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
` + tail);
      console.log(`${X}: site ${k} (${a}): ${off} -> ${offNext}, ${nSteps} + 1 steps`);
    }
    D = Dnext; H = Hnext; N = Nnext;
    Ds.set(k + 1, offNext);
  }
  // the glue stretches: typed runs and size bridges between the calls
  const stepsAt = new Map<string, { name: string; file: string }>();
  for (const f of readdirSync(tdir).filter(f => /^TypedSteps\d+\.lean$/.test(f)))
    for (const m of readFileSync(join(tdir, f), "utf8").matchAll(new RegExp(`boot_rfl ${X}\\.(body(?:StepA|StepB|PatchB)\\d*) from ${X}\\.s(\\d+) to ${X}\\.s(\\d+)`, "g")))
      stepsAt.set(`${m[2]}->${m[3]}`, { name: m[1]!, file: f.slice(0, -5) });
  const ranges = [...src("Run").matchAll(/^sim_chain_range \S+ \S+ (\d+) (\d+) runSeg(\d+)$/gm)]
    .map(m => ({ a: +m[1]!, b: +m[2]!, r: +m[3]! }));
  const sizeIdx = new Map<number, number>();
  for (const m of src("Bridge").matchAll(new RegExp(`kernel_rfl ${X}\\.sizeA(\\d+) : Host\\.Ts\\.Sim\\.Disp\\.sizeParts ${X}\\.s(\\d+)`, "g")))
    sizeIdx.set(+m[2]!, +m[1]!);
  const chain = JSON.parse(readFileSync(join(stream, "chain.json"), "utf8"));
  const fuelOf = (k: number) => `${X}.ks`;
  for (const p of chain.pieces.filter((p: any) => p.glue !== undefined)) {
    const j = +p.glue.slice(1);
    if (onlySites.length || onlyGlues.length) { if (!onlyGlues.includes(j)) continue; }
    const stage = stages.find(b => b.site === j);
    const start = p.from as number, last = stage ? stage.ia as number : p.to as number;
    const inside = bridges.filter(b => b.kind === "size" && b.ia > start && b.ia <= last).sort((x, y) => x.ia - y.ia);
    const Dj = Ds.get(j) ?? fail(`no offset at glue ${j}`);
    const imports = new Set<string>(["host.sim.compose.a4b.VWBodyGlue", "host.sim.compose.a4b.VWBodyBase",
      "host.sim.compose.a4b.VWBodyMap", `${mod}.Bridge`]);
    const hOf = (k: number) => imports.add(`${mod}.H${Math.floor(k / 32)}`);
    let facts = "", proof = "";
    const brEq = (k: number) => { facts += `kernel_rfl bodyBr${k} : bridgeOf ${X}.s${k}.ffi = bridgeOf ${X}.s0.ffi\n`; };
    const good = (k: number) => {
      facts += `kernel_rfl bodyO${k} : ${X}.S${k}.oracle = List.drop (${X}.OR.length - ${X}.S${k}.oracle.length) ${X}.OR\n`;
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
      pieces.push(`bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ${Dj}) ${acA} ${run} ${acB} bodyHalt${b} ${X}.${st.name} bodyTop${b + 1} ${brIn} ${active(a)} (bodyBr${b + 1}.trans bodyBr${a}.symm) ${cnt(a, b + 1)}`);
    };
    for (const br of inside) {
      if (br.ia === last) continue;
      toCall(br.ia - 1);
      const n = sizeIdx.get(br.ia) ?? fail(`no size bridge at ${br.ia}`);
      const patch = stepsAt.get(`${br.ia}->${br.ia + 1}`) ?? fail(`no patch ${br.ia}`);
      imports.add(`${mod}.${patch.file}`); hOf(br.ia + 1);
      const g0 = good(br.ia);
      brEq(br.ia + 1);
      pieces.push(`bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ${Dj}) ${X}.sizeA${n} ${X}.sizeArgsA${n} ${X}.sizeSymA${n} ${X}.sizeMlxA${n} ${X}.sizePayA${n} ${X}.sizeTaA${n} ${X}.sizeDecA${n} ${X}.sizePreA${n} ${X}.${patch.name} ${g0} ${active(br.ia)} (bodyBr${br.ia + 1}.trans bodyBr${br.ia}.symm) ${cnt(br.ia, br.ia + 1)}`);
      a = br.ia + 1;
    }
    if (stage) toCall(last - 1);
    else {
      const brIn = good(a), acA = acc(a), run = seg(a, last);
      facts += `kernel_rfl bodyBr${last} : bridgeOf ${X}.s${last}.ffi = bridgeOf ${X}.s0.ffi\nkernel_rfl bodyTop${last} : noRetBlock ${X}.s${last} = true\n`;
      pieces.push(`bodyGlue (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (O := ${Dj}) ${acA} ${run} bodyTop${last} ${brIn} ${active(a)} (bodyBr${last}.trans bodyBr${a}.symm) ${cnt(a, last)}`);
    }
    const dedup = [...new Set(facts.split("\n"))].join("\n");
    proof = pieces.reduce((acc0, q) => acc0 ? `(${acc0}).trans (${q})` : q, "");
    writeFileSync(join(outDir, `VWBodyG${j}.lean`), head([...imports]) + `${dedup}
theorem bodyGlue${j} (NB T : Nat) (tk : Nat → Nat) (π : List Nat) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    ∃ n, CutStep (bodyCut NB T tk π i ${Dj} bodyM ${X}.s${start} ${X}.S${start})
      (bodyCut NB T tk π i ${Dj} bodyM ${X}.s${last} ${X}.S${last}) n :=
  ⟨_, ${proof}⟩
` + tail);
    console.log(`${X}: glue ${j} (${start}..${last}): ${pieces.length} pieces`);
  }
}

if (process.argv[2] === "prefill-body") genBodyFill(process.argv.slice(3));
