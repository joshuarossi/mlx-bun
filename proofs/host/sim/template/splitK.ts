// Split a generated chunk module into independent kernel checks, retaining all theorem names.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const [dir, file] = process.argv.slice(2);
if (!dir || !file || !/^K[0-9]+$/.test(file)) throw Error("usage: splitK.ts <chain-dir> K<index>");
const root = join(import.meta.dir, dir), path = join(root, `${file}.lean`);
const text = readFileSync(path, "utf8"), first = text.search(/^(?:boot_rfl|sim_chunk|kernel_rfl) /m);
if (first < 0) throw Error("module has no generated checks to split");
const end = text.lastIndexOf("end Host.Load.Run.Tpl"), head = text.slice(0, first);
const checks = text.slice(first, end).trim().split(/\n(?=(?:boot_rfl|sim_chunk|kernel_rfl) )/);
for (const [i, check] of checks.entries()) writeFileSync(join(root, `${file}_${i}.lean`),
  head + check + "\nend Host.Load.Run.Tpl\n");
const mod = `host.sim.template.${dir.replaceAll("/", ".")}`;
writeFileSync(path, checks.map((_, i) => `import ${mod}.${file}_${i}\n`).join(""));
console.log(`${dir}/${file}: split ${checks.length} generated checks`);
