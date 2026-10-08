// Auxiliary checkpoint files: the non-weight files (tokenizer, chat template,
// generation config, …) a written model directory needs to stay loadable.
// Checkpoint producers (quantization, adapter fusion) copy them through verbatim.

import { existsSync } from "node:fs";
import { join } from "node:path";

/** Aux files copied through verbatim from the source dir when present. */
const AUX_FILES = [
  "tokenizer.json",
  "tokenizer_config.json",
  "tokenizer.model",
  "spiece.model",
  "chat_template.jinja",
  "generation_config.json",
  "special_tokens_map.json",
  "added_tokens.json",
  "vocab.json",
  "merges.txt",
  "README.md",
  "kv_config.json",
];

/** Copy known aux files (and any `*.model`) from src → out when present. */
export async function copyAuxFiles(srcDir: string, outDir: string): Promise<void> {
  const seen = new Set<string>();
  for (const f of AUX_FILES) {
    const src = join(srcDir, f);
    if (existsSync(src)) {
      await Bun.write(join(outDir, f), Bun.file(src));
      seen.add(f);
    }
  }
  // Sweep any additional *.model tokenizer sidecars not in the known list.
  try {
    const { readdirSync } = await import("node:fs");
    for (const f of readdirSync(srcDir)) {
      if (f.endsWith(".model") && !seen.has(f)) {
        await Bun.write(join(outDir, f), Bun.file(join(srcDir, f)));
      }
    }
  } catch {
    // src dir unreadable — aux copy is best-effort.
  }
}
