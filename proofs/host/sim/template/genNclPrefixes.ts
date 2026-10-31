// Split generated NClean composition at each call; SiteR must not depend on later sites.
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const [dir, name] = process.argv.slice(2);
if (!dir || !name) throw Error("usage: genNclPrefixes.ts <chain-dir> <Name>");
const root = join(import.meta.dir, dir), mod = `host.sim.template.${dir.replaceAll("/", ".")}`;
const streams = process.env.HOST_STREAM_DIR ?? join(import.meta.dir, "../../../.host-stream");
const meta = JSON.parse(readFileSync(join(streams, `Host.Load.Run.Tpl.${name}`, "seg.json"), "utf8"));
const file = join(root, "NClAll.lean"), source = readFileSync(file, "utf8");
if (source.includes(`${mod}.NClCall`)) throw Error("NClAll already split; regenerate it before splitting again");
const imports = [...source.matchAll(/^import (\S+)$/gm)].map(m => m[1]!);
const facts = [...source.matchAll(/^theorem (\S+)\.ncl(\d+) : .*$/gm)].map(m => ({ at: +m[2]!, line: m[0] }));
const end = source.match(/^theorem \S+\.nclEnd : .*$/m)?.[0];
if (!end) throw Error("NClAll has no generated endpoint theorem");
const header = (imps: string[]) => imps.map(m => `import ${m}\n`).join("") +
  "set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim Host.Ts.Sim.Template\n\n";
let previous = "", fromImport = 0, after = -1;
for (const site of meta.bridges.filter((b: {kind: string}) => b.kind === "stage" && b.compaction)) {
  const k = site.site, stop = imports.indexOf(`${mod}.SiteCl${k}`);
  if (stop < fromImport) throw Error(`missing ordered SiteCl${k} in NClAll`);
  const own = facts.filter(f => after < f.at && f.at <= site.ia);
  const callMod = `${mod}.NClCall${k}`;
  writeFileSync(join(root, `NClCall${k}.lean`), header([
    ...(previous ? [previous] : []), ...imports.slice(fromImport, stop),
  ]) + own.map(f => f.line + "\n").join("") + "\nend Host.Load.Run.Tpl\n");
  const siteFile = join(root, `SiteR${k}.lean`);
  if (existsSync(siteFile)) writeFileSync(siteFile, readFileSync(siteFile, "utf8")
    .replace(`import ${mod}.NClAll\n`, `import ${callMod}\n`));
  previous = callMod;
  fromImport = stop;
  after = site.ia;
}
writeFileSync(file, header([...(previous ? [previous] : []), ...imports.slice(fromImport)]) +
  facts.filter(f => after < f.at).map(f => f.line + "\n").join("") + end + "\n\nend Host.Load.Run.Tpl\n");
console.log(`${name}: NClean call prefixes split; endpoint theorem names retained`);
