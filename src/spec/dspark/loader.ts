// Central DSpark checkpoint loader — the variant dispatch the modules never
// had (scripts imported their class directly; the serve path needs one entry
// point). Reads dspark.json and returns the matching drafter:
//   variant "dspark"           — the faithful KV-injection module (canonical)
//   variant "dflash" (legacy)  — same module, pre-rename stamp
//   variant absent             — a v1 single-vector checkpoint (module.ts,
//                                superseded research baseline) — refused for
//                                serving with a pointer at the v2 trainer.

import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { DflashDrafter } from "./module-dflash";

export function loadDsparkDrafter(dir: string): DflashDrafter {
  const metaPath = join(dir, "dspark.json");
  if (!existsSync(metaPath)) throw new Error(`no dspark.json in ${dir} — not a DSpark checkpoint`);
  const meta = JSON.parse(readFileSync(metaPath, "utf8")) as { variant?: string };
  if (meta.variant === "dspark" || meta.variant === "dflash") return DflashDrafter.load(dir);
  throw new Error(
    `${dir} is a v1 single-vector DSpark checkpoint (variant=${meta.variant ?? "none"}) — ` +
      `superseded, not serveable; retrain with scripts/dspark.ts train`,
  );
}
