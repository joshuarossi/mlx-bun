// Exact-byte binding for selected CPU scalar-constructor paths. This is not
// a C++ frontend, std::copy proof, host ABI, allocator or coherence proof.
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { checkScalarFullHostSourceBinding } from "./ScalarFullHostSourceBinding";
const revision = "1f8e74e3f12f31365464a6867c6579f0e9b29d85";
const hashes: Record<string, string> = {
  "array.h": "5c90807aa44226c557c5bda740bdc1732109810e8862697ad5d374092669db65",
  "ops.cpp": "6eae219354d0f9be37a064cb327c863fc3a12dba6668fd61d428e8d09d6baaf2",
  "dtype.h": "a9b6c8719deae53015cfcf0452b570b2620c8c24b409b93e80ffd8ecb4537748",
  "types/half_types.h": "43fa5d204abea6db4211f620058bde2f6869563f2615de2d5d5b28d9f7494229",
  "types/bf16.h": "a279b39030b406eda06a42069abd660ad24fced7b1cfe33378b236b2ce1e786f",
};
export interface CpuScalarBindingOptions {
  proofsRoot?: string;
  leanSource?: string;
  arrayHeader?: string;
  opsSource?: string;
  dtypeHeader?: string;
  halfTypesHeader?: string;
  bf16Header?: string;
  selfTest?: boolean;
}
function extract(source: string, marker: string): string {
  const start = source.indexOf(marker);
  if (start < 0 || source.indexOf(marker, start + 1) >= 0) throw Error(`Expected one ${marker}`);
  const open = source.indexOf("{\n", start);
  if (open < 0) throw Error("Missing selected function body");
  let depth = 0;
  for (let i = open; i < source.length; i++) {
    if (source[i] === "{") depth++;
    if (source[i] === "}" && --depth === 0) return source.slice(start, i + 1);
  }
  throw Error("Unclosed selected scalar function");
}
function literal(lean: string, name: string): string {
  const raw = [...lean.matchAll(new RegExp(`^def ${name} : String := r#"([\\s\\S]*?)"#`, "gm"))];
  if (raw.length === 1) return raw[0]![1]!;
  const plain = [...lean.matchAll(new RegExp(`^def ${name} : String := "([^"\\n]*)"`, "gm"))];
  if (plain.length !== 1) throw Error(`Expected one ${name} literal`);
  return JSON.parse(`"${plain[0]![1]!}"`);
}
function caseSpan(source: string, type: string): string {
  const marker = `    case ${type}:`;
  const start = source.indexOf(marker);
  if (start < 0 || source.indexOf(marker, start + 1) >= 0) throw Error(`Expected unique ${type} case`);
  const end = source.indexOf("      break;", start);
  if (end < 0) throw Error("Missing selected case break");
  return source.slice(start, end + "      break;".length);
}
function verify(texts: Record<string, string>, lean: string): void {
  for (const [path, expected] of Object.entries(hashes)) {
    if (new Bun.CryptoHasher("sha256").update(texts[path]!).digest("hex") !== expected) throw Error(`Pinned ${path} changed`);
  }
  const constructor = extract(texts["array.h"]!, "template <typename T>\narray::array(T val,");
  const init = extract(texts["array.h"]!, "template <typename It>\nvoid array::init(It src)");
  const header = init.slice(0, init.indexOf("    case bool_:"));
  const fallback = extract(texts["types/bf16.h"]!, "  _MLX_BFloat16(const float& x)");
  const start = fallback.indexOf("in.u +=");
  const end = fallback.indexOf("bits_ = in.u >> 16;", start);
  if (start < 0 || end < 0) throw Error("Missing fallback RNE path");
  const rounding = fallback.slice(start, end + "bits_ = in.u >> 16;".length);
  const fragments: Record<string, string> = {
    constructorSource: constructor,
    initSource: init,
    initHeaderSource: header,
    bf16CaseSource: caseSpan(init, "bfloat16"),
    fp32CaseSource: caseSpan(init, "float32"),
    roundingSource: rounding,
  };
  for (const [name, expected] of Object.entries(fragments)) {
    if (literal(lean, name) !== expected) throw Error(`CPU scalar ${name} differs from selected pinned bytes`);
  }
  const zero = extract(texts["ops.cpp"]!, "array zeros(const Shape& shape, Dtype dtype");
  if (!zero.includes(`full(shape, ${literal(lean, "zeroCallSource")},`)) throw Error("zeros scalar integer producer changed");
  if (!texts["dtype.h"]!.includes("inline constexpr Dtype bfloat16{Dtype::Val::bfloat16, sizeof(uint16_t)};") ||
      !texts["dtype.h"]!.includes("inline constexpr Dtype float32{Dtype::Val::float32, sizeof(float)};")) throw Error("CPU scalar dtype size declaration changed");
  for (const fragment of ["#ifdef __ARM_FEATURE_BF16", "#include <arm_bf16.h>", "using ::bfloat16_t;", '#include "mlx/types/bf16.h"', "typedef struct _MLX_BFloat16 bfloat16_t;"])
    if (!texts["types/half_types.h"]!.includes(fragment)) throw Error("CPU BF16 macro selection changed");
  for (const fragment of ["if (std::isnan(x))", "bits_ = __MLX_BFLOAT_NAN__;", "in.f = x;"])
    if (!fallback.includes(fragment)) throw Error("Fallback representation/non-NaN path changed");
}
export async function checkCpuScalarSourceBinding(options: CpuScalarBindingOptions = {}): Promise<void> {
  await checkScalarFullHostSourceBinding({ proofsRoot: options.proofsRoot, selfTest: options.selfTest });
  const root = options.proofsRoot ? pathToFileURL(`${resolve(options.proofsRoot)}/`) : new URL("../../", import.meta.url);
  const sourceRoot = new URL(`.lake/sources/mlx/${revision}/mlx/`, root);
  const overrides: Record<string, string | undefined> = {
    "array.h": options.arrayHeader, "ops.cpp": options.opsSource, "dtype.h": options.dtypeHeader,
    "types/half_types.h": options.halfTypesHeader, "types/bf16.h": options.bf16Header,
  };
  const texts = Object.fromEntries(await Promise.all(Object.keys(hashes).map(async path => [path,
    await Bun.file(overrides[path] ? resolve(overrides[path]!) : new URL(path, sourceRoot)).text()])));
  const lean = await Bun.file(options.leanSource ? resolve(options.leanSource) : new URL("CpuScalarSourceSyntax.lean", import.meta.url)).text();
  verify(texts, lean);
  if (options.selfTest) {
    const changes = [
      ["array.h", "init(&val);", "init(&other);"],
      ["array.h", "size() * size_of(dtype())", "size() + size_of(dtype())"],
      ["array.h", "std::copy(src, src + size(), data<bfloat16_t>());", "std::copy(src, src + size(), data<float16_t>());"],
      ["array.h", "std::copy(src, src + size(), data<float>());", "std::copy(src, src + size(), data<double>());"],
      ["ops.cpp", "full(shape, array(0, dtype)", "full(shape, array(1, dtype)"],
      ["types/bf16.h", "uint32_t(0x7FFF)", "uint32_t(0x7FFE)"],
      ["types/bf16.h", "bits_ = in.u >> 16;", "bits_ = in.u >> 15;"],
      ["types/half_types.h", "#ifdef __ARM_FEATURE_BF16", "#ifdef __ARM_FEATURE_BF16_CHANGED"],
      ["dtype.h", "Dtype::Val::bfloat16, sizeof(uint16_t)", "Dtype::Val::bfloat16, sizeof(uint32_t)"],
    ] as const;
    for (const [path, from, to] of changes) {
      const changed = texts[path]!.replace(from, to);
      if (changed === texts[path]) throw Error(`Production scalar mutation did not apply: ${from}`);
      let rejected = false;
      try { verify({ ...texts, [path]: changed }, lean); } catch { rejected = true; }
      if (!rejected) throw Error(`Production scalar mutation escaped binding: ${from}`);
    }
    for (const from of ["array(0, dtype)", "0x7FFF", "src + size()", "init(&val);"]) {
      const changed = lean.replace(from, from + " ");
      if (changed === lean) throw Error("Lean scalar mutation did not apply");
      let rejected = false;
      try { verify(texts, changed); } catch { rejected = true; }
      if (!rejected) throw Error("Lean scalar literal mutation escaped binding");
    }
  }
}
function option(name: string): string | undefined {
  const i = process.argv.indexOf(name); if (i < 0) return undefined;
  const value = process.argv[i + 1]; if (!value || value.startsWith("--")) throw Error(`Missing ${name}`); return value;
}
if (import.meta.main) {
  await checkCpuScalarSourceBinding({ proofsRoot: option("--proofs-root"), leanSource: option("--lean-source"),
    arrayHeader: option("--array-header"), opsSource: option("--ops-source"), dtypeHeader: option("--dtype-header"),
    halfTypesHeader: option("--half-types-header"), bf16Header: option("--bf16-header"), selfTest: process.argv.includes("--self-test") });
  console.log("CPU scalar source binding passed");
}
