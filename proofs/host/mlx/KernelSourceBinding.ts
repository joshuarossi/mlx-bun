import ts from "typescript";
import { dirname, resolve } from "node:path";

const repository = new URL("../../../", import.meta.url).pathname;
const destinations = [
  ["affineRow", "quantization/affine-row.ts", "mlx_bun_affine_row"],
  ["siluRmsHeads", "delta/silu-rms-heads.ts", "mlx_bun_silu_rms_heads"],
  ["gatedDeltaStep", "delta/gated.ts", "gated_delta_step"],
  ["gatedRmsNorm", "gated-rms-norm.ts", "mlx_bun_gated_rms_norm"],
  ["residualRmsNorm", "residual-rms-norm.ts", "mlx_bun_residual_rms_norm"],
  ["gateUp", "trellis/gate-up-codebook.ts", "mlx_bun_trellis_gateup_codebook_row"],
  ["downPartial", "trellis/down-codebook.ts", "mlx_bun_trellis_down_codebook_row"],
  ["downFold", "trellis/down-codebook.ts", "mlx_bun_trellis_down_codebook_fold"],
  ["argmaxPartial", "sampling/normalized-argmax.ts", "normalized_argmax_partial"],
  ["argmaxFinish", "sampling/normalized-argmax.ts", "normalized_argmax_finish"],
] as const;
// The prefill route kernels (proofs: metal/kernels; enum: PrefillKernelSources.lean).
const prefillDestinations = [
  ["affine3Rows", "quantization/affine3-rows.ts", "mlx_bun_affine3_rows"],
  ["affine4Rows", "quantization/affine4-rows.ts", "mlx_bun_affine4_rows"],
  ["affineSplitMma", "quantization/affine-split-mma.ts", "mlx_bun_affine_split_mma"],
  ["gateUpCodebookMma", "trellis/gate-up-codebook-mma.ts", "mlx_bun_trellis_gateup_codebook_mma"],
  ["gateUpMmaWide", "trellis/gate-up-mma-wide.ts", "mlx_bun_trellis_gateup_mma_wide"],
  ["downMmaWide", "trellis/down-mma-wide.ts", "mlx_bun_trellis_down_mma_wide"],
  ["downK3iMmaWide", "trellis/down-mma-wide.ts", "mlx_bun_trellis_down_k3i_mma_wide"],
  ["aneTrellisFill", "ane/fill.ts", "mlx_bun_ane_trellis_fill"],
  ["aneTrellisFillK3i", "ane/fill.ts", "mlx_bun_ane_trellis_fill_k3i"],
  ["aneWriteHalf", "ane/fill.ts", "mlx_bun_ane_write_half"],
  ["vectorExpand", "trellis/vector-expand.ts", "mlx_bun_trellis_vector_expand"],
] as const;
type Destination = readonly [string, string, string];

type Read = (path: string) => Promise<string>;
/** What a `new MetalKernel({...})` passes to `mlx_fast_metal_kernel_new` (metal-kernel.ts). */
interface Constructor {
  source: string;
  header: string;
  inputNames: string[];
  outputNames: string[];
  rowContiguous: boolean;
  atomicOutputs: boolean;
}
interface Module {
  file: ts.SourceFile;
  values: Map<string, ts.Expression>;
  imports: Map<string, { file: string; name: string }>;
}

/** Evaluate only static string syntax. No repository module is executed. */
async function kernelBodies(root: string, read: Read, table: readonly Destination[] = destinations) {
  const modules = new Map<string, Module>();
  const module = async (path: string): Promise<Module> => {
    const cached = modules.get(path);
    if (cached) return cached;
    const file = ts.createSourceFile(path, await read(path), ts.ScriptTarget.Latest, true, ts.ScriptKind.TS);
    const result: Module = { file, values: new Map(), imports: new Map() };
    modules.set(path, result);
    for (const statement of file.statements) {
      if (ts.isVariableStatement(statement)) {
        for (const declaration of statement.declarationList.declarations) {
          if (ts.isIdentifier(declaration.name) && declaration.initializer) {
            if (result.values.has(declaration.name.text)) throw Error("Duplicate static binding");
            result.values.set(declaration.name.text, declaration.initializer);
          }
        }
      } else if (ts.isImportDeclaration(statement) && ts.isStringLiteral(statement.moduleSpecifier)) {
        const bindings = statement.importClause?.namedBindings;
        if (statement.moduleSpecifier.text.startsWith(".") && bindings && ts.isNamedImports(bindings)) {
          for (const binding of bindings.elements) result.imports.set(binding.name.text, {
            file: resolve(dirname(path), statement.moduleSpecifier.text + ".ts"),
            name: binding.propertyName?.text ?? binding.name.text,
          });
        }
      }
    }
    return result;
  };
  // `scope`: the static string arguments of the module-level arrow function being applied.
  const evaluate = async (path: string, node: ts.Expression, stack = new Set<string>(),
    scope = new Map<string, string>()): Promise<string> => {
    if (ts.isStringLiteral(node) || ts.isNoSubstitutionTemplateLiteral(node)) return node.text;
    if (ts.isParenthesizedExpression(node)) return evaluate(path, node.expression, stack, scope);
    if (ts.isBinaryExpression(node) && node.operatorToken.kind === ts.SyntaxKind.PlusToken)
      return await evaluate(path, node.left, stack, scope) + await evaluate(path, node.right, stack, scope);
    if (ts.isIdentifier(node) && scope.has(node.text)) return scope.get(node.text)!;
    if (ts.isCallExpression(node) && ts.isIdentifier(node.expression)) {
      // A module-level `const f = (a, …) => <static string>` applied to static strings.
      const f = (await module(path)).values.get(node.expression.text);
      if (!f || !ts.isArrowFunction(f) || !ts.isExpression(f.body) || f.parameters.length !== node.arguments.length
        || !f.parameters.every(p => ts.isIdentifier(p.name) && !p.initializer && !p.dotDotDotToken))
        throw Error("Non-static kernel string call: " + node.expression.text);
      const bound = new Map<string, string>();
      for (const [i, p] of f.parameters.entries())
        bound.set((p.name as ts.Identifier).text, await evaluate(path, node.arguments[i]!, stack, scope));
      return evaluate(path, f.body, stack, bound);
    }
    if (ts.isIdentifier(node)) {
      const key = path + ":" + node.text;
      if (stack.has(key)) throw Error("Cyclic static string: " + key);
      const next = new Set(stack).add(key), m = await module(path), local = m.values.get(node.text);
      if (local) return evaluate(path, local, next);
      const imported = m.imports.get(node.text);
      if (imported) {
        const value = (await module(imported.file)).values.get(imported.name);
        if (value) return evaluate(imported.file, value, next);
      }
      throw Error("Unresolved static string: " + key);
    }
    const raw = ts.isTaggedTemplateExpression(node) && ts.isPropertyAccessExpression(node.tag)
      && ts.isIdentifier(node.tag.expression) && node.tag.expression.text === "String" && node.tag.name.text === "raw";
    const template = raw ? node.template : node;
    const text = (part: ts.TemplateLiteralLikeNode) => raw ? part.rawText ?? part.text : part.text;
    if (ts.isNoSubstitutionTemplateLiteral(template)) return text(template);
    if (ts.isTemplateExpression(template)) {
      let value = text(template.head);
      for (const span of template.templateSpans) value += await evaluate(path, span.expression, stack, scope) + text(span.literal);
      return value;
    }
    throw Error("Non-static kernel string expression: " + ts.SyntaxKind[node.kind]);
  };
  // A static array of static strings: a constructor's `inputNames`/`outputNames`.
  const names = async (path: string, node: ts.Expression | undefined, what: string): Promise<string[]> => {
    if (!node || !ts.isArrayLiteralExpression(node)) throw Error("Non-static kernel " + what);
    const out: string[] = [];
    for (const element of node.elements) out.push(await evaluate(path, element));
    return out;
  };
  // A boolean literal, or metal-kernel.ts's default for an absent flag.
  const flag = (node: ts.Expression | undefined, absent: boolean, what: string): boolean => {
    if (!node) return absent;
    if (node.kind === ts.SyntaxKind.TrueKeyword) return true;
    if (node.kind === ts.SyntaxKind.FalseKeyword) return false;
    throw Error("Non-static kernel " + what);
  };
  const result: ({ kind: string; name: string } & Constructor)[] = [];
  for (const [kind, relative, name] of table) {
    const path = resolve(root, "packages/inference/src/kernels", relative), m = await module(path);
    const objects: ts.ObjectLiteralExpression[] = [];
    const visit = (node: ts.Node) => {
      if (ts.isNewExpression(node) && ts.isIdentifier(node.expression) && node.expression.text === "MetalKernel") {
        const argument = node.arguments?.[0];
        if (argument && ts.isObjectLiteralExpression(argument)) objects.push(argument);
      }
      ts.forEachChild(node, visit);
    };
    visit(m.file);
    const found: Constructor[] = [];
    for (const object of objects) {
      const fields = new Map<string, ts.Expression>();
      for (const field of object.properties) {
        if (ts.isPropertyAssignment(field) && (ts.isIdentifier(field.name) || ts.isStringLiteral(field.name))) {
          if (fields.has(field.name.text)) throw Error("Duplicate kernel field");
          fields.set(field.name.text, field.initializer);
        } else if (ts.isShorthandPropertyAssignment(field)) fields.set(field.name.text, field.name);
        else throw Error("Unsupported MetalKernel property syntax");
      }
      const named = fields.get("name");
      if (!named || await evaluate(path, named) !== name) continue;
      const source = fields.get("source"), header = fields.get("header");
      if (!source) throw Error("Missing kernel source: " + name);
      found.push({ source: await evaluate(path, source), header: header ? await evaluate(path, header) : "",
        inputNames: await names(path, fields.get("inputNames"), "inputNames: " + name),
        outputNames: await names(path, fields.get("outputNames"), "outputNames: " + name),
        rowContiguous: flag(fields.get("ensureRowContiguous"), true, "ensureRowContiguous: " + name),
        atomicOutputs: flag(fields.get("atomicOutputs"), false, "atomicOutputs: " + name) });
    }
    if (found.length !== 1) throw Error(`Expected one ${name} constructor, found ${found.length}`);
    result.push({ kind, name, ...found[0]! });
  }
  return result;
}

// FFI cstrings contain UTF-8 bytes. Host.Ts models each byte as one Char.
function chars(s: string): string {
  if (s.includes("\0")) throw Error("Embedded NUL in kernel body");
  return "chars!" + JSON.stringify(Buffer.from(s, "utf8").toString("latin1"));
}

function render(bodies: Awaited<ReturnType<typeof kernelBodies>>): string {
  return `import host.mlx.FfiEval
namespace Host.Mlx.SourceKernels
open Host.Mlx.FfiEval
set_option maxRecDepth 100000
set_option maxHeartbeats 0

/-! Exact UTF-8 source/header bytes passed to the ten route kernel constructors.
KernelSourceBinding.ts checks these literals against the pinned TypeScript.
What each body computes is proved from these bytes (proofs/metal/kernels). -/

def sources : KernelSources where
  source
${bodies.map(b => `    | .${b.kind} => ${chars(b.source)}`).join("\n")}
  header
${bodies.map(b => `    | .${b.kind} => ${chars(b.header)}`).join("\n")}

end Host.Mlx.SourceKernels
`;
}

type Bodies = Awaited<ReturnType<typeof kernelBodies>>;

/** The input and output names and the two flags of each constructor, as functions of `type`. */
function portDefs(type: string, bodies: Bodies): string {
  const list = (ns: string[]) => "[" + ns.map(chars).join(", ") + "]";
  return `def inputNames : ${type} → List (List Char)
${bodies.map(b => `  | .${b.kind} => ${list(b.inputNames)}`).join("\n")}

def outputNames : ${type} → List (List Char)
${bodies.map(b => `  | .${b.kind} => ${list(b.outputNames)}`).join("\n")}

/-- \`ensureRowContiguous\` (absent: \`true\`). -/
def rowContiguous : ${type} → Bool
${bodies.map(b => `  | .${b.kind} => ${b.rowContiguous}`).join("\n")}

/-- \`atomicOutputs\` (absent: \`false\`). -/
def atomicOutputs : ${type} → Bool
${bodies.map(b => `  | .${b.kind} => ${b.atomicOutputs}`).join("\n")}
`;
}

function renderPorts(bodies: Bodies): string {
  return `import host.mlx.Kernel
import host.ts.Source
namespace Host.Mlx.KernelPorts

/-! The input and output names and the \`ensureRowContiguous\`/\`atomicOutputs\` flags the ten route
kernel constructors pass to \`mlx_fast_metal_kernel_new\`.
KernelSourceBinding.ts checks these literals against the pinned TypeScript. -/

${portDefs("Kernel", bodies)}
end Host.Mlx.KernelPorts
`;
}

function renderPrefill(bodies: Awaited<ReturnType<typeof kernelBodies>>): string {
  return `import host.ts.Source
namespace Host.Mlx.PrefillSources
set_option maxRecDepth 100000
set_option maxHeartbeats 0

/-! Exact UTF-8 source/header bytes passed to the prefill route kernel constructors.
KernelSourceBinding.ts checks these literals against the pinned TypeScript. -/

inductive PrefillKernel where
  | ${bodies.map(b => b.kind).join(" | ")}
  deriving DecidableEq

/-- The name each constructor passes to \`mlx_fast_metal_kernel_new\`. -/
def name : PrefillKernel → List Char
${bodies.map(b => `  | .${b.kind} => ${chars(b.name)}`).join("\n")}

def source : PrefillKernel → List Char
${bodies.map(b => `  | .${b.kind} => ${chars(b.source)}`).join("\n")}

def header : PrefillKernel → List Char
${bodies.map(b => `  | .${b.kind} => ${chars(b.header)}`).join("\n")}

/-! The input and output names and the flags each constructor passes to \`mlx_fast_metal_kernel_new\`. -/

${portDefs("PrefillKernel", bodies)}
end Host.Mlx.PrefillSources
`;
}

export async function checkKernelSourceBinding(options: { repositoryRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  const root = options.repositoryRoot ?? repository;
  const read = (path: string) => Bun.file(path).text();
  const bodies = await kernelBodies(root, read), expected = render(bodies);
  const actual = await Bun.file(new URL("./KernelSources.lean", import.meta.url)).text();
  if (actual !== expected) throw Error("KernelSources.lean differs from actual kernel constructor strings");
  const ports = await Bun.file(new URL("./KernelPorts.lean", import.meta.url)).text();
  if (ports !== renderPorts(bodies)) throw Error("KernelPorts.lean differs from actual kernel constructor names and flags");
  const prefill = renderPrefill(await kernelBodies(root, read, prefillDestinations));
  if (await Bun.file(new URL("./PrefillKernelSources.lean", import.meta.url)).text() !== prefill)
    throw Error("PrefillKernelSources.lean differs from actual kernel constructor strings");
  if (options.selfTest) {
    for (const [file, from, to] of [
      ["sampling/normalized-argmax.ts", "const reduction = `", "const reduction = `// altered reduction\n"],
      ["trellis/gate-up-codebook.ts", "header: HEADER + CODEBOOK_WINDOW", "header: HEADER"],
      ["quantization/affine-row.ts", "source: SOURCE", 'source: SOURCE + "changed"'],
      ["delta/silu-rms-heads.ts", "source: SOURCE", 'source: SOURCE, header: "changed"'],
      ["delta/silu-rms-heads.ts", 'inputNames: ["x", "qscale", "kscale"]', 'inputNames: ["x", "kscale", "qscale"]'],
      ["residual-rms-norm.ts", 'outputNames: ["residual", "normalized"]', 'outputNames: ["normalized", "residual"]'],
      ["quantization/affine-row.ts", "ensureRowContiguous: true", "ensureRowContiguous: false"],
      ["gated-rms-norm.ts", 'outputNames: ["out"], source: SOURCE', 'outputNames: ["out"], source: SOURCE, atomicOutputs: true'],
    ]) {
      let changed = false;
      const mutation: Read = async path => {
        const source = await read(path);
        if (!path.endsWith(file!)) return source;
        const next = source.replace(from!, to!);
        changed ||= source !== next;
        return next;
      };
      const mutated = await kernelBodies(root, mutation);
      if (!changed || render(mutated) + renderPorts(mutated) === actual + ports)
        throw Error("Kernel source mutation escaped: " + file);
    }
    for (const [file, from, to] of [
      ["ane/fill.ts", "source(\"codes + (ulong)r", "source(\"codes + (ulong)(r + 1)"],
      ["trellis/down-mma-wide.ts", "header: HEADER + STATE_HEADER", "header: STATE_HEADER"],
      ["ane/fill.ts", 'inputNames: ["src", "dst"]', 'inputNames: ["dst", "src"]'],
      ["trellis/down-mma-wide.ts", "ensureRowContiguous: true", "ensureRowContiguous: false"],
      ["quantization/affine3-rows.ts", 'source: SOURCE, ensureRowContiguous: true', 'source: SOURCE, ensureRowContiguous: true, atomicOutputs: true'],
    ]) {
      let changed = false;
      const mutation: Read = async path => {
        const source = await read(path);
        if (!path.endsWith(file!)) return source;
        const next = source.replace(from!, to!);
        changed ||= source !== next;
        return next;
      };
      const result = renderPrefill(await kernelBodies(root, mutation, prefillDestinations));
      if (!changed || result === prefill) throw Error("Prefill kernel source mutation escaped: " + file);
    }
    const changedRead: Read = async path => (await read(path)).replace('name: "gated_delta_step"', 'name: "wrong_kernel"');
    let rejected = false;
    try { await kernelBodies(root, changedRead); } catch { rejected = true; }
    if (!rejected) throw Error("Missing kernel constructor mutation escaped");
    const dynamicRead: Read = async path => (await read(path))
      .replace('inputNames: ["x", "w", "scales", "biases"],\n    outputNames: ["y"], source: SOURCE, header: HEADER',
        'inputNames: INPUTS,\n    outputNames: ["y"], source: SOURCE, header: HEADER');
    rejected = false;
    try { await kernelBodies(root, dynamicRead); } catch { rejected = true; }
    if (!rejected) throw Error("Non-static kernel names mutation escaped");
  }
}

if (import.meta.main) {
  if (process.argv.includes("--write")) {
    const read = (path: string) => Bun.file(path).text();
    const bodies = await kernelBodies(repository, read);
    await Bun.write(new URL("./KernelSources.lean", import.meta.url), render(bodies));
    await Bun.write(new URL("./KernelPorts.lean", import.meta.url), renderPorts(bodies));
    await Bun.write(new URL("./PrefillKernelSources.lean", import.meta.url),
      renderPrefill(await kernelBodies(repository, read, prefillDestinations)));
  } else {
    await checkKernelSourceBinding({ selfTest: process.argv.includes("--self-test") });
    console.log(`Exact source/header/names/flags binding passed: ${destinations.length} decode and ${prefillDestinations.length} prefill route kernels`);
  }
}
