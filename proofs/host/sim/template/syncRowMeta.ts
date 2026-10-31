import { readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

export function syncRowMetadata(streams: string, pre: string): number {
  const old = "(SymE.bin .add (SymE.lit (F64.zero false)) (SymE.bin .sub (SymE.bin .sub (SymE.var 9) (SymE.lit (F64.zero false))) (SymE.lit (F64.fin false 1 (0)))))";
  const escaped = pre.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const oracle = new RegExp(`\\b(${escaped}(?:\\.st[0-9]+)?)\\.O\\b`, "g");
  let changed = 0;
  for (const sub of readdirSync(streams).filter(d => d === pre || d.startsWith(`${pre}.st`))) {
    for (const f of readdirSync(join(streams, sub)).filter(f => f.endsWith(".json"))) {
      const p = join(streams, sub, f), before = readFileSync(p, "utf8");
      const after = before.replaceAll(old, "(SymE.var 10)").replace(oracle, "$1.OR");
      if (after !== before) { writeFileSync(p, after); changed++; }
    }
  }
  return changed;
}

if (import.meta.main) {
  const [streams, pre] = process.argv.slice(2);
  if (!streams || !pre) throw Error("usage: syncRowMeta.ts <stream-dir> <full namespace>");
  console.log(`updated ${syncRowMetadata(streams, pre)} JSON metadata files; binary states unchanged`);
}
