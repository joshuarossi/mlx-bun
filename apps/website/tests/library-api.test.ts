import { expect, test } from "bun:test";
import { mkdtemp, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import type { JSONOutput } from "typedoc";
import { assertLibraryCoverage, publicLibrarySurface } from "../scripts/check-library-api";
import { generateLibraryApi, libraryPackages, sourceRevision } from "../scripts/generate-library-api";

test("API generation resolves public aliases, star exports, overloads, generics and ownership comments without executing code", async () => {
  const repository = await mkdtemp(resolve(tmpdir(), "mlx-library-docs-"));
  const revision = "1234567890123456789012345678901234567890";
  const directory = resolve(repository, "packages/example"), destination = resolve(repository, "site");
  try {
    await mkdir(directory, { recursive: true });
    await writeFile(resolve(directory, "package.json"), JSON.stringify({ name: "@mlx-bun/example", version: "0.0.0", exports: { ".": "./index.ts", "./secondary": "./secondary.ts" } }));
    await writeFile(resolve(directory, "tsconfig.json"), JSON.stringify({ compilerOptions: { target: "ESNext", module: "Preserve", moduleResolution: "bundler", strict: true, types: [], noEmit: true }, include: ["*.ts"] }));
    await writeFile(resolve(directory, "index.ts"), 'export * from "./implementation"; export { Owned as Renamed } from "./implementation";');
    await writeFile(resolve(directory, "secondary.ts"), 'export { overloaded as renamedFunction } from "./implementation"; export type { Choice } from "./implementation";');
    await writeFile(resolve(directory, "implementation.ts"), `
throw new Error("Documentation must never execute library code");
/** Caller owns this value and must call dispose. */
export class Owned<T> {
  constructor(public value: T) {}
  /** Release owned resources. */
  dispose(): void {}
}
/** Preserve the caller's selection. */
export type Choice<T> = { selected: T };
/** Return a borrowed value; do not dispose it here. */
export function overloaded(value: string): string;
export function overloaded(value: number): number;
export function overloaded(value: string | number): string | number { return value; }
/** @internal Still publicly exported, so it must remain discoverable. */
export const visibleInternal = 1;
`);
    await generateLibraryApi(repository, destination, revision);
    const project: JSONOutput.ProjectReflection = JSON.parse(await readFile(resolve(destination, ".astro/library-api.json"), "utf8"));
    const expected = await publicLibrarySurface(await libraryPackages(repository));
    expect(expected[0]!.modules.get("@mlx-bun/example")).toEqual(["Choice", "Owned", "Renamed", "overloaded", "visibleInternal"]);
    expect(assertLibraryCoverage(project, expected, revision)).toBe(7);
    const reflections = project.children!.flatMap(module => module.children!);
    const owned = reflections.find(item => item.name === "Owned")!;
    expect(owned.typeParameters?.[0]?.name).toBe("T");
    expect(owned.comment?.summary.map(part => part.text).join("")).toContain("must call dispose");
    expect(owned.children?.some(item => item.name === "dispose")).toBe(true);
    expect(reflections.find(item => item.name === "overloaded")!.signatures).toHaveLength(2);
    const html: string[] = [];
    for await (const file of new Bun.Glob("**/*.html").scan(resolve(destination, "public/api")))
      html.push(await readFile(resolve(destination, "public/api", file), "utf8"));
    expect(html.join("\n")).toContain("Return a borrowed value; do not dispose it here.");
    expect(html.some(page => page.includes(`https://github.com/joshuarossi/mlx-bun/blob/${revision}/packages/example/implementation.ts#L`))).toBe(true);

    const missingModule = structuredClone(project);
    missingModule.children!.pop();
    expect(() => assertLibraryCoverage(missingModule, expected, revision)).toThrow("incomplete API coverage");
    const missingSymbol = structuredClone(project);
    missingSymbol.children![0]!.children!.pop();
    expect(() => assertLibraryCoverage(missingSymbol, expected, revision)).toThrow("incomplete API coverage");
    const brokenAlias = structuredClone(project);
    const reference = brokenAlias.children!.flatMap(module => module.children!).find(item => item.variant === "reference")!;
    if ("target" in reference) reference.target = -1 as JSONOutput.ReflectionId;
    expect(() => assertLibraryCoverage(brokenAlias, expected, revision)).toThrow("unresolved API re-export");
  } finally { await rm(repository, { recursive: true, force: true }); }
}, 30_000);


test("API source links use a valid CI SHA or local commit and only unpacked trees use a branch", async () => {
  const repository = resolve(import.meta.dir, "../../..");
  const head = Bun.spawnSync(["git", "-C", repository, "rev-parse", "HEAD"]);
  expect(head.exitCode).toBe(0);
  const revision = "1234567890123456789012345678901234567890";
  expect(sourceRevision(repository, revision)).toBe(revision);
  expect(sourceRevision(repository, "invalid-sha")).toBe(head.stdout.toString().trim());
  expect(sourceRevision(repository, "")).toBe(head.stdout.toString().trim());
  const unpacked = await mkdtemp(resolve(tmpdir(), "mlx-api-source-"));
  try {
    expect(sourceRevision(unpacked, "")).toBe("refactor/monorepo");
    expect(Bun.spawnSync(["git", "init", "--quiet", unpacked]).exitCode).toBe(0);
    expect(() => sourceRevision(unpacked, "")).toThrow("Cannot resolve the documentation source commit");
  } finally { await rm(unpacked, { recursive: true, force: true }); }
});
