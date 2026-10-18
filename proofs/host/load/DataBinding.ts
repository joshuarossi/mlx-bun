// Binds the load route's data literals (`host/load/Data.lean`) to the real files.
//   bun proofs/host/load/DataBinding.ts [--write] [--model-dir <dir>]
// Data.lean holds, verbatim, the files the route reads (config.json, the safetensors index,
// turboquant_fold.json, each shard's JSON header, persistence.worker.js), the model directory's
// listing (path, size), each shard's header length and the MLX weight table (`headers`, the
// literal `Data.headers_eq` checks against `stHeader` of the header text). Without --write this
// checks that the module is exactly what the files produce, and the sha256 pins below.
import { readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";
import { hashes } from "../ts/sources.ts";

const repo = new URL("../../../", import.meta.url).pathname;
const defaultModel = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-bun--Qwen3.8-27B-Trellis-3.2bpw/snapshots/cbb7a58a7222a19a3d02d36540c9cab5d9aadf0d`;

/** sha256 of every byte string Data.lean embeds; changing one requires reviewing the route. */
export const dataPins: Record<string, string> = {
  "config.json": "4f810d56164b8e83deb2c8e4fddc0b3321221724f8bedb2103d1395f15934cd3",
  "model.safetensors.index.json": "be4a509b5fc55b66f4dcdae9dbd5c9a8424b49b13d87fee9c46028b9ef0bec5f",
  "turboquant_fold.json": "30ae9baaca964d1a7c3f146fb0fab8c4d2b838549e5009f21b861183e5da3fba",
  "packages/inference/src/state/persistence.worker.js": "fcd071ca7fe207b5759afd0cb73693e07530e2bae30bb1e01df2151507134dda",
  "model-00001-of-00006.safetensors#header": "244477466aaa77465354d90879904b07764009bb19f9ce8ac0bb6a06e197f58a",
  "model-00002-of-00006.safetensors#header": "bb7345ef75657bad43b39308aa601f7b331659461c64fb306327cadae2042383",
  "model-00003-of-00006.safetensors#header": "b658fd015294713ea29f294a0d465f81579d63207707118bb7b486c0bdb9ed94",
  "model-00004-of-00006.safetensors#header": "0651149f225a5933759878901df2989bc5ab07b48b181659b0c18942b761341b",
  "model-00005-of-00006.safetensors#header": "2b6257025b110640fde3c20fa1a0cbaf5034904aeb0bb918290758cadbe81959",
  "model-00006-of-00006.safetensors#header": "f5e62742451f8b2e5dfc49cfdd9c0dc55ab02f183b86721f46dde3f3859efc4e",
  "listing": "aa30368f8a7cecb3c094512373e2623c23b1401fc6416fc4a27b0820a80bcfc4",
};

const TEXTS: [string, string][] = [["config.json", "config"], ["model.safetensors.index.json", "index"], ["turboquant_fold.json", "fold"]];

function walk(dir: string, base = dir): string[] {
  return readdirSync(dir).flatMap(n => {
    const p = join(dir, n);
    return statSync(p).isDirectory() ? walk(p, base) : [relative(base, p)];
  }).sort();
}

const CODE: Record<string, number> = { BOOL: 0, U8: 1, U16: 2, U32: 3, U64: 4, I8: 5, I16: 6, I32: 7, I64: 8, F16: 9, F32: 10, F64: 11, BF16: 12 };

function lit(name: string, doc: string, text: string): string {
  const h = hashes(text);
  return `/-- ${doc} -/\ndef ${name} : String := r${h}"${text}"${h}\ndata_chars ${name}Chars ${name}\n`;
}

const chars = (s: string) => `chars!${JSON.stringify(s)}`;

export async function render(model: string): Promise<{ lean: string; pins: Record<string, string> }> {
  const pins: Record<string, string> = {};
  const sha = (b: string | Uint8Array) => new Bun.CryptoHasher("sha256").update(b).digest("hex");
  const parts: string[] = [];
  const listing = walk(model);
  for (const [f, name] of TEXTS) {
    const t = await Bun.file(join(model, f)).text();
    pins[f] = sha(t);
    parts.push(lit(name, `Verbatim \`${f}\` of the model directory.`, t));
  }
  const worker = await Bun.file(join(repo, "packages/inference/src/state/persistence.worker.js")).text();
  pins["packages/inference/src/state/persistence.worker.js"] = sha(worker);
  parts.push(lit("worker", "Verbatim `packages/inference/src/state/persistence.worker.js` (a text import).", worker));
  const shards = listing.filter(f => f.endsWith(".safetensors") && !f.includes("/"));
  const shardRows: string[] = [];
  const tables: string[] = [];
  const eqs: string[] = [];
  for (const [i, f] of shards.entries()) {
    const file = Bun.file(join(model, f));
    const len = Number(new DataView(await file.slice(0, 8).arrayBuffer()).getBigUint64(0, true));
    const text = await file.slice(8, 8 + len).text();
    pins[f + "#header"] = sha(text);
    parts.push(lit(`header${i}`, `Verbatim JSON header of \`${f}\` (bytes 8 … ${8 + len}).`, text));
    shardRows.push(`(${chars(f)}, ${file.size}, ${len}, header${i}Chars)`);
    const header = JSON.parse(text) as Record<string, { dtype: string; shape: number[] }>;
    const rows = Object.entries(header).filter(([k]) => k !== "__metadata__")
      .map(([k, v]) => `(${chars(k)}, [${v.shape.join(", ")}], ${CODE[v.dtype]})`);
    tables.push(`/-- The weight table of \`${f}\` (\`stHeader\` of its header, \`header_eq${i}\`). -/\ndef table${i} : Host.Mlx.Ffi.Header :=\n  [${rows.join(",\n   ")}]\n`);
    eqs.push(`set_option maxRecDepth 1000000 in\nkernel_rfl header_eq${i} : stHeader header${i}Chars = some table${i}\n`);
  }
  pins["listing"] = sha(listing.map(f => `${f}\t${statSync(join(model, f)).size}`).join("\n"));
  const lean = `import host.ts.Source
import host.load.Header
namespace Host.Load.Data
open Host.Ts
set_option maxRecDepth 100000

/-! # The load route's data, verbatim

Generated and checked by \`host/load/DataBinding.ts\` against the model
directory and the repository: the files the route reads, each shard's
JSON header with its length and the file's size, the directory listing,
and the weight tables \`mlx_load_safetensors\` answers from, each proved
equal to \`stHeader\` of its shard's header text. -/

def modelDir : String := ${JSON.stringify(model)}

${parts.join("\n")}
/-- Every file of the model directory (relative path, size in bytes). -/
def listing : List (List Char × Nat) :=
  [${listing.map(f => `(${chars(f)}, ${statSync(join(model, f)).size})`).join(",\n   ")}]

/-- Each shard: file name, size, header length, header text. -/
def shards : List (List Char × Nat × Nat × List Char) :=
  [${shardRows.join(",\n   ")}]

${tables.join("\n")}
/-- The shards' weight tables, by file name. -/
def tables : List (List Char × Host.Mlx.Ffi.Header) :=
  [${shards.map((f, i) => `(${chars(f)}, table${i})`).join(",\n   ")}]

${eqs.join("\n")}
end Host.Load.Data
`;
  return { lean, pins };
}

function verify(embedded: string, rendered: string, pins: Record<string, string>): void {
  if (embedded !== rendered) throw new Error("host/load/Data.lean differs from the files it embeds");
  if (Object.keys(pins).length !== Object.keys(dataPins).length) throw new Error("load data pin inventory changed");
  for (const [k, v] of Object.entries(dataPins)) if (pins[k] !== v) throw new Error(`data pin changed: ${k}`);
}

/** Data.lean is exactly what the model directory and the repository produce, under the pins. */
export async function checkLoadDataBinding(model = defaultModel, selfTest = false): Promise<void> {
  const { lean, pins } = await render(model);
  const embedded = await Bun.file(new URL("./Data.lean", import.meta.url)).text();
  verify(embedded, lean, pins);
  if (selfTest) {
    const rejects = (label: string, check: () => void) => {
      try { check(); } catch { return; }
      throw new Error(`Load data mutation escaped: ${label}`);
    };
    rejects("literal", () => verify(embedded + "\n", lean, pins));
    for (const key of Object.keys(dataPins)) {
      rejects(key, () => verify(embedded, lean, { ...pins, [key]: pins[key] + "0" }));
      const missing = { ...pins };
      delete missing[key];
      rejects(`missing ${key}`, () => verify(embedded, lean, missing));
    }
  }
}

if (import.meta.main) {
  const mi = process.argv.indexOf("--model-dir");
  const model = mi < 0 ? defaultModel : process.argv[mi + 1]!;
  if (process.argv.includes("--write")) {
    const { lean, pins } = await render(model);
    await Bun.write(new URL("./Data.lean", import.meta.url), lean);
    console.log(JSON.stringify(pins, null, 2));
  } else {
    await checkLoadDataBinding(model, process.argv.includes("--self-test"));
    console.log(`Load route data binding passed: ${Object.keys(dataPins).length} pins`);
  }
}
