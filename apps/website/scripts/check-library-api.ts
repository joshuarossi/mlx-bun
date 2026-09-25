import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import ts from "typescript";
import type { JSONOutput } from "typedoc";

export interface PackageSurface { name: string; modules: Map<string, string[]> }

/** Independent coverage oracle: ask TypeScript what each manifest entry exports,
 * including star exports and aliases. This never evaluates library code. */
export async function publicLibrarySurface(directories: string[]): Promise<PackageSurface[]> {
  const result: PackageSurface[] = [];
  for (const directory of directories) {
    const pkg = JSON.parse(await readFile(resolve(directory, "package.json"), "utf8"));
    const entries = Object.entries(pkg.exports as Record<string, unknown>);
    for (const [subpath, target] of entries)
      if (!(subpath === "." || subpath.startsWith("./")) || subpath.includes("*") ||
          typeof target !== "string" || !target.endsWith(".ts"))
        throw new Error(`${pkg.name}: unsupported export ${subpath}; update API coverage before publishing`);
    const config = ts.readConfigFile(resolve(directory, "tsconfig.json"), ts.sys.readFile);
    if (config.error) throw new Error(ts.flattenDiagnosticMessageText(config.error.messageText, "\n"));
    const parsed = ts.parseJsonConfigFileContent(config.config, ts.sys, directory);
    if (parsed.errors.length) throw new Error(ts.formatDiagnosticsWithColorAndContext(parsed.errors, {
      getCanonicalFileName: name => name, getCurrentDirectory: () => directory, getNewLine: () => "\n",
    }));
    const program = ts.createProgram(entries.map(([, target]) => resolve(directory, target as string)), parsed.options);
    const checker = program.getTypeChecker(), modules = new Map<string, string[]>();
    for (const [subpath, target] of entries) {
      const source = program.getSourceFile(resolve(directory, target as string));
      const symbol = source && checker.getSymbolAtLocation(source);
      if (!symbol) throw new Error(`${pkg.name}${subpath.slice(1)}: export module cannot be resolved`);
      modules.set(pkg.name + subpath.slice(1), checker.getExportsOfModule(symbol).map(item => item.name).sort());
    }
    result.push({ name: pkg.name, modules });
  }
  return result;
}

/** Check serialized output, not just the input list handed to the generator. */
export function assertLibraryCoverage(project: JSONOutput.ProjectReflection, expected: PackageSurface[], revision: string): number {
  const declarations = new Map<number, JSONOutput.DeclarationReflection | JSONOutput.ReferenceReflection>();
  function visit(node: JSONOutput.ContainerReflection) {
    for (const child of node.children ?? []) { declarations.set(child.id, child); visit(child); }
  }
  visit(project);
  let count = 0;
  const same = (actual: string[], wanted: string[], label: string) => {
    if (JSON.stringify(actual.sort()) !== JSON.stringify([...wanted].sort()))
      throw new Error(`${label}: incomplete API coverage; missing ${wanted.filter(name => !actual.includes(name)).join(", ")}; unexpected ${actual.filter(name => !wanted.includes(name)).join(", ")}`);
  };
  const packages = expected.length === 1 && project.name === expected[0]!.name ? [project] : project.children ?? [];
  same(packages.map(item => item.name), expected.map(item => item.name), "Library packages");
  for (const pkg of expected) {
    const actual = packages.find(item => item.name === pkg.name)!;
    same((actual.children ?? []).map(item => item.name), [...pkg.modules.keys()], pkg.name);
    for (const [name, symbols] of pkg.modules) {
      const module = actual.children!.find(item => item.name === name)!;
      same((module.children ?? []).map(item => item.name), symbols, name);
      for (const exported of module.children ?? []) {
        let target = exported;
        const visited = new Set<number>();
        while ("target" in target) {
          if (visited.has(target.id)) throw new Error(`${name}.${exported.name}: cyclic API reference`);
          visited.add(target.id);
          const resolved = declarations.get(target.target);
          if (!resolved) throw new Error(`${name}.${exported.name}: unresolved API re-export`);
          target = resolved;
        }
        const sources = [...(target.sources ?? []), ...(target.signatures ?? []).flatMap(item => item.sources ?? [])];
        if (!sources.some(source => source.url === `https://github.com/joshuarossi/mlx-bun/blob/${revision}/${source.fileName}#L${source.line}`))
          throw new Error(`${name}.${exported.name}: missing API source link`);
      }
      count += symbols.length;
    }
  }
  return count;
}
