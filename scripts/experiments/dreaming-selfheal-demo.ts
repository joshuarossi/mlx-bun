// The Dreaming — REAL self-healing-through-time demo (GPU, single model load).
//
// ONE entity ("Focal Length Preference") is discussed in TWO conversations:
//   • the 35mm take — "35mm is my favorite, the one I reach for".
//   • the 50mm take — "50mm is my favorite now, far better for my work".
// We drive the staged synthesize worker CHRONOLOGICALLY — one synthesize pass
// per conversation in updated_at ASC order, exactly as the nightly appliance
// would as conversations arrive over time. The OLDER conversation CREATES the
// article; the NEWER one PATCHES it, and synthesizePatch folds the correction
// "toward the user's latest position". So the FINAL article reflects whichever
// take is NEWER.
//
// LATEST-WINS: the 50mm conversation is newer  ⇒ expect the article to favor 50mm.
// CONTROL:     swap the two timestamps (35mm newer) ⇒ expect it to favor 35mm.
// If swapping the timestamps flips the article's position, chronological ordering
// is genuinely driving the synthesis. Both scenarios run in ONE process ⇒ one
// model mount.

import { mkdtemp, mkdir, rm, writeFile, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { MemoryStore, chunkId } from "../../src/memory/db";
import { runRouteStage, runSynthesizeStage } from "../../src/memory/stages";
import { articleStructure, parseInfobox, parseLead } from "../../src/memory/article";
import { extractConvHashes } from "../../src/memory/gate";
import { assertsValueAsCurrent, isRelationshipKey } from "../../src/memory/reconcile";
import { extractSection, slugifyHeading } from "../../src/memory/vault";

const C35 = "33333333-3333-3333-3333-333333333333"; // the 35mm conversation
const C50 = "55555555-5555-5555-5555-555555555555"; // the 50mm conversation
const ENTITY = "Focal Length Preference";

// Three reinforcing user turns per conversation ⇒ three chunks each, so WHICHEVER
// conversation is processed first clears the recurrence create gate (the subject
// recurs across chunks) and drafts the article; the later one then patches it.
const TURNS_35 = [
  "On focal lengths: my favorite is 35mm. The 35mm prime is the one I reach for every single time.",
  "35mm suits the way I actually shoot better than anything else. It is my current favorite focal length.",
  "If I could keep only one lens it would be the 35mm. 35mm is my number-one pick, full stop.",
];
const TURNS_50 = [
  "On focal lengths: my favorite is 50mm. The 50mm prime is the one I reach for every single time.",
  "50mm suits the way I actually shoot better than anything else. It is my current favorite focal length.",
  "If I could keep only one lens it would be the 50mm. 50mm is my number-one pick, full stop.",
];

async function buildScenario(at35: number, at50: number): Promise<{ store: MemoryStore; root: string }> {
  const root = await mkdtemp(join(tmpdir(), "selfheal-"));
  await mkdir(join(root, "articles"), { recursive: true });
  await mkdir(join(root, "Meta"), { recursive: true });
  await writeFile(join(root, "Meta", "Entities.md"), "# Entities\n");
  const store = new MemoryStore(":memory:");
  store.db.run("INSERT OR IGNORE INTO entities (name, article_stem, kind, notable) VALUES (?, NULL, 'thing', 0)", [ENTITY]);

  const addConv = (conv: string, at: number, turns: string[]) => {
    store.db.run("INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", [
      conv, "pi-terminal", "focal length", at, at,
    ]);
    let pos = 0;
    for (const text of turns) {
      const start = pos;
      store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
        conv, pos++, "user", `${conv}-${start}`, text,
      ]);
      store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", [
        conv, pos++, "assistant", `${conv}-a${start}`, "Noted — I'll remember your focal-length preference.",
      ]);
      const cid = chunkId(conv, start, pos - 1);
      store.db.run("INSERT INTO chunks (id, conv, start, end, label) VALUES (?,?,?,?,?)", [
        cid, conv, start, pos - 1, "focal length preference",
      ]);
      store.db.run("INSERT OR IGNORE INTO chunk_entities (chunk_id, entity_name, surface_form) VALUES (?,?,?)", [
        cid, ENTITY, "focal length",
      ]);
    }
  };
  addConv(C35, at35, TURNS_35);
  addConv(C50, at50, TURNS_50);
  return { store, root };
}

/** Which focal length the article currently favors. The INFOBOX relationship field
 *  is the GROUND TRUTH (resolved date-driven, then propagated to the prose), so we
 *  read `favors` straight off it; the lead is returned for display/inspection. */
function judge(article: string): { favors: "50mm" | "35mm" | "unclear"; lead: string } {
  const box = parseInfobox(article);
  const fl = (box?.fields ?? []).filter((f) => /\d{2}mm/.test(f.value));
  let favors: "50mm" | "35mm" | "unclear" = "unclear";
  const field = fl.find((f) => f.value.includes("50mm") || f.value.includes("35mm"));
  if (field?.value.includes("50mm")) favors = "50mm";
  else if (field?.value.includes("35mm")) favors = "35mm";
  const lead = parseLead(article) ?? "";
  return { favors, lead };
}

// ---- full-article consistency analysis -------------------------------------
// After self-healing, the WHOLE article must agree with the latest-dated verdict:
// the lead, every relationship infobox field, and every body section. The
// superseded value may still APPEAR — but only framed as history ("originally
// 35mm[^1]; now 50mm[^2]"), never asserted as the CURRENT pick. Both citations
// must survive (provenance preserved).

/** Does `text` assert `mm` as the CURRENT favorite (not framed as history)?
 *  SINGLE SOURCE OF TRUTH: the same deterministic clause-level oracle
 *  (`assertsValueAsCurrent`) that drives the reconcile pass's retry — a value is
 *  "current" only when present-tense AND not past-framed in its own clause, so a
 *  clean "previously 35mm[^1]; now 50mm[^2]" reads 35mm as history, never current.
 *  (The earlier bespoke regex here had a literal bug — `\bprevious\b` did not match
 *  "previously" and omitted "was/were" — producing false positives on clean prose.) */
function assertsCurrent(text: string, mm: string): boolean {
  return assertsValueAsCurrent(text, mm);
}

interface ArticleReport {
  winner: "35mm" | "50mm";
  superseded: "35mm" | "50mm";
  leadFavorsWinner: boolean;
  leadAssertsStale: boolean;
  infoboxRelFields: { key: string; value: string }[];
  infoboxFavorsWinner: boolean;
  infoboxAssertsStale: boolean;
  staleSections: string[]; // section anchors still asserting the superseded value as current
  bothCitations: boolean; // both conv hashes survive
  convHashes: string[];
}

const C35_HASH = "33333333";
const C50_HASH = "55555555";

function analyze(article: string, winner: "35mm" | "50mm"): ArticleReport {
  const superseded = winner === "50mm" ? "35mm" : "50mm";
  const lead = parseLead(article) ?? "";
  const leadFavorsWinner = assertsCurrent(lead, winner) || (lead.toLowerCase().includes(winner) && !assertsCurrent(lead, superseded));
  const leadAssertsStale = assertsCurrent(lead, superseded);

  const box = parseInfobox(article);
  const rel = (box?.fields ?? []).filter((f) => isRelationshipKey(f.key)).map((f) => ({ key: f.key, value: f.value }));
  // Only fields that actually carry a focal-length value participate.
  const fl = rel.filter((f) => /\d{2}mm/.test(f.value));
  const infoboxFavorsWinner = fl.length > 0 && fl.every((f) => f.value.includes(winner));
  const infoboxAssertsStale = fl.some((f) => f.value.includes(superseded) && !f.value.includes(winner));

  const staleSections: string[] = [];
  for (const item of articleStructure(article)) {
    if (item.kind !== "section" || !item.title) continue;
    if (/^references$/i.test(item.title)) continue;
    const anchor = slugifyHeading(item.title);
    const block = extractSection(article, anchor);
    if (block == null) continue;
    const body = block.split("\n").slice(1).join("\n");
    if (assertsCurrent(body, superseded)) staleSections.push(anchor);
  }

  const hashes = extractConvHashes(article);
  const bothCitations = hashes.has(C35_HASH) && hashes.has(C50_HASH);

  return {
    winner,
    superseded,
    leadFavorsWinner,
    leadAssertsStale,
    infoboxRelFields: rel,
    infoboxFavorsWinner,
    infoboxAssertsStale,
    staleSections,
    bothCitations,
    convHashes: [...hashes],
  };
}

interface ScenarioResult {
  article: string;
  favors: string;
  lead: string;
  patched: number;
  reconciled: number;
  /** A resolve fold logged a NO-OP / dropped-citation (the bug we are closing). */
  sawNoop: boolean;
  noopLines: string[];
}

async function runScenario(label: string, at35: number, at50: number): Promise<ScenarioResult> {
  const { store, root } = await buildScenario(at35, at50);
  process.env.MLX_BUN_WIKI = root;
  await runRouteStage(store); // notable=1 (recurs across 6 chunks)

  // Drive synthesize CHRONOLOGICALLY: one pass per conversation, oldest first.
  const convs = (store.db.query("SELECT conv, updated_at FROM conversations ORDER BY updated_at ASC").all() as {
    conv: string;
    updated_at: number;
  }[]);
  let patched = 0;
  let reconciled = 0;
  let sawNoop = false;
  const noopLines: string[] = [];
  for (const c of convs) {
    const which = c.conv === C35 ? "35mm" : "50mm";
    const r = await runSynthesizeStage(store, {
      root,
      convIds: [c.conv],
      commit: false,
      onEvent: (e) => {
        if (e.type === "stage" && (e.stage === "section-route" || e.stage === "patch" || e.stage === "create" || e.stage === "reconcile")) {
          console.log(`    [${which}] ${e.message}`);
        } else if (e.type === "log" && /patch|skip|NO-OP|reconcil|dropped/i.test(e.message)) {
          console.log(`    [${which}]${e.message}`);
          if (/NO-OP|dropped citation/i.test(e.message)) {
            sawNoop = true;
            noopLines.push(e.message.trim());
          }
        }
      },
    });
    patched += r.patched.length;
    reconciled += r.reconciled.length;
    console.log(
      `    [${which}] → created=${r.created.length} patched=${r.patched.length} reconciled=${r.reconciled.length} gated=${r.skippedByGate.length}`,
    );
  }

  let article = "";
  try {
    article = await readFile(join(root, "articles", "Focal_Length_Preference.md"), "utf8");
  } catch {
    article = "(no article created)";
  }
  store.close();
  const j = judge(article);
  console.log(`\n================= ${label} =================`);
  console.log(`processing order (updated_at ASC): ${convs.map((c) => (c.conv === C35 ? "35mm" : "50mm") + "@" + c.updated_at).join("  →  ")}`);
  console.log(`VERDICT favors: ${j.favors}   patched=${patched} reconciled=${reconciled} sawNoop=${sawNoop}`);
  console.log(`LEAD: ${j.lead}`);
  console.log("----- article -----");
  console.log(article);
  await rm(root, { recursive: true, force: true });
  return { article, favors: j.favors, lead: j.lead, patched, reconciled, sawNoop, noopLines };
}

function reportLines(tag: string, r: ScenarioResult, winner: "35mm" | "50mm"): boolean {
  const a = analyze(r.article, winner);
  const noStale = !a.leadAssertsStale && !a.infoboxAssertsStale && a.staleSections.length === 0;
  console.log(`\n----- ${tag} consistency (winner=${winner}) -----`);
  console.log(`  lead favors winner: ${a.leadFavorsWinner}  (asserts superseded as current: ${a.leadAssertsStale})`);
  console.log(`  infobox relationship fields: ${a.infoboxRelFields.map((f) => `${f.key}=${f.value}`).join(", ") || "(none)"}`);
  console.log(`  infobox favors winner: ${a.infoboxFavorsWinner}  (asserts superseded: ${a.infoboxAssertsStale})`);
  console.log(`  stale body sections (assert superseded as current): ${a.staleSections.join(", ") || "(none)"}`);
  console.log(`  conv hashes present: ${a.convHashes.join(", ")}  both([^35],[^50])=${a.bothCitations}`);
  console.log(`  NO internal inconsistency: ${noStale}`);
  console.log(`  ${tag}_LEAD_FAVORS::${a.leadFavorsWinner}`);
  console.log(`  ${tag}_INFOBOX_FAVORS::${a.infoboxFavorsWinner}`);
  console.log(`  ${tag}_BODY_CONSISTENT::${a.staleSections.length === 0}`);
  console.log(`  ${tag}_BOTH_CITATIONS::${a.bothCitations}`);
  console.log(`  ${tag}_NO_STALE::${noStale}`);
  console.log(`  ${tag}_RESOLVE_NOOPED::${r.sawNoop}`);
  return noStale && a.leadFavorsWinner && a.infoboxFavorsWinner && a.bothCitations;
}

// Real, DISTINCT calendar dates — the date-aware resolve keys off footnoteDate
// (conversations.updated_at in epoch-ms). Small ordering integers like 1000/5000ms
// both render as 1970-01-01, collapsing the date signal; these are years apart so
// the model can see which note is later-dated.
const D2023 = 1672531200000; // 2023-01-01
const D2025 = 1735689600000; // 2025-01-01

async function main(): Promise<void> {
  const latest = await runScenario("LATEST-WINS (50mm conversation is NEWER)", D2023, D2025);
  const control = await runScenario("CONTROL (timestamps swapped — 35mm conversation is NEWER)", D2025, D2023);

  // The two runs are byte-identical in CONTENT and DB INSERTION ORDER (buildScenario
  // always inserts the 35mm conversation first, then the 50mm one). The ONLY thing
  // that differs is the two updated_at integers. So a flip between them is keyed off
  // the DATE, not insertion/processing order — that is the date-driven proof.
  const latestOk = reportLines("LATEST", latest, "50mm");
  const controlOk = reportLines("CONTROL", control, "35mm");

  console.log("\n\n================= SUMMARY =================");
  console.log(`latest-wins favors: ${latest.favors} (expect 50mm)  fully-consistent=${latestOk}`);
  console.log(`control     favors: ${control.favors} (expect 35mm)  fully-consistent=${controlOk}`);
  const leadFlips = latest.favors === "50mm" && control.favors === "35mm";
  const la = analyze(latest.article, "50mm");
  const ca = analyze(control.article, "35mm");
  const infoboxFlips = la.infoboxFavorsWinner && ca.infoboxFavorsWinner;
  const bodyConsistent = la.staleSections.length === 0 && ca.staleSections.length === 0;
  const bothCitations = la.bothCitations && ca.bothCitations;
  const noStale =
    !la.leadAssertsStale && !la.infoboxAssertsStale && la.staleSections.length === 0 &&
    !ca.leadAssertsStale && !ca.infoboxAssertsStale && ca.staleSections.length === 0;
  // Date-driven: identical insertion order across both runs, only updated_at swapped,
  // yet lead+infobox+body all flip ⇒ resolution is keyed off the DATE.
  const dateDriven = leadFlips && infoboxFlips;

  console.log(`LEAD_FLIPS::${leadFlips}`);
  console.log(`INFOBOX_FLIPS::${infoboxFlips}`);
  console.log(`BODY_CONSISTENT::${bodyConsistent}`);
  console.log(`BOTH_CITATIONS_PRESENT::${bothCitations}`);
  console.log(`NO_STALE_ASSERTION::${noStale}`);
  console.log(`DATE_DRIVEN::${dateDriven}`);
  console.log(`SELF_HEALING_COMPLETE::${latestOk && controlOk && leadFlips && infoboxFlips && bothCitations && noStale}`);
  console.log(`\nLATEST_LEAD::${latest.lead}`);
  console.log(`CONTROL_LEAD::${control.lead}`);
  console.log(`FLIP_RESULT::${leadFlips}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
