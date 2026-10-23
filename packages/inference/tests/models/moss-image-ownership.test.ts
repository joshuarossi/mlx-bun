// MOSS-Image composes its own layers from kernels and its graphs from those
// layers: its directory imports no other family's modules and no shared
// `layers/` implementation, the kernel it added is bound by exactly one layer,
// and its graph files (DiT, conditioner, VAE decoder) hold no numerics of their
// own: every operation they run belongs to a layer they arrange. A family test,
// not a repository-wide ban: other families keep their own composition.
import { expect, test } from "bun:test";
import { readdirSync, readFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import ts from "typescript";

const source = resolve(import.meta.dir, "../../src");
const family = join(source, "models/moss-image");
const GRAPH_FILES = ["transformer.ts", "text-encoder.ts", "vae.ts"];

/** Every runtime and type import specifier of `file`, resolved relative to `src/` when relative. */
function imports(file: string): string[] {
  const text = readFileSync(file, "utf8");
  const parsed = ts.createSourceFile(file, text, ts.ScriptTarget.Latest, true);
  const out: string[] = [];
  const visit = (node: ts.Node) => {
    if ((ts.isImportDeclaration(node) || ts.isExportDeclaration(node)) && node.moduleSpecifier && ts.isStringLiteral(node.moduleSpecifier)) {
      const specifier = node.moduleSpecifier.text;
      out.push(specifier.startsWith(".") ? relative(source, resolve(dirname(file), specifier)) : specifier);
    }
    ts.forEachChild(node, visit);
  };
  visit(parsed);
  return out;
}

const familyFiles = () => readdirSync(family).filter(name => name.endsWith(".ts")).map(name => join(family, name));

test("the family imports no other family's modules and no shared layer implementation", () => {
  const foreign: string[] = [];
  for (const file of familyFiles())
    for (const target of imports(file))
      if ((target.startsWith("models/") && !target.startsWith("models/moss-image/") && target !== "models/family") || target.startsWith("layers/"))
        foreign.push(`${relative(source, file)} -> ${target}`);
  expect(foreign).toEqual([]);
});

test("the SITU kernel is bound by exactly one layer", () => {
  const binders: string[] = [];
  const walk = (dir: string) => {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      const path = join(dir, entry.name);
      if (entry.isDirectory()) walk(path);
      else if (entry.name.endsWith(".ts") && imports(path).includes("kernels/situ")) binders.push(relative(source, path));
    }
  };
  walk(source);
  expect(binders).toEqual(["models/moss-image/layers.ts"]);
});

test("the graph files arrange layers and run no operations of their own", () => {
  const numeric = GRAPH_FILES.flatMap(name => imports(join(family, name))
    .filter(target => target === "@mlx-bun/mlx/ops" || target.startsWith("kernels/"))
    .map(target => `${name} -> ${target}`));
  expect(numeric).toEqual([]);
});
