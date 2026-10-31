import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

type Name = (string | number)[];
type Pair = { file: string; sourceSha256: string; oleanSha256: string; dependencies: string[]; dependencyOleaus: Record<string, string> };
type Root = { name: Name; display: string; module: Name; moduleDisplay: string; levelParams: Name[]; typeExpr: string };
type Inventory = { modules: Name[]; roots: Root[] };
const out = process.argv[2], mode = process.argv[3];
if (!out || !["prepare", "certificates", "verify"].includes(mode ?? "")) throw new Error("usage: generateRootCertificates.ts DEVOUT prepare|certificates|verify");
const dir = import.meta.dir, proofRoot = dir.slice(0, -"host/sim/template/a4pre_d1_body".length);
const base = "host/sim/template/a4pre_d1_body/", main = "host/sim/compose/a4b/SetupD1Body.lean";
const H = (text: string | Uint8Array) => new Bun.CryptoHasher("sha256").update(text).digest("hex");
const HF = (path: string) => H(readFileSync(path));
const json = <T>(path: string) => JSON.parse(readFileSync(path, "utf8")) as T;
const literal = (x: unknown) => JSON.stringify(JSON.stringify(x));
const frozenPath = join(out, "grouped-audit-originals-r1.json");
const inventoryPath = join(out, "grouped-root-inventory-r1.json");
const groupsPath = join(out, "grouped-root-certificates-r1.json");
const instrumentation = /^(?:AuditRoots|RootInventoryProbe|RootCertificateProbe|RootInventory|RootCertificate\d+)\.lean$/;
function verifyOriginals(rows: Pair[]) {
  for (const r of rows) {
    if (HF(join(proofRoot, r.file)) !== r.sourceSha256 ||
        HF(join(out, "source/proofs", r.file)) !== r.sourceSha256 ||
        HF(join(out, r.file.replace(/lean$/, "olean"))) !== r.oleanSha256) throw new Error("original source/artifact drift: " + r.file);
    for (const d of r.dependencies) if (HF(join(out, d.replace(/lean$/, "olean"))) !== r.dependencyOleaus[d])
      throw new Error("original direct dependency drift: " + r.file + " -> " + d);
  }
}
if (mode === "prepare") {
  if (existsSync(frozenPath)) throw new Error("original inventory is frozen");
  const pairs = json<{ modules: Pair[] }>(join(out, "imports.json"));
  const rows = pairs.modules.filter(r => (r.file.startsWith(base) && !instrumentation.test(r.file.slice(base.length))) || r.file === main).sort((a, b) => a.file.localeCompare(b.file));
  if (!rows.some(r => r.file === main) || !rows.some(r => r.file === base + "SizedRun.lean")) throw new Error("complete normal body and final interface required first");
  const selected = new Set(rows.map(r => r.file));
  for (const f of readdirSync(dir).filter(f => f.endsWith(".lean") && !instrumentation.test(f)))
    if (!selected.has(base + f)) throw new Error("unpaired original proof module: " + f);
  verifyOriginals(rows);
  const modules = rows.map(r => r.file.slice(0, -5).split("/"));
  const source = "import host.sim.template.a4pre_d1_body.AuditRoots\n" + modules.map(n => "import " + n.join(".")).join("\n") +
    "\nset_option Elab.async false\nset_option maxHeartbeats 0\n" + `d1_root_inventory ${literal(modules)}\n`;
  writeFileSync(join(dir, "RootInventory.lean"), source);
  writeFileSync(frozenPath, JSON.stringify({ at: new Date().toISOString(), status: "frozen-normal-original-module-set",
    originalPairs: rows, modules, importedDeclarationInventorySource: base + "RootInventory.lean", inventorySourceSha256: H(source),
    instrumentationExcluded: pairs.modules.filter(r => r.file.startsWith(base) && instrumentation.test(r.file.slice(base.length))),
    finalOriginalSourcePerModuleAudits: "remain required in the unchanged final frozen full checker" }, null, 2));
  console.log({ modules: rows.length, next: "normal build and exact auditedText of RootInventory.lean, tag RootInventory-audit-r1" });
} else if (mode === "certificates") {
  if (existsSync(groupsPath)) throw new Error("certificate plan is frozen");
  const frozen = json<{ originalPairs: Pair[]; modules: Name[] }>(frozenPath);
  verifyOriginals(frozen.originalPairs);
  const log = readFileSync(join(out, "RootInventory-audit-r1.log"), "utf8");
  if (!log.includes("Axiom audit passed:") || /sorryAx|Forbidden axiom|error:/.test(log)) throw new Error("inventory audit not accepted");
  const matches = [...log.matchAll(/D1_BODY_ROOT_INVENTORY (\{[^\n]*\})/g)];
  if (matches.length !== 1) throw new Error("inventory report count");
  const inventory = JSON.parse(matches[0]![1]!) as Inventory;
  if (JSON.stringify(inventory.modules) !== JSON.stringify(frozen.modules)) throw new Error("inventory module mismatch");
  const moduleKeys = new Set(frozen.modules.map(n => JSON.stringify(n))), seen = new Set<string>();
  for (const r of inventory.roots) {
    const key = JSON.stringify(r.name);
    if (seen.has(key) || !moduleKeys.has(JSON.stringify(r.module)) || !r.typeExpr || !Array.isArray(r.levelParams))
      throw new Error("duplicate/extraneous/changed root inventory");
    seen.add(key);
  }
  writeFileSync(inventoryPath, JSON.stringify({ at: new Date().toISOString(), logSha256: HF(join(out, "RootInventory-audit-r1.log")), ...inventory }, null, 2));
  const groups: { file: string; modules: Name[]; roots: Root[]; sourceSha256: string }[] = [];
  for (let i = 0; i < frozen.modules.length; i += 24) {
    const modules = frozen.modules.slice(i, i + 24), selected = new Set(modules.map(n => JSON.stringify(n)));
    const roots = inventory.roots.filter(r => selected.has(JSON.stringify(r.module))).sort((a, b) => JSON.stringify(a.name).localeCompare(JSON.stringify(b.name)));
    const n = groups.length, name = "RootCertificate" + n;
    const source = "import host.sim.template.a4pre_d1_body.AuditRoots\n" + modules.map(n => "import " + n.join(".")).join("\n") +
      `\nset_option Elab.async false\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl.D1BodyRootCertificate${n}\n` +
      `d1_root_certificate ${literal(modules)} roots ${literal(roots.map(r => r.name))}\n` +
      `end Host.Load.Run.Tpl.D1BodyRootCertificate${n}\n`;
    if (existsSync(join(dir, name + ".lean"))) throw new Error("existing certificate source");
    writeFileSync(join(dir, name + ".lean"), source);
    groups.push({ file: base + name + ".lean", modules, roots, sourceSha256: H(source) });
  }
  const roots = groups.flatMap(g => g.roots.map(r => JSON.stringify(r.name)));
  if (roots.length !== seen.size || new Set(roots).size !== seen.size || roots.some(r => !seen.has(r))) throw new Error("certificate-to-root bijection failed");
  writeFileSync(groupsPath, JSON.stringify({ at: new Date().toISOString(), status: "certificate-source-plan-only", groups,
    completeModules: frozen.modules.length, completeRoots: roots.length, inventorySha256: HF(inventoryPath),
    originalPairsSha256: HF(frozenPath), finalCheckerReplacement: false }, null, 2));
  console.log({ groups: groups.length, modules: frozen.modules.length, roots: roots.length });
} else {
  const frozen = json<{ originalPairs: Pair[]; modules: Name[] }>(frozenPath);
  verifyOriginals(frozen.originalPairs);
  const plan = json<{ groups: { file: string; modules: Name[]; roots: Root[]; sourceSha256: string }[] }>(groupsPath);
  const inventory = json<Inventory>(inventoryPath), seen = new Set<string>(), modules = new Set<string>();
  const reports: unknown[] = [];
  for (const [i, g] of plan.groups.entries()) {
    if (HF(join(proofRoot, g.file)) !== g.sourceSha256) throw new Error("certificate source drift");
    const tag = "RootCertificate" + i + "-audit-r1", path = join(out, tag + ".log"), log = readFileSync(path, "utf8");
    const payload = join(out, "audit-payloads", tag + ".lean");
    const { auditedText, accepted } = await import("../../../../checker.ts");
    if (readFileSync(payload, "utf8") !== auditedText(readFileSync(join(proofRoot, g.file), "utf8")) + "\n\n")
      throw new Error("certificate was not exact current auditedText payload");
    const history = readFileSync(join(out, "builds.jsonl"), "utf8").trim().split("\n").map(s => JSON.parse(s) as { tag: string; code: number });
    const builds = history.filter(r => r.tag === tag);
    if (builds.length !== 1 || !accepted(log, builds[0]!.code)) throw new Error("certificate audit failed");
    const rss = Number(log.match(/(\d+)\s+maximum resident set size/)?.[1] ?? 0);
    if (!rss || rss > 8000 * 1024 * 1024) throw new Error("certificate exceeds normal memory cap");
    const printed = (log.match(/depends on axioms:|does not depend on any axioms/g) ?? []).length;
    const checked = Number(log.match(/Axiom audit passed: (\d+)/)?.[1] ?? -1);
    const ms = [...log.matchAll(/D1_BODY_ROOT_CERTIFICATE (\{[^\n]*\})/g)];
    if (ms.length !== 1 || printed !== g.roots.length || checked !== g.roots.length) throw new Error("certificate root/print count mismatch");
    const report = JSON.parse(ms[0]![1]!) as { modules: Name[]; aliases: { original: Name; module: Name; alias: Name; typeExpr: string; levelParams: Name[] }[] };
    if (JSON.stringify(report.modules) !== JSON.stringify(g.modules) || report.aliases.length !== g.roots.length) throw new Error("certificate module set mismatch");
    for (const [j, r] of g.roots.entries()) {
      const a = report.aliases[j]!, key = JSON.stringify(r.name);
      if (seen.has(key) || JSON.stringify(a.original) !== key || JSON.stringify(a.module) !== JSON.stringify(r.module) ||
          a.typeExpr !== r.typeExpr || JSON.stringify(a.levelParams) !== JSON.stringify(r.levelParams) || a.alias.at(-1) !== "root" + j)
        throw new Error("omitted/changed/extraneous certificate root or complete elaborated type");
      seen.add(key);
    }
    for (const m of g.modules) { const key = JSON.stringify(m); if (modules.has(key)) throw new Error("duplicate module coverage"); modules.add(key); }
    reports.push({ file: g.file, roots: g.roots.length, printed, checked, rss, payloadSha256: HF(payload), logSha256: HF(path), sourceSha256: g.sourceSha256 });
  }
  if (seen.size !== inventory.roots.length || inventory.roots.some(r => !seen.has(JSON.stringify(r.name))) ||
      modules.size !== frozen.modules.length || frozen.modules.some(m => !modules.has(JSON.stringify(m)))) throw new Error("incomplete whole certificate coverage");
  const receipt = join(out, "grouped-root-acceptance-r1.json");
  if (existsSync(receipt)) throw new Error("root receipt is frozen");
  writeFileSync(receipt, JSON.stringify({ at: new Date().toISOString(), status: "bounded-development-grouped-root-audits", modules: modules.size,
    roots: seen.size, everyOriginalRootPrinted: true, completeElaboratedTypesUnchanged: true, originalPairsUnchanged: true,
    originalPairsSha256: HF(frozenPath), inventorySha256: HF(inventoryPath), certificatePlanSha256: HF(groupsPath), reports,
    finalOriginalSourcePerModuleCheckerAudits: "deferred to unchanged frozen full checker; grouped certificates are not replacement modules",
    fullCheckerAcceptance: false }, null, 2));
  console.log({ roots: seen.size, modules: modules.size, receipt, sha256: HF(receipt) });
}
