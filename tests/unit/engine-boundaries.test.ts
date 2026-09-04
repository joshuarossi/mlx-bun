import { expect, test } from "bun:test";
import ts from "typescript";
import { resolve, relative } from "node:path";

test("portable contracts, engine, and inference import only their own dependency layers", async () => {
  const root = resolve(import.meta.dir, "../..");
  const layers = ["src/contracts", "src/engine", "src/inference"];
  const violations: string[] = [];
  const options: ts.CompilerOptions = { moduleResolution: ts.ModuleResolutionKind.Bundler,
    module: ts.ModuleKind.Preserve, baseUrl: root };
  let files = 0;
  for (const layer of layers) {
    for await (const path of new Bun.Glob("**/*.ts").scan(resolve(root, layer))) {
      files++;
      const absolute = resolve(root, layer, path);
      const source = ts.createSourceFile(absolute, await Bun.file(absolute).text(), ts.ScriptTarget.Latest, true);
      const inspect = (literal: ts.Node | undefined) => {
        if (!literal || !ts.isStringLiteralLike(literal)) {
          violations.push(`${relative(root, absolute)}: nonliteral module reference`); return;
        }
        const target = ts.resolveModuleName(literal.text, absolute, options, ts.sys).resolvedModule;
        const rel = target && relative(root, target.resolvedFileName).replaceAll("\\", "/");
        const allowed = layer === "src/contracts" ? ["src/contracts"] :
          layer === "src/inference" ? ["src/contracts", "src/inference"] : layers;
        if (!rel || !allowed.some((prefix) => rel.startsWith(`${prefix}/`)))
          violations.push(`${relative(root, absolute)} -> ${literal.text} (${rel ?? "unresolved"})`);
      };
      const visit = (node: ts.Node) => {
        if (ts.isImportDeclaration(node) || ts.isExportDeclaration(node)) {
          if (node.moduleSpecifier) inspect(node.moduleSpecifier);
        } else if (ts.isImportTypeNode(node) && ts.isLiteralTypeNode(node.argument)) {
          inspect(node.argument.literal);
        } else if (ts.isImportEqualsDeclaration(node) && ts.isExternalModuleReference(node.moduleReference)) {
          inspect(node.moduleReference.expression);
        } else if (ts.isCallExpression(node) && (node.expression.kind === ts.SyntaxKind.ImportKeyword ||
          (ts.isIdentifier(node.expression) && node.expression.text === "require"))) inspect(node.arguments[0]);
        ts.forEachChild(node, visit);
      };
      visit(source);
    }
  }
  expect(files).toBeGreaterThan(0);
  expect(violations).toEqual([]);
});
