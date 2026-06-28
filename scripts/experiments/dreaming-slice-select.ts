// One-off: select ~150 representative conversations spanning domains for the
// Dreaming end-to-end slice (our-chunker E2E). Writes the chosen conv ids +
// their domain bucket to scratchpad JSON for the runner. Read-only on the DB.

import { Database } from "bun:sqlite";

const DB = `${process.env.HOME}/.cache/mlx-bun/memory.sqlite`;
const OUT = process.argv[2] ?? "/tmp/dreaming-slice.json";

const db = new Database(DB, { readonly: true });

interface Conv {
  conv: string;
  source: string;
  title: string;
  msgs: number;
  chars: number;
  hasAssistant: number;
  blob: string; // lowercased title + message text (for keyword classification)
}

// Pull every conv with a size + a lowercased searchable blob (title + text).
const rows = db
  .query(
    `SELECT c.conv AS conv, c.source AS source, COALESCE(c.title,'') AS title,
            COUNT(m.position) AS msgs,
            COALESCE(SUM(LENGTH(m.text)),0) AS chars,
            MAX(CASE WHEN m.role='assistant' AND m.text IS NOT NULL AND TRIM(m.text)<>'' THEN 1 ELSE 0 END) AS hasAssistant,
            LOWER(COALESCE(c.title,'') || ' ' || COALESCE(GROUP_CONCAT(m.text,' '),'')) AS blob
       FROM conversations c
       LEFT JOIN messages m ON m.conv=c.conv
      GROUP BY c.conv`,
  )
  .all() as Conv[];

const has = (blob: string, kws: string[]): boolean => kws.some((k) => blob.includes(k.toLowerCase()));

// CURATED pattern-shaped convs (the reviewer's #1 concern): each conv's SUBJECT
// is a framework / stance / thesis / epistemic-method / mental-model / analogy —
// NOT a gear or product comparison. Hand-picked from a title+text scan, all
// chunk-eligible size (<=60k chars). 30 ids => the >=25 floor with margin.
const PATTERN_CONVS = [
  "6dc26f1a-a15c-45ec-b026-a345f36eede9", // Streamlined Software Development Framework
  "22c12dbb", // Adversarial PRD to plan loop (resolved by prefix below)
  "18e1ea4c-106a-4212-8531-28342d0cc3e7", // Toyota's Kaizen Culture (TPS/lean)
  "ee182ec6-249e-40fb-a109-88ccd8245160", // Free Energy Principle Overview
  "d2efeb61-aa2b-45aa-9714-4f7f1596ad16", // Intelligence as adaptation to the unknown
  "ebd37ef0", // Raising the floor raises the ceiling (principle/stance)
  "623e870d-9e5c-4aee-9c70-1f052396f4b3", // Strategic report prioritization framework
  "c3c61271-f77e-4557-ab9e-816f272f6d03", // LLM as persistent participant (stance)
  "f317a56f-e1ac-4562-993d-e6b22709167d", // Ornith's self-scaffolding LLM problem
  "5c634fa2-f654-43f5-b133-be303c586308", // Domain-specific languages as structured encoding
  "73dfacab-5fef-4cab-a496-adce45f0773a", // Classic simulation hypothesis arguments
  "c9f3e2d8-87a5-4fa4-9c3b-50c11bc12474", // Determinism in identical model instances
  "dd52739f-0b86-4d81-9aeb-9f246d49b608", // Neural networks as a game of telephone (analogy)
  "4d6b452a-18fa-485d-b97f-e6fadaca78db", // Statistical overfitting and meaningless data slicing
  "e1758166", // Conscious Lag in Decisions (Libet)
  "e578e526-9874-44ed-be28-9dc85afbbd38", // Transformers and gear ratios analogy
  "616bcc07-997f-493d-aebe-ede775e79529", // LessWrong Core Ideas (rationality/epistemics)
  "df61d9d5-b246-4320-a817-32d735bd23ec", // Bayesian Reasoning Explanation (epistemics)
  "47bf0430-125f-45e4-9702-7d1c487f45af", // Defining Intelligence Types (concept)
  "66ed8adf-34ec-8013-8c2c-f2a10acf7528", // Understanding Ideas and Math (concept)
  "b32725a4-9ad9-49fa-b8fe-0a871fa6e437", // AI compute as a commoditized energy market (thesis)
  "0029d4fb-f645-4ab7-843c-8b19c0d34aca", // Reminder vs. todo distinction (conceptual)
  "9215e78d-4249-4d12-b6a7-f9461a721d3f", // Distal vs Proximal Explained (concept)
  "64d79436-c1f8-454a-acec-a99f6f847a83", // Churches as more than event spaces (stance/thesis)
  "e484342a-431c-4f32-a74e-f5de2613b18e", // Understanding Y Combinator fundamentals (recursion concept)
  "8b05cf5a-8dd8-4699-8b97-624a354332bd", // Applying Roam concepts to Lucien (knowledge-mgmt framework)
  "f326906c-e688-408f-830d-0b389365d4eb", // Optimization and scope tradeoff (principle)
  "c1f536c6-5f1f-423a-aef8-16d136e37003", // Prompt optimization strategy (methodology)
  "e653e6d2-1d66-4492-bd31-f7312a47050f", // Price Concealment Strategy (strategy)
  "020e86e3-b186-47cd-ab05-99cb4afc685f", // White label software strategy evaluation (strategy)
];

const GEAR = [
  "anamorphic", "l-mount", "lumix", "sirui", "sankor", "mirrorless", "focal length",
  "aperture", "telephoto", "full-frame", "avedon", "jupiter-9", "flange distance",
  "anamorphot", "vintage lens", "photography", "camera body", "lens choice",
];
const ALPHAPOINT = [
  "alphapoint", "archie", "jira", "wor-", "convex", "sprint", "prd ", "saas",
  "ticket", "jql", "workflow status", "lucien",
];
const AITOOL = [
  "mlx", "mlx-bun", "mlx-lm", "quantization", "kv cache", "optiq", "gemma", "lora",
  "orpo", "adapter", "metal kernel", "local inference", "local ai", "apple silicon",
  "memory bandwidth", "embedding", "fine-tune", "fine tune", "tokeniz", "safetensors",
];

type Bucket = "pattern" | "gear" | "alphapoint" | "aitool";

interface Tagged extends Conv {
  bucket: Bucket | null;
}

// Resolve the curated pattern ids (some are 8-hex prefixes) to full conv ids.
const patternIdSet = new Set<string>();
for (const r of rows) {
  for (const p of PATTERN_CONVS) {
    if (r.conv === p || r.conv.startsWith(p)) patternIdSet.add(r.conv);
  }
}

const tagged: Tagged[] = rows
  .filter((r) => r.hasAssistant === 1 && r.chars >= 400 && r.chars <= 60000 && r.msgs >= 2)
  .map((r) => {
    // Pattern is assigned by the CURATED id list (subject-verified). The other
    // buckets are keyword-classified, priority alphapoint > gear > aitool.
    let bucket: Bucket | null = null;
    if (patternIdSet.has(r.conv)) bucket = "pattern";
    else if (has(r.blob, ALPHAPOINT)) bucket = "alphapoint";
    else if (has(r.blob, GEAR)) bucket = "gear";
    else if (has(r.blob, AITOOL)) bucket = "aitool";
    return { ...r, bucket, blob: "" }; // drop blob from output
  });

// Target mix (150). Pattern = the full curated set (>=25 floor with margin).
const TARGET: Record<Bucket, number> = { pattern: 30, gear: 40, alphapoint: 40, aitool: 40 };

// Pick a size-spread within a bucket: sort by chars, then stride-sample so we get
// short + medium + long (representative, not all tiny).
function pickSpread(cands: Tagged[], n: number): Tagged[] {
  const sorted = cands.slice().sort((a, b) => a.chars - b.chars);
  if (sorted.length <= n) return sorted;
  const out: Tagged[] = [];
  for (let i = 0; i < n; i++) {
    const idx = Math.floor((i * (sorted.length - 1)) / (n - 1));
    out.push(sorted[idx]!);
  }
  // stride-sample can collide at the ends; dedupe + backfill from the middle.
  const seen = new Set(out.map((c) => c.conv));
  if (seen.size < n) {
    for (const c of sorted) {
      if (seen.has(c.conv)) continue;
      out.push(c);
      seen.add(c.conv);
      if (seen.size >= n) break;
    }
  }
  return [...new Map(out.map((c) => [c.conv, c])).values()].slice(0, n);
}

const chosen: Tagged[] = [];
const usedConv = new Set<string>();
for (const b of ["pattern", "gear", "alphapoint", "aitool"] as Bucket[]) {
  const cands = tagged.filter((t) => t.bucket === b && !usedConv.has(t.conv));
  const pick = pickSpread(cands, TARGET[b]);
  for (const c of pick) {
    chosen.push(c);
    usedConv.add(c.conv);
  }
}

const byBucket: Record<string, number> = {};
for (const c of chosen) byBucket[c.bucket!] = (byBucket[c.bucket!] ?? 0) + 1;

const summary = {
  total: chosen.length,
  byBucket,
  charStats: {
    min: Math.min(...chosen.map((c) => c.chars)),
    max: Math.max(...chosen.map((c) => c.chars)),
    median: chosen.map((c) => c.chars).sort((a, b) => a - b)[Math.floor(chosen.length / 2)],
  },
  convIds: chosen.map((c) => c.conv),
  detail: chosen.map((c) => ({ conv: c.conv, bucket: c.bucket, source: c.source, msgs: c.msgs, chars: c.chars, title: c.title })),
};

await Bun.write(OUT, JSON.stringify(summary, null, 2));
console.log(`selected ${chosen.length} convs → ${OUT}`);
console.log("byBucket:", byBucket);
console.log("charStats:", summary.charStats);
db.close();
