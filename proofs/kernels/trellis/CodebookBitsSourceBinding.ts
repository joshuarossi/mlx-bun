// Trusted exact-byte binding for trellis_unrefined_bits_y's parsed Metal body. These pins also
// preserve the reviewed one-row Qwen decode route; this is not a TS frontend,
// compiler, hardware or all-phases graph-conformance proof.
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

const here = new URL("./", import.meta.url);
const sources = [
  ["kernels/trellis/codebook.ts", "0ba8624952767d077cdecc531fd9f49a159545b95ae4fc4ddd213ed13fa1e276"],
  ["kernels/trellis/gate-up-codebook.ts", "c0aec9b9f951c5fd94270a52f4bf4da43e7fb7d0ecda6ccd65e20571e8931f45"],
  ["kernels/trellis/down-codebook.ts", "5649124f12f6828241d88bb86f9e9f6bf965af2b3b5a298ddd8a2973277eec55"],
  ["layers/trellis-codebook-gate-up.ts", "28d27e84cb669c18a4532723e8dbc66786e386a4390454121640a3e14e5526f5"],
  ["layers/trellis-codebook-down.ts", "48752c429a3ab558131f95c6d361b15b6795c3bb6ee161f8afdca71609437898"],
  ["models/qwen/qwen38-27b-trellis-m1max.ts", "915f129881b5ce85f97b6bca5c98afe06dedc21be514a81137a75e058cac882b"],
] as const;

function extractBody(source: string): string {
  const marker = "static inline float trellis_unrefined_bits_y(int y)";
  const at = source.indexOf(marker);
  if (at < 0 || source.indexOf(marker, at + 1) >= 0) throw Error("Expected unique trellis_unrefined_bits_y signature");
  const start = source.indexOf("{", at + marker.length);
  if (start < 0) throw Error("Missing trellis_unrefined_bits_y body");
  let depth = 0;
  for (let i = start; i < source.length; i++) {
    const c = source[i]!;
    if (!/[A-Za-z0-9_{}();*+=|<>.\/\-\s]/.test(c)) throw Error("Outside audited source-extraction subset");
    if (c === "{") depth++;
    if (c === "}" && --depth === 0) return source.slice(start, i + 1);
  }
  throw Error("Unclosed trellis_unrefined_bits_y body");
}

export async function checkCodebookBitsSourceBinding(options: {
  repositoryRoot?: string;
  leanSource?: string;
  selfTest?: boolean;
} = {}): Promise<void> {
  const repository = options.repositoryRoot
    ? pathToFileURL(resolve(options.repositoryRoot) + "/")
    : new URL("../../../", here);
  let codebook = "";
  for (const [path, hash] of sources) {
    const source = await Bun.file(new URL("packages/inference/src/" + path, repository)).text();
    if (new Bun.CryptoHasher("sha256").update(source).digest("hex") !== hash) throw Error("Pinned source changed: " + path);
    if (path === "kernels/trellis/codebook.ts") codebook = source;
  }
  const lean = await Bun.file(options.leanSource
    ? resolve(options.leanSource)
    : new URL("CodebookBitsSyntax.lean", here)).text();
  const literals = [...lean.matchAll(/^def sourceBody : String := r#"([\s\S]*?)"#/gm)];
  if (literals.length !== 1) throw Error("Expected unique Lean sourceBody");
  const actual = extractBody(codebook);
  const expected = literals[0]![1]!;
  const equal = (body: string) => { if (body !== expected) throw Error("Parsed Lean literal differs from exact trellis_unrefined_bits_y body bytes"); };
  equal(actual);
  if (options.selfTest) {
    const mutations = [
      actual.replace("0x4b000000u", "0x4b000001u"),
      actual.replace("y + 510", "y + 511"),
      actual.replace("8389118.0f", "8389119.0f"),
      actual.replace("147.800537109375f", "147.800537109376f"),
      actual.replace("uint(y", "int(y"),
      actual + " ",
    ];
    for (const mutation of mutations) {
      if (mutation === actual) throw Error("Mutation did not modify selected helper");
      let rejected = false;
      try { equal(mutation); } catch { rejected = true; }
      if (!rejected) throw Error("Source mutation escaped byte binding");
    }
  }
}

if (import.meta.main) {
  await checkCodebookBitsSourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("Exact trellis_unrefined_bits_y body and selected one-row source pins match; extraction/compiler/hardware bindings remain external.");
}
