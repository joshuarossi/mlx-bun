// Merge a generated chain's small modules into bundles: most of a small module's cost is its import, not its checks.
// usage: bun proofs/host/sim/template/genMerge.ts <case-dir> [--out <case-dir'>] [--only <regex>] [--budget <s>] [--costs <builder.log>...]
//   <case-dir>: a chain's directory under host/sim/template (genChain.ts's, with its stage instances st<k>/ and typed checks).
//   --out: write the bundles to <case-dir'> (default: <case-dir>/m); the members stay. Constant names do not change.
//   --only: bundle only the members whose path matches (a validation of one site; everything else stays imported as it is).
//   --roots: keep only the import closure of the members whose path matches (the consumers' modules; the rest is not written).
//   --budget: a bundle's check budget in slot-seconds (default 300), --costs: earlier builders' "slot <s>s <file>" lines
//   (without them a kind's default below; the import, IMPORT seconds, is not part of a member's cost).
// A partition of a topological order into intervals has an acyclic quotient, so the bundles are intervals of the import
// order, the order keeping a site's members together. States and Rebind (native commands) are never members; a member's
// body is scoped by a section, so options and opens stay its own.
import { readFileSync, writeFileSync, mkdirSync, readdirSync, statSync } from "node:fs";
import { join, relative, dirname } from "node:path";

const argv = process.argv.slice(2);
const takeN = (f: string): string[] => {
  const out: string[] = [];
  for (let i = argv.indexOf(f); i >= 0; i = argv.indexOf(f)) { out.push(argv[i + 1]!); argv.splice(i, 2); }
  return out;
};
const outArg = takeN("--out")[0], onlyArg = takeN("--only")[0], rootArgs = takeN("--roots"), budget = Number(takeN("--budget")[0] ?? 300);
const costFiles = takeN("--costs");
const dir = argv[0];
if (!dir) throw new Error("usage: genMerge.ts <case-dir> [--out <dir>] [--only <regex>] [--budget <s>] [--costs <log>...]");
const here = import.meta.dir, root = join(here, dir), outDir = outArg ?? `${dir}/m`;
const prefix = `host.sim.template.${dir.replaceAll("/", ".")}.`, outPrefix = `host.sim.template.${outDir.replaceAll("/", ".")}.`;
const IMPORT = 6;
// never bundled: native commands, whose order and side effects the stream relies on
const fixed = /^(States|Rebind|Origin)$/;
type Mod = { name: string; imports: string[]; body: string; rank: number; site: number; cost: number };
const walk = (d: string): string[] => readdirSync(d).flatMap(f => {
  const p = join(d, f);
  return statSync(p).isDirectory() ? (f === "m" ? [] : walk(p)) : f.endsWith(".lean") ? [p] : [];
});
const only = onlyArg ? new RegExp(onlyArg) : undefined;
// a kind's default check cost without measurements (seconds past the import)
const defaults: [RegExp, number][] = [[/^(st\d+\/)?H\d+$/, 2], [/K\d+$|MicroK/, 12], [/TypedK/, 10], [/SiteZ|SiteS/, 4], [/./, 1]];
const measured = new Map<string, number>();
for (const f of costFiles) for (const l of readFileSync(f, "utf8").split("\n")) {
  const x = /^slot ([\d.]+)s \S*?\/template\/(\S+)\.lean/.exec(l);
  if (x && x[2]!.startsWith(`${dir}/`)) measured.set(x[2]!.slice(dir.length + 1), Math.max(0.2, Number(x[1]) - IMPORT));
}
const costOf = (n: string) => measured.get(n) ?? defaults.find(([r]) => r.test(n))![1];
// the order: the chain's states and acceptance, its glue checks, the sites one by one, the assemblies
const rankOf = (n: string): [number, number] => {
  const site = /^st(\d+)\//.exec(n) ?? /^Site[A-Za-z]*(\d+)/.exec(n);
  if (/^H\d+$/.test(n)) return [0, Number(n.slice(1))];
  if (site && !/^SiteR/.test(n)) return [2, Number(site[1])];
  if (/^SiteR/.test(n)) return [4, 0];
  if (/^(K|K_|MicroK|TypedK|TypedSteps|TypedSeg)/.test(n)) return [1, 0];
  return [3, 0];
};
const mods = new Map<string, Mod>();
for (const p of walk(root)) {
  const name = relative(root, p).replace(/\.lean$/, "");
  if (fixed.test(name) || (only && !only.test(name))) continue;
  const text = readFileSync(p, "utf8");
  const imports = [...text.matchAll(/^import\s+(\S+)\s*$/gm)].map(m => m[1]!);
  const [rank, site] = rankOf(name);
  mods.set(name, { name, imports, body: text.replace(/^import\s+\S+\s*\n/gm, ""), rank, site, cost: costOf(name) });
}
// a member outside the consumers' closure is not written
if (rootArgs.length) {
  const roots = rootArgs.map(r => new RegExp(r)), keep = new Set<string>();
  const inDir = (i: string) => i.startsWith(prefix) ? i.slice(prefix.length).replaceAll(".", "/") : undefined;
  const go = (n: string) => {
    const m = mods.get(n);
    if (!m || keep.has(n)) return;
    keep.add(n);
    for (const i of m.imports) { const g = inDir(i); if (g) go(g); }
  };
  for (const n of mods.keys()) if (roots.some(r => r.test(n))) go(n);
  for (const n of [...mods.keys()]) if (!keep.has(n)) mods.delete(n);
}
const nameOf = (imp: string) => imp.startsWith(prefix) ? imp.slice(prefix.length).replaceAll(".", "/") : undefined;
const depsOf = (m: Mod) => m.imports.flatMap(i => { const n = nameOf(i); return n && mods.has(n) ? [n] : []; });
// Kahn's order, ready members by (rank, site, name order): intervals of it are the bundles
const indeg = new Map<string, number>(), users = new Map<string, string[]>();
for (const m of mods.values()) {
  indeg.set(m.name, depsOf(m).length);
  for (const d of depsOf(m)) (users.get(d) ?? users.set(d, []).get(d)!).push(m.name);
}
const natural = (a: string, b: string) => a.localeCompare(b, "en", { numeric: true });
const key = (n: string) => { const m = mods.get(n)!; return [m.rank, m.site, n] as const; };
const before = (a: string, b: string) => {
  const [ra, sa, na] = key(a), [rb, sb, nb] = key(b);
  return ra - rb || sa - sb || natural(na, nb);
};
const ready = [...mods.keys()].filter(n => indeg.get(n) === 0).sort(before);
const order: string[] = [];
while (ready.length) {
  const n = ready.shift()!;
  order.push(n);
  for (const u of users.get(n) ?? []) {
    indeg.set(u, indeg.get(u)! - 1);
    if (indeg.get(u) === 0) {
      let i = ready.findIndex(x => before(u, x) < 0);
      if (i < 0) i = ready.length;
      ready.splice(i, 0, u);
    }
  }
}
if (order.length !== mods.size) throw new Error(`import cycle among ${dir}'s members`);
// cut the order by budget and at a change of rank
const bundles: string[][] = [];
let cur: string[] = [], curCost = 0, curRank = -1;
for (const n of order) {
  const m = mods.get(n)!;
  if (cur.length && (curCost + m.cost > budget || m.rank !== curRank)) { bundles.push(cur); cur = []; curCost = 0; }
  cur.push(n); curCost += m.cost; curRank = m.rank;
}
if (cur.length) bundles.push(cur);
const bundleOf = new Map<string, number>();
bundles.forEach((b, j) => b.forEach(n => bundleOf.set(n, j)));
mkdirSync(join(here, outDir), { recursive: true });
const pad = (j: number) => String(j).padStart(String(bundles.length).length, "0");
const bundleMod = (j: number) => `${outPrefix}B${pad(j)}`;
for (const [j, b] of bundles.entries()) {
  const imps = new Set<string>();
  for (const n of b) for (const i of mods.get(n)!.imports) {
    const g = nameOf(i);
    if (g && bundleOf.has(g)) { if (bundleOf.get(g) !== j) imps.add(bundleMod(bundleOf.get(g)!)); } else imps.add(i);
  }
  writeFileSync(join(here, outDir, `B${pad(j)}.lean`), [
    ...[...imps].map(i => `import ${i}\n`),
    ...b.map(n => `\nsection -- ${n}\n${mods.get(n)!.body.trimEnd()}\nend\n`)].join(""));
}
// where each member went, for the importers outside the chain
writeFileSync(join(here, outDir, "members.json"), JSON.stringify(Object.fromEntries(order.map(n => [n, `B${pad(bundleOf.get(n)!)}`])), null, 0) + "\n");
const total = order.reduce((a, n) => a + mods.get(n)!.cost, 0);
console.log(`${dir}: ${order.length} members into ${bundles.length} bundles under ${outDir}: ${(total / 3600).toFixed(2)} slot-h of checks, ` +
  `imports ${(order.length * IMPORT / 3600).toFixed(2)} -> ${(bundles.length * IMPORT / 3600).toFixed(2)} slot-h at ${IMPORT} s`);
