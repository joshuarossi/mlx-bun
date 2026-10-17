// Trusted host byte binding for the two literals parsed and proved in Lean.
// This is not a verified frontend or a compiler/native execution proof.
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

const revision = "1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const here = new URL("./", import.meta.url);
const bindings = [
  {
    file: "copy.h",
    hash: "a9fad1b262ffc25f4ccda4e09d0c76821cd580f12871acd2a0daa98151e1587c",
    marker: "[[kernel]] void copy_gg_nd2(",
    literal: "sourceBody",
    change: (body: string) => body.replace("dst[dst_idx]", "dst[src_idx]"),
  },
  {
    file: "utils.h",
    hash: "5e1568e9edde9d05dbf86f68fa0d6c6240f2c32b973c7c6a76166b9c0d91543d",
    marker: "METAL_FUNC IdxT elem_to_loc_2(",
    literal: "helperBody",
    change: (body: string) => body.replace("strides[1]", "strides[0]"),
  },
];

function extractBody(source: string, marker: string): string {
  const functionStart = source.indexOf(marker);
  if (functionStart < 0 || source.indexOf(marker, functionStart + 1) >= 0) {
    throw new Error(`Expected exactly one declaration for ${marker}`);
  }
  const start = source.indexOf("{", functionStart);
  if (start < 0) throw new Error("Missing function body");
  let depth = 0;
  for (let at = start; at < source.length; at++) {
    const c = source[at]!;
    if (!/[A-Za-z0-9_{}\[\]();*+=<>.,\s]/.test(c)) {
      throw new Error("Body left the audited extraction subset");
    }
    if (c === "{") depth++;
    if (c === "}" && --depth === 0) return source.slice(start, at + 1);
  }
  throw new Error("Unclosed function body");
}

export async function checkGeneralCopy2DSourceBinding(options: {
  proofsRoot?: string;
  leanSource?: string;
  selfTest?: boolean;
} = {}): Promise<void> {
  const proofs = options.proofsRoot
    ? pathToFileURL(`${resolve(options.proofsRoot)}/`)
    : new URL("../../", here);
  const lean = await Bun.file(options.leanSource
    ? resolve(options.leanSource)
    : new URL("GeneralCopy2DSyntax.lean", here)).text();
  for (const binding of bindings) {
    const native = await Bun.file(new URL(
      `.lake/sources/mlx/${revision}/mlx/backend/metal/kernels/${binding.file}`, proofs,
    )).text();
    if (new Bun.CryptoHasher("sha256").update(native).digest("hex") !== binding.hash) {
      throw new Error(`Pinned ${binding.file} content changed; review source and proof`);
    }
    const literals = [...lean.matchAll(new RegExp(
      `^def ${binding.literal} : String := r#"([\\s\\S]*?)"#`, "gm",
    ))];
    if (literals.length !== 1) throw new Error(`Expected one ${binding.literal} literal`);
    const literal = literals[0]![1]!;
    const body = extractBody(native, binding.marker);
    const equal = (left: string, right: string) => {
      if (left !== right) throw new Error(`Lean ${binding.literal} differs from exact source bytes`);
    };
    equal(body, literal);
    if (options.selfTest) {
      for (const changed of [binding.change(body), body + " "]) {
        if (changed === body) throw new Error("Mutation did not change the selected body");
        let rejected = false;
        try { equal(changed, literal); } catch { rejected = true; }
        if (!rejected) throw new Error("Mutation escaped exact body binding");
      }
    }
  }
}

if (import.meta.main) {
  await checkGeneralCopy2DSourceBinding({ selfTest: process.argv.includes("--self-test") });
  console.log("Exact pinned copy_gg_nd2 and elem_to_loc_2 body bytes match Lean literals. Host extraction remains trusted.");
}
