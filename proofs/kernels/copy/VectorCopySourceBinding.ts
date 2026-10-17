// This host-side check binds the Lean raw literal to a pinned source body.
// It is a trusted extraction/byte-comparison check, not a verified frontend,
// compiler-correctness proof, or evidence of GPU execution.
import { resolve } from "node:path";

const revision = "1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const sourceHash = "a9fad1b262ffc25f4ccda4e09d0c76821cd580f12871acd2a0daa98151e1587c";
const here = new URL("./", import.meta.url);
function option(name: string): string | undefined {
  const index = process.argv.indexOf(name);
  if (index < 0) return undefined;
  const value = process.argv[index + 1];
  if (!value || value.startsWith("--")) throw new Error(`Missing ${name} value`);
  return value;
}
export interface SourceBindingOptions {
  proofsRoot?: string;
  leanSource?: string;
  selfTest?: boolean;
}

export async function checkVectorCopySourceBinding(options: SourceBindingOptions = {}): Promise<void> {
  const root = options.proofsRoot;
  const proofs = root ? new URL(`file://${resolve(root)}/`) : new URL("../../", here);
  const leanPath = options.leanSource;
  const lean = await Bun.file(leanPath ? resolve(leanPath) : new URL("VectorCopySyntax.lean", here)).text();
  const nativePath = new URL(`.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/copy.h`, proofs);
  const native = await Bun.file(nativePath).text();
  if (new Bun.CryptoHasher("sha256").update(native).digest("hex") !== sourceHash) {
    throw new Error("Pinned copy.h content changed; review the source and proof.");
  }

  function extractBody(source: string): string {
    const marker = "[[kernel]] void copy_v(";
    const functionStart = source.indexOf(marker);
    if (functionStart < 0 || source.indexOf(marker, functionStart + 1) >= 0) {
      throw new Error("Expected exactly one copy_v kernel declaration");
    }
    const start = source.indexOf("{", functionStart);
    if (start < 0) throw new Error("Missing copy_v body");
    let depth = 0;
    for (let at = start; at < source.length; at++) {
      const c = source[at]!;
      // The audited subset contains no comments, strings, or character literals.
      if (!/[A-Za-z0-9_{}\[\]();*+=<>&\s]/.test(c)) {
        throw new Error("copy_v body left the audited extraction subset");
      }
      if (c === "{") depth++;
      if (c === "}" && --depth === 0) return source.slice(start, at + 1);
    }
    throw new Error("Unclosed copy_v body");
  }
  function checkBinding(source: string, literal: string): void {
    if (extractBody(source) !== literal) throw new Error("Lean sourceBody differs from pinned copy_v body bytes");
  }
  const literals = [...lean.matchAll(/^def sourceBody : String := r#"([\s\S]*?)"#/gm)];
  if (literals.length !== 1) throw new Error("Expected exactly one Lean sourceBody raw literal");
  const literal = literals[0]![1]!;
  checkBinding(native, literal);
  if (options.selfTest) {
    for (const changed of [native.replaceAll("index *= N;", "index += N;"), native.replace("src[index + i]", "src[index]")]) {
      let rejected = false;
      try { checkBinding(changed, literal); } catch { rejected = true; }
      if (!rejected) throw new Error("Source mutation escaped exact body binding");
    }
    let rejected = false;
    try { checkBinding(native, literal + " "); } catch { rejected = true; }
    if (!rejected) throw new Error("Whitespace mutation escaped exact body binding");
  }
}

// CLI: bun VectorCopySourceBinding.ts [--proofs-root DIR] [--lean-source FILE] [--self-test]
if (import.meta.main) {
  await checkVectorCopySourceBinding({
    proofsRoot: option("--proofs-root"),
    leanSource: option("--lean-source"),
    selfTest: process.argv.includes("--self-test"),
  });
  console.log("Exact pinned copy_v body bytes match Lean sourceBody; no normalization. Host extraction remains trusted.");

}
