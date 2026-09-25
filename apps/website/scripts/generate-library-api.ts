import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { Application, EntryPointStrategy, normalizePath } from "typedoc";
import { assertLibraryCoverage, publicLibrarySurface } from "./check-library-api";

const root = resolve(import.meta.dir, "../../..");

export async function libraryPackages(repository = root): Promise<string[]> {
  const packages: string[] = [];
  for await (const manifest of new Bun.Glob("packages/*/package.json").scan(repository)) {
    const pkg = JSON.parse(await readFile(resolve(repository, manifest), "utf8"));
    if (!pkg.private && pkg.exports) packages.push(dirname(resolve(repository, manifest)));
  }
  return packages.sort();
}

export async function generateLibraryApi(repository = root, destination = resolve(import.meta.dir, "..")): Promise<void> {
  const directories = await libraryPackages(repository);
  const app = await Application.bootstrap({
    name: "mlx-bun library API", entryPoints: directories,
    entryPointStrategy: EntryPointStrategy.Packages, readme: "none",
    navigationLinks: { Documentation: "/guides/library/" },
    packageOptions: {
      readme: "none", alwaysCreateEntryPointModule: true,
      excludeReferences: false, excludeInternal: false,
      gitRevision: "refactor/monorepo",
      disableGit: true, basePath: repository, displayBasePath: repository,
      sourceLinkTemplate: "https://github.com/joshuarossi/mlx-bun/blob/{gitRevision}/{path}#L{line}",
    },
  });
  const project = await app.convert();
  if (!project || app.logger.hasErrors()) throw new Error("Library API conversion failed");
  const expected = await publicLibrarySurface(directories);
  // TypeDoc unwraps a single package. Keep its public package name in that case.
  if (expected.length === 1) project.name = expected[0]!.name;
  const packages = expected.length === 1 ? [project] : project.children ?? [];
  // Use import specifiers as module names, including the package root.
  for (const pkg of packages) for (const module of pkg.children ?? [])
    module.name = pkg.name + (module.name ? `/${module.name}` : "");
  const symbols = assertLibraryCoverage(app.serializer.projectToObject(project, normalizePath(repository)), expected);
  await app.generateDocs(project, resolve(destination, "public/api"));
  await app.generateJson(project, resolve(destination, ".astro/library-api.json"));
  console.log(`Verified ${expected.length} library packages and ${symbols} exported symbols across ${expected.reduce((n, pkg) => n + pkg.modules.size, 0)} public entry points.`);
}

if (import.meta.main) {
  if (process.argv.includes("--help")) console.log("Usage: bun scripts/generate-library-api.ts\nGenerate public library API from package manifests, signatures, and JSDoc without loading native libraries.");
  else await generateLibraryApi();
}
