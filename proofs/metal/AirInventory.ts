// Floating-point operation inventory of the ten route custom kernels, read from
// Apple's Metal compiler output (CPU only: `xcrun metal -S -emit-llvm`, no
// device). The compiled text is MLX's `metal::utils()` preamble followed by the
// assembled kernel text stated in tests/Assemble.lean (`text k sig inst`).
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

const proofs = new URL("../", import.meta.url);
const revision = "1f8e74e3f12f31365464a6867c6579f0e9b29d85";
/** sha256 of `metal::utils()` (the string embedded in libmlx.dylib at `revision`). */
const preambleSha256 = "bfe14e75bc59019b613107950878a9548ec943f0e4d4b140199addcbb6f0e750";
/** utils.h and its quoted includes in `metal -H` inclusion order (make_compiled_preamble.sh). */
const preambleHeaders = ["bf16.h", "bf16_math.h", "complex.h", "defines.h", "logging.h", "utils.h"]
  .map(h => `mlx/backend/metal/kernels/${h}`);

export const kernels = [
  "affineRow", "siluRmsHeads", "gatedDeltaStep", "gatedRmsNorm", "residualRmsNorm",
  "gateUp", "downPartial", "downFold", "argmaxPartial", "argmaxFinish",
] as const;

/** MLX on macOS >= 15 compiles with MTL::MathModeSafe (CompileOptions' default)
 * and MTLCompileOptions' default fp32 functions (fast); on macOS 27 the
 * language version is 4.1 (device.cpp get_metal_version). */
export const compileFlags = ["-std=metal4.1", "-fmetal-math-mode=safe"];
/** `O0` counts static source sites: no loop in this AIR is unrolled at any
 * level (unroll pragmas pass to the GPU backend as loop metadata), and -O0
 * omits the default level's folding, canonicalization (fsub X,C → fadd
 * X,-C; fdiv by 2^k → fmul), bf16 narrowing and CSE. */
export const variants = {
  default: [],
  O0: ["-O0"],
} as const satisfies Record<string, readonly string[]>;
export type Variant = keyof typeof variants;

// ---------------------------------------------------------------------------
// Lean texts

/** Decode the Lean string literal whose opening quote is at `at`. */
function leanString(text: string, at: number): { value: string; end: number } {
  if (text[at] !== '"') throw Error("Expected a string literal");
  let value = "", i = at + 1;
  const hex = (n: number) => {
    const digits = text.slice(i, i + n);
    if (!new RegExp(`^[0-9a-fA-F]{${n}}$`).test(digits)) throw Error("Bad escape");
    i += n;
    return String.fromCharCode(parseInt(digits, 16));
  };
  for (;;) {
    const c = text[i++];
    if (c === undefined) throw Error("Unterminated string literal");
    if (c === '"') return { value, end: i };
    if (c !== "\\") { value += c; continue; }
    const e = text[i++];
    if (e === "n") value += "\n";
    else if (e === "t") value += "\t";
    else if (e === "r") value += "\r";
    else if (e === "\\" || e === '"' || e === "'") value += e;
    else if (e === "x") value += hex(2);
    else if (e === "u") value += hex(4);
    else if (e === "\n") { while (/[ \t\r\n]/.test(text[i] ?? "")) i++; } // string gap
    else throw Error(`Unsupported Lean escape \\${e}`);
  }
}

/** A `chars!` literal: one Lean `Char` per byte. */
function bytes(chars: string): Buffer {
  if ([...chars].some(c => c.codePointAt(0)! > 0xff)) throw Error("Lean byte text holds a non-byte Char");
  return Buffer.from(chars, "latin1");
}

/** `sources.source` and `sources.header` of host/mlx/KernelSources.lean. */
function kernelSources(lean: string) {
  const split = lean.indexOf("\n  header\n");
  if (split < 0 || lean.indexOf("\n  source\n") < 0) throw Error("KernelSources.lean layout changed");
  const source = new Map<string, Buffer>(), header = new Map<string, Buffer>();
  for (const m of lean.matchAll(/\n    \| \.(\w+) => chars!"/g)) {
    const table = m.index! < split ? source : header;
    if (table.has(m[1]!)) throw Error(`Duplicate ${m[1]} source`);
    table.set(m[1]!, bytes(leanString(lean, m.index! + m[0].length - 1).value));
  }
  return { source, header };
}

/** `<k>Signature` and `<k>Instantiation` of tests/Assemble.lean. */
function assembledParts(lean: string) {
  const parts = new Map<string, Buffer>();
  for (const m of lean.matchAll(/^def (\w+(?:Signature|Instantiation)) : List Char :=\n  chars!"/gm)) {
    const { value, end } = leanString(lean, m.index! + m[0].length - 1);
    if (lean[end] !== "\n") throw Error(`${m[1]} is not a bare literal`);
    parts.set(m[1]!, bytes(value));
  }
  const text = "def text (k : Kernel) (signature instantiation : List Char) : List Char :=\n" +
    '  sources.header k ++ signature ++ sources.source k ++ chars!"\\n}\\n" ++ instantiation\n';
  if (!lean.includes(text)) throw Error("tests/Assemble.lean `text` changed");
  return parts;
}

export interface KernelText { kernel: string; name: string; text: Buffer }

/** The assembled kernel texts `text k <k>Signature <k>Instantiation`. */
export async function kernelTexts(): Promise<KernelText[]> {
  const { source, header } = kernelSources(await Bun.file(new URL("host/mlx/KernelSources.lean", proofs)).text());
  const parts = assembledParts(await Bun.file(new URL("metal/tests/Assemble.lean", proofs)).text());
  return kernels.map(kernel => {
    const body = source.get(kernel), head = header.get(kernel);
    const sig = parts.get(kernel + "Signature"), inst = parts.get(kernel + "Instantiation");
    if (!body || !head || !sig || !inst) throw Error(`Missing Lean text for ${kernel}`);
    const name = /\[\[kernel\]\] void (\w+)\(/.exec(sig.toString("latin1"))?.[1];
    if (!name) throw Error(`No kernel name in ${kernel}Signature`);
    return { kernel, name, text: Buffer.concat([head, sig, body, Buffer.from("\n}\n"), inst]) };
  });
}

// ---------------------------------------------------------------------------
// Preamble

async function pinnedMlxSource(path: string): Promise<string> {
  const cached = Bun.file(new URL(`.lake/sources/mlx/${revision}/${path}`, proofs));
  if (await cached.exists()) return cached.text();
  const response = await fetch(`https://raw.githubusercontent.com/ml-explore/mlx/${revision}/${path}`);
  if (!response.ok) throw Error(`Cannot fetch pinned MLX source ${path}: HTTP ${response.status}`);
  return response.text();
}

let preambleCache: Promise<Buffer> | undefined;
/** `metal::utils()`, rebuilt as make_compiled_preamble.sh does: each header's
 * text after a banner and `#line 1`, minus `#include "….h"` and `#pragma once`
 * lines (`grep -v`), inside `R"preamble(\n$CONTENT\n)preamble"`. */
export function preamble(): Promise<Buffer> {
  return preambleCache ??= (async () => {
    const bar = "/".repeat(79);
    const lines = ["// Copyright © 2025 Apple Inc.", "", "// Auto generated source for mlx/backend/metal/kernels/utils.h", ""];
    for (const path of preambleHeaders) {
      const text = await pinnedMlxSource(path);
      const kept = (text.endsWith("\n") ? text.slice(0, -1) : text).split("\n")
        .filter(line => !/#include ".*.h"/.test(line) && !line.includes("#pragma once"));
      lines.push(bar, `// Contents from "${path}"`, bar, "", `#line 1 "${path}"`, ...kept, "");
    }
    lines.push(bar);
    const result = Buffer.from("\n" + lines.join("\n") + "\n", "utf8");
    const sha = new Bun.CryptoHasher("sha256").update(result).digest("hex");
    if (sha !== preambleSha256) throw Error(`Rebuilt metal::utils() has sha256 ${sha}, expected ${preambleSha256}`);
    return result;
  })();
}

// ---------------------------------------------------------------------------
// Compilation

/** `xcrun metal … -S -emit-llvm` of `metal::utils() + text` (CPU only). */
export async function compileIr(text: Buffer, extra: readonly string[] = []): Promise<string> {
  const dir = await mkdtemp(join(tmpdir(), "air-inventory-"));
  try {
    const file = join(dir, "kernel.metal");
    await Bun.write(file, Buffer.concat([await preamble(), text]));
    const proc = Bun.spawn(["xcrun", "metal", ...compileFlags, ...extra, "-S", "-emit-llvm", "-o", "-", file],
      { stdout: "pipe", stderr: "pipe" });
    const [ir, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
    if (code !== 0) throw Error(`xcrun metal failed (${code}):\n${err}`);
    return ir;
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

// ---------------------------------------------------------------------------
// IR inventory

/** float → f32, bfloat → bf16, half → f16, double → f64, <4 x float> → v4f32. */
function typeName(type: string): string {
  const scalar: Record<string, string> = { float: "f32", bfloat: "bf16", half: "f16", double: "f64" };
  const vector = /^<(\d+) x (\w+)>$/.exec(type);
  if (vector) return "v" + vector[1] + typeName(vector[2]!);
  return scalar[type] ?? type;
}
const isFloat = (type: string) => /^(<\d+ x )?(float|bfloat|half|double)>?$/.test(type);
const fpFlags = /^(?:(?:fast|nnan|ninf|nsz|arcp|contract|afn|reassoc) )*/;

/** The per-function inventory of one IR line: an operation key or a call. */
function classify(line: string): { key?: string; call?: string; constant?: boolean } {
  const body = /^\s*(?:%[\w.]+ = )?(.*)$/.exec(line)![1]!;
  const call = /^(?:tail |musttail |notail )?call [^@]*@"?([\w.$]+)"?\((.*)$/.exec(body);
  if (call) return { call: call[1]!, constant: !call[2]!.includes("%") };
  if (/^(?:\w+ )*call /.test(body)) throw Error(`Unparsed call: ${line}`);
  const op = /^(fadd|fsub|fmul|fdiv|frem|fneg|fcmp) (.*)$/.exec(body);
  if (op) {
    const rest = op[2]!.replace(fpFlags, "");
    if (op[1] === "fcmp") {
      const m = /^(\w+) (<\d+ x \w+>|\w+) /.exec(rest)!;
      return { key: `fcmp.${m[1]}.${typeName(m[2]!)}` };
    }
    const m = /^(<\d+ x \w+>|\w+) /.exec(rest)!;
    return { key: `${op[1]}.${typeName(m[1]!)}` };
  }
  const cast = /^(fpext|fptrunc|uitofp|sitofp|fptoui|fptosi|bitcast) (.*) to ([^,]+)(?:,.*)?$/.exec(body);
  if (cast) {
    const from = cast[2]!.replace(/ \S+$/, ""), to = cast[3]!.trim();
    if (from.includes("*") || to.includes("*") || !(isFloat(from) || isFloat(to))) return {};
    return { key: `${cast[1]} ${typeName(from)}→${typeName(to)}` };
  }
  return {};
}

interface IrFunction { name: string; lines: string[] }
function functions(ir: string): Map<string, IrFunction> {
  const result = new Map<string, IrFunction>();
  let current: IrFunction | undefined;
  for (const line of ir.split("\n")) {
    if (current) {
      if (line === "}") { result.set(current.name, current); current = undefined; }
      else current.lines.push(line);
    } else if (line.startsWith("define ")) {
      const name = /@"?([\w.$]+)"?\(/.exec(line)?.[1];
      if (!name) throw Error(`Unparsed definition: ${line}`);
      current = { name, lines: [] };
    }
  }
  if (current) throw Error("Unterminated function");
  return result;
}

export type Inventory = Map<string, number>;
/** Calls kept by name: AIR intrinsics and LLVM intrinsics with an FP type in
 * their name; other LLVM intrinsics (memset, fshl, lifetime, …) are integer or
 * memory operations. */
const counted = (callee: string) =>
  callee.startsWith("air.") || /^llvm\..*\.(v\d+)?(f16|bf16|f32|f64)(\.|$)/.test(callee);
const ignored = (callee: string) => callee.startsWith("llvm.");

/** The static inventory of `entry` (constant-operand conversions, which the
 * optimizer folds, are marked `(const)`): each call to a defined function (helpers
 * left out of line at -O0) contributes the callee's inventory per call site. */
export function inventoryOf(ir: string, entry: string): Inventory {
  const defs = functions(ir), memo = new Map<string, Inventory>();
  const visit = (name: string, stack: string[]): Inventory => {
    const done = memo.get(name);
    if (done) return done;
    if (stack.includes(name)) throw Error(`Recursive call: ${[...stack, name].join(" → ")}`);
    const f = defs.get(name);
    if (!f) throw Error(`No definition of @${name}`);
    const inv: Inventory = new Map();
    const add = (key: string, n = 1) => inv.set(key, (inv.get(key) ?? 0) + n);
    for (const line of f.lines) {
      const { key, call, constant } = classify(line);
      if (key) add(key);
      else if (call && defs.has(call)) for (const [k, n] of visit(call, [...stack, name])) add(k, n);
      else if (call && counted(call)) add(constant && call.startsWith("air.convert.") ? call + " (const)" : call);
      else if (call && !ignored(call)) add(`call ${call}`);
    }
    memo.set(name, inv);
    return inv;
  };
  return visit(entry, []);
}

/** Inventory of `kernel`'s instantiated function, compiled with `variant`
 * (by default the static source-site inventory, -O0). */
export async function airInventory(kernel: string, variant: Variant = "O0"): Promise<Inventory> {
  const k = (await kernelTexts()).find(t => t.kernel === kernel);
  if (!k) throw Error(`Unknown kernel ${kernel}; expected one of ${kernels.join(", ")}`);
  return inventoryOf(await compileIr(k.text, variants[variant]), k.name);
}

// ---------------------------------------------------------------------------
// Source call → intrinsic lowering (from -O0 -gline-tables-only locations)

export interface Lowering { site: string; line: number; column: number; resolved: string; intrinsic: string }

/** Each AIR intrinsic call (conversions aside) of `ir` attributed to the call
 * written in the kernel text: the innermost `inlinedAt` location inside the
 * text, the function that call resolved to, and the intrinsic it became. */
export function loweringsOf(ir: string, text: Buffer, pre: Buffer): Lowering[] {
  const meta = new Map<string, string>();
  for (const m of ir.matchAll(/^(!\d+) = (?:distinct )?(.*)$/gm)) meta.set(m[1]!, m[2]!);
  const field = (node: string | undefined, name: string) => node && new RegExp(`\\b${name}: ("[^"]*"|!\\d+|\\d+)`).exec(node)?.[1];
  const fileOf = (scope: string) => JSON.parse(field(meta.get(field(meta.get(scope), "file") ?? ""), "filename") ?? '""') as string;
  const subprogram = (scope: string): string => {
    const node = meta.get(scope) ?? "";
    return node.startsWith("!DISubprogram") ? JSON.parse(field(node, "name")!) : subprogram(field(node, "scope")!);
  };
  // The kernel text continues the preamble's last `#line 1 "<file>"`.
  const preLines = pre.toString("utf8").split("\n");
  const last = preLines.findLastIndex(l => l.startsWith("#line 1 "));
  const textFile = JSON.parse(preLines[last]!.slice("#line 1 ".length)) as string;
  const offset = preLines.length - 1 - (last + 1), textLines = text.toString("utf8").split("\n");
  const result: Lowering[] = [];
  for (const m of ir.matchAll(/call [^@]*@(air\.[\w.]+)\(.*!dbg (!\d+)/g)) {
    if (m[1]!.startsWith("air.convert.")) continue;
    const chain: { line: number; column: number; scope: string }[] = [];
    for (let loc: string | undefined = m[2]; loc; loc = field(meta.get(loc), "inlinedAt")) {
      const node = meta.get(loc)!;
      chain.push({ line: Number(field(node, "line")), column: Number(field(node, "column")), scope: field(node, "scope")! });
    }
    const at = chain.findIndex(l => fileOf(l.scope) === textFile && l.line > offset);
    if (at < 0) throw Error(`No kernel-text location for ${m[1]}`);
    const { line, column } = chain[at]!, k = line - offset;
    const site = /^[A-Za-z_][\w:]*/.exec(textLines[k - 1]!.slice(column - 1))?.[0] ?? "?";
    const callee = at > 0 ? chain[at - 1]!.scope : undefined;
    const resolved = callee ? `${subprogram(callee)} [${fileOf(callee).split("/").pop()}]` : "(direct)";
    result.push({ site, line: k, column, resolved, intrinsic: m[1]! });
  }
  return result;
}

export async function airLowerings(kernel: string): Promise<Lowering[]> {
  const k = (await kernelTexts()).find(t => t.kernel === kernel);
  if (!k) throw Error(`Unknown kernel ${kernel}`);
  return loweringsOf(await compileIr(k.text, ["-O0", "-gline-tables-only"]), k.text, await preamble());
}

// ---------------------------------------------------------------------------
// CLI: bun AirInventory.ts [kernel…]

if (import.meta.main) {
  const version = (await new Response(Bun.spawn(["xcrun", "metal", "--version"]).stdout).text()).split("\n")[0];
  console.log(`${version}; flags ${compileFlags.join(" ")}; metal::utils() sha256 ${preambleSha256}`);
  const selected = process.argv.slice(2);
  for (const kernel of selected.length ? selected : kernels) {
    const [def, o0, lowered] = await Promise.all([airInventory(kernel, "default"), airInventory(kernel, "O0"), airLowerings(kernel)]);
    const keys = [...new Set([...o0.keys(), ...def.keys()])].sort();
    const width = Math.max(...keys.map(k => k.length));
    console.log(`\n${kernel}\n  ${"operation".padEnd(width)}    -O0  default`);
    for (const key of keys) {
      const a = o0.get(key) ?? 0, b = def.get(key) ?? 0;
      console.log(`  ${key.padEnd(width)} ${String(a).padStart(6)} ${String(b).padStart(8)}${a === b ? "" : "  *"}`);
    }
    const groups = new Map<string, string[]>();
    for (const l of lowered) {
      const key = `${l.site} → ${l.resolved} → ${l.intrinsic}`;
      groups.set(key, [...(groups.get(key) ?? []), `${l.line}:${l.column}`]);
    }
    console.log("  lowering (source call @ text line:column → resolved function → intrinsic):");
    for (const [key, sites] of groups) console.log(`    ${key}  @ ${sites.join(", ")}`);
    const bf16 = (o0.get("llvm.fmuladd.bf16") ?? 0) + (def.get("llvm.fmuladd.bf16") ?? 0);
    console.log(`  llvm.fmuladd.bf16: ${bf16 ? "present" : "none"}`);
  }
}
