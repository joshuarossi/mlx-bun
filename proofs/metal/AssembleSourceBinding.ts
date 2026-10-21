// This host-side check binds the MLX constants in Assemble.lean to the pinned
// MLX sources: the attribute table and constant-space bound of
// metal_kernel.cpp, get_type_string of compiled.cpp (and dtype.h's enum, which
// makes its default branch unreachable), and custom_kernel.cpp compiling
// `metal::utils() + source_`. It is a trusted text extraction, not a verified
// C++ frontend; the assembly code itself is reviewed against metal_kernel.cpp.
import { resolve } from "node:path";

const revision = "1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const pins = {
  "mlx/backend/common/metal_kernel.cpp": "b4b36fae88cc3de926b423a82d44ab7de44c00e073c35784ff6b0034433c68b8",
  "mlx/backend/common/compiled.cpp": "a5a4e711add8b57b153be9c096089e312c747691dcb9ec61d4db1bf29186e2cc",
  "mlx/backend/metal/custom_kernel.cpp": "92548fba86690996a30725ef96bb8e0e299b69a4559e71c60340e7e11c1cac5e",
  "mlx/dtype.h": "a9b6c8719deae53015cfcf0452b570b2620c8c24b409b93e80ffd8ecb4537748",
} as const;
type Pinned = Record<keyof typeof pins, string>;
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

function only<T>(items: T[], what: string): T {
  if (items.length !== 1) throw new Error(`Expected exactly one ${what}, found ${items.length}`);
  return items[0]!;
}
function between(text: string, start: string, end: string, what: string): string {
  const at = text.indexOf(start);
  if (at < 0 || text.indexOf(start, at + 1) >= 0) throw new Error(`Expected exactly one ${what}`);
  const stop = text.indexOf(end, at + start.length);
  if (stop < 0) throw new Error(`Unterminated ${what}`);
  return text.slice(at + start.length, stop);
}
const same = (a: unknown, b: unknown) => JSON.stringify(a) === JSON.stringify(b);

interface Constants {
  attributes: [string, string][];
  maxConstant: number;
  types: [string, string][];
}

function cppConstants(cpp: Pinned): Constants {
  const kernel = cpp["mlx/backend/common/metal_kernel.cpp"];
  const table = between(kernel, "metal_attributes = {", "};", "metal_attributes table");
  const attributes = [...table.matchAll(/\{"(\w+)", "(\w+)"\}/g)].map(m => [m[1]!, m[2]!] as [string, string]);
  if (table.replace(/\{"\w+", "\w+"\},/g, "").trim() !== "") throw new Error("metal_attributes left the extraction subset");
  const maxConstant = Number(only([...kernel.matchAll(/constexpr int max_constant_array_size = (\d+);/g)], "max_constant_array_size")[1]);
  for (const use of ['arr.size() < max_constant_array_size ? "constant" : "device"', "arr.size() < max_constant_array_size) {"]) {
    if (kernel.split(use).length !== 2) throw new Error(`Expected one use: ${use}`);
  }
  if (kernel.split('attributes.push_back("  " + dtype + " " + attr + " [[" + attr + "]]");').length !== 2) {
    throw new Error("Attribute parameter format changed");
  }

  const body = between(cpp["mlx/backend/common/compiled.cpp"], "std::string get_type_string(Dtype d) {", "\n}\n", "get_type_string");
  const [cases, fallback] = body.split("default:");
  if (fallback === undefined || !fallback.includes("throw std::runtime_error")) throw new Error("get_type_string default no longer throws");
  const types = [...cases!.matchAll(/case (\w+):\s*return "([^"]*)";/g)].map(m => [m[1]!, m[2]!] as [string, string]);
  if (cases!.replace(/case \w+:\s*return "[^"]*";/g, "").replace(/switch \(d\) \{/, "").trim() !== "") {
    throw new Error("get_type_string left the extraction subset");
  }
  const enumeration = between(cpp["mlx/dtype.h"], "enum class Val {", "};", "Dtype::Val enum")
    .split(",").map(s => s.trim()).filter(s => s !== "");
  if (!same([...enumeration].sort(), types.map(t => t[0]).sort())) throw new Error("get_type_string cases differ from Dtype::Val");

  const custom = cpp["mlx/backend/metal/custom_kernel.cpp"];
  if (custom.split("[this] { return metal::utils() + source_; });").length !== 2) {
    throw new Error("custom_kernel.cpp no longer compiles metal::utils() + source_");
  }
  return { attributes, maxConstant, types };
}

function leanConstants(lean: string): Constants {
  const table = between(lean, "def metalAttributes : List (List Char × List Char) := [", "]\n", "metalAttributes");
  const attributes = [...table.matchAll(/\(chars!"(\w+)", chars!"(\w+)"\)/g)].map(m => [m[1]!, m[2]!] as [string, string]);
  if (table.replace(/\(chars!"\w+", chars!"\w+"\),?/g, "").trim() !== "") throw new Error("Lean metalAttributes left the extraction subset");
  const maxConstant = Number(only([...lean.matchAll(/^def maxConstantArraySize : Nat := (\d+)$/gm)], "maxConstantArraySize")[1]);
  const block = between(lean, "def typeString : Dtype → Option (List Char)\n", "\n\n", "typeString");
  const lines = block.split("\n");
  const types = lines.map(line => {
    const m = /^  \| \.(\w+) => some chars!"([^"\\]*)"$/.exec(line);
    if (!m) throw new Error(`Unexpected typeString line: ${line}`);
    // MLX's enumerator `bool_` is the Lean constructor `bool`.
    return [m[1] === "bool" ? "bool_" : m[1]!, m[2]!] as [string, string];
  });
  return { attributes, maxConstant, types };
}

function checkBinding(cpp: Pinned, lean: string): void {
  const c = cppConstants(cpp), l = leanConstants(lean);
  if (c.attributes.length !== 20) throw new Error(`Expected 20 metal attributes, found ${c.attributes.length}`);
  if (!same(c.attributes, l.attributes)) throw new Error("Lean metalAttributes differ from metal_kernel.cpp's table");
  if (c.maxConstant !== l.maxConstant) throw new Error("Lean maxConstantArraySize differs from max_constant_array_size");
  const sort = (t: [string, string][]) => [...t].sort((a, b) => a[0].localeCompare(b[0]));
  if (!same(sort(c.types), sort(l.types))) throw new Error("Lean typeString differs from get_type_string");
}

export async function checkMetalAssembleSourceBinding(options: SourceBindingOptions = {}): Promise<void> {
  const root = options.proofsRoot;
  const proofs = root ? new URL(`file://${resolve(root)}/`) : new URL("../", here);
  const leanPath = options.leanSource;
  const lean = await Bun.file(leanPath ? resolve(leanPath) : new URL("Assemble.lean", here)).text();
  const cpp = {} as Pinned;
  for (const [path, hash] of Object.entries(pins) as [keyof typeof pins, string][]) {
    const text = await Bun.file(new URL(`.lake/sources/mlx/${revision}/${path}`, proofs)).text();
    if (new Bun.CryptoHasher("sha256").update(text).digest("hex") !== hash) {
      throw new Error(`Pinned ${path} content changed; review the source and Assemble.lean.`);
    }
    cpp[path] = text;
  }
  checkBinding(cpp, lean);
  if (options.selfTest) {
    const kernel = "mlx/backend/common/metal_kernel.cpp", compiled = "mlx/backend/common/compiled.cpp";
    const mutations: [Pinned, string][] = [
      [{ ...cpp, [kernel]: cpp[kernel].replace('{"grid_origin", "uint3"},\n      {"grid_size", "uint3"},', '{"grid_size", "uint3"},\n      {"grid_origin", "uint3"},') }, lean],
      [{ ...cpp, [kernel]: cpp[kernel].replace('{"threads_per_simdgroup", "uint"}', '{"threads_per_simdgroup", "uint3"}') }, lean],
      [{ ...cpp, [kernel]: cpp[kernel].replace("max_constant_array_size = 8;", "max_constant_array_size = 9;") }, lean],
      [{ ...cpp, [compiled]: cpp[compiled].replace('return "float16_t";', 'return "half";') }, lean],
      [cpp, lean.replace('(chars!"grid_size", chars!"uint3"),\n', "")],
      [cpp, lean.replace("def maxConstantArraySize : Nat := 8", "def maxConstantArraySize : Nat := 16")],
      [cpp, lean.replace('| .bfloat16 => some chars!"bfloat16_t"', '| .bfloat16 => some chars!"bfloat"')],
    ];
    for (const [c, l] of mutations) {
      if (same(c, cpp) && l === lean) throw new Error("Self-test mutation did not apply");
      let rejected = false;
      try { checkBinding(c, l); } catch { rejected = true; }
      if (!rejected) throw new Error("Mutation escaped the MLX assembly constant binding");
    }
  }
}

// CLI: bun AssembleSourceBinding.ts [--proofs-root DIR] [--lean-source FILE] [--self-test]
if (import.meta.main) {
  await checkMetalAssembleSourceBinding({
    proofsRoot: option("--proofs-root"),
    leanSource: option("--lean-source"),
    selfTest: process.argv.includes("--self-test"),
  });
  console.log("Assemble.lean's attribute table, constant-space bound and type strings match pinned MLX sources.");
}
