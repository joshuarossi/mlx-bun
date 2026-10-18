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

type Read = (path: string) => Promise<string>;
interface Module {
  file: ts.SourceFile;
  values: Map<string, ts.Expression>;
  imports: Map<string, { file: string; name: string }>;
}

/** Evaluate only static string syntax. No repository module is executed. */
async function kernelBodies(root: string, read: Read) {
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
  const evaluate = async (path: string, node: ts.Expression, stack = new Set<string>()): Promise<string> => {
    if (ts.isStringLiteral(node) || ts.isNoSubstitutionTemplateLiteral(node)) return node.text;
    if (ts.isParenthesizedExpression(node)) return evaluate(path, node.expression, stack);
    if (ts.isBinaryExpression(node) && node.operatorToken.kind === ts.SyntaxKind.PlusToken)
      return await evaluate(path, node.left, stack) + await evaluate(path, node.right, stack);
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
      for (const span of template.templateSpans) value += await evaluate(path, span.expression, stack) + text(span.literal);
      return value;
    }
    throw Error("Non-static kernel string expression: " + ts.SyntaxKind[node.kind]);
  };
  const result: { kind: string; name: string; source: string; header: string }[] = [];
  for (const [kind, relative, name] of destinations) {
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
    const found: { source: string; header: string }[] = [];
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
      found.push({ source: await evaluate(path, source), header: header ? await evaluate(path, header) : "" });
    }
    if (found.length !== 1) throw Error(`Expected one ${name} constructor, found ${found.length}`);
    result.push({ kind, name, ...found[0]! });
  }
  return result;
}

function render(bodies: Awaited<ReturnType<typeof kernelBodies>>): string {
  // FFI cstrings contain UTF-8 bytes. Host.Ts models each byte as one Char.
  const chars = (s: string) => {
    if (s.includes("\0")) throw Error("Embedded NUL in kernel body");
    return "chars!" + JSON.stringify(Buffer.from(s, "utf8").toString("latin1"));
  };
  return `import host.mlx.FfiEval
namespace Host.Mlx.SourceKernels
open Host.Mlx.FfiEval
set_option maxRecDepth 100000
set_option maxHeartbeats 0

/-! Exact UTF-8 source/header bytes passed to the ten route kernel constructors.
KernelSourceBinding.ts checks these literals against the pinned TypeScript.
The existing parsed-source bindings check each body's numerical programs. -/

def sources : KernelSources where
  source
${bodies.map(b => `    | .${b.kind} => ${chars(b.source)}`).join("\n")}
  header
${bodies.map(b => `    | .${b.kind} => ${chars(b.header)}`).join("\n")}

end Host.Mlx.SourceKernels
`;
}

export async function checkKernelSourceBinding(options: { repositoryRoot?: string; selfTest?: boolean } = {}): Promise<void> {
  const root = options.repositoryRoot ?? repository;
  const read = (path: string) => Bun.file(path).text();
  const bodies = await kernelBodies(root, read), expected = render(bodies);
  const actual = await Bun.file(new URL("./KernelSources.lean", import.meta.url)).text();
  if (actual !== expected) throw Error("KernelSources.lean differs from actual kernel constructor strings");
  if (options.selfTest) {
    for (const [file, from, to] of [
      ["sampling/normalized-argmax.ts", "const reduction = `", "const reduction = `// altered reduction\n"],
      ["trellis/gate-up-codebook.ts", "header: HEADER + CODEBOOK_WINDOW", "header: HEADER"],
      ["quantization/affine-row.ts", "source: SOURCE", 'source: SOURCE + "changed"'],
      ["delta/silu-rms-heads.ts", "source: SOURCE", 'source: SOURCE, header: "changed"'],
    ]) {
      let changed = false;
      const mutation: Read = async path => {
        const source = await read(path);
        if (!path.endsWith(file!)) return source;
        const next = source.replace(from!, to!);
        changed ||= source !== next;
        return next;
      };
      const result = render(await kernelBodies(root, mutation));
      if (!changed || result === actual) throw Error("Kernel source mutation escaped: " + file);
    }
    const changedRead: Read = async path => (await read(path)).replace('name: "gated_delta_step"', 'name: "wrong_kernel"');
    let rejected = false;
    try { await kernelBodies(root, changedRead); } catch { rejected = true; }
    if (!rejected) throw Error("Missing kernel constructor mutation escaped");
  }
}

if (import.meta.main) {
  if (process.argv.includes("--write")) {
    await Bun.write(new URL("./KernelSources.lean", import.meta.url), render(await kernelBodies(repository, path => Bun.file(path).text())));
  } else {
    await checkKernelSourceBinding({ selfTest: process.argv.includes("--self-test") });
    console.log("Exact source/header binding passed: 10 route kernels");
  }
}
