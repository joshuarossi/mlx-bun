import { copyFile, mkdir, mkdtemp, readFile, rm, stat } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { NATIVE_DIR as MLX_DIR, NATIVE_FILES as MLX_FILES } from "@mlx-bun/mlx/native";
import { NATIVE_DIR as INFERENCE_DIR, NATIVE_FILES as INFERENCE_FILES } from "../packages/inference/src/runtime/native";
import { buildWeb, OUTFILE } from "../apps/mlx-bun/src/web/build";
import { BUNDLE_FILES } from "./bundle-files";
import { checkCurated, packageNotices, retainedInputs, retainedPackages } from "./bundle-notices";

import { MIC_CAPTURE_STAGED, MIC_CAPTURE_BINARY } from "../packages/module-transcription/src/mic-capture";

const root = resolve(import.meta.dir, "..");
const app = join(root, "apps/mlx-bun");

/** Both the real executable and the verification consumer use this asset list.
 * Bun preserves each asset directory's basename below /$bunfs/root/. The
 * generated JS is embedded as /$bunfs/root/app.js, which web/assets.ts selects
 * only in standalone execution; source checkouts retain dist/web fallback. */
export async function compileApp(entry: string, output: string, metafile?: string): Promise<void> {
  const proc = Bun.spawn([process.execPath, "build", "--compile", entry, "--outfile", output,
    "--asset", join(app, "src/web/public"), "--asset", OUTFILE,
    "--asset", join(root, "packages/module-memory/src/skills"),
    "--no-compile-autoload-dotenv", "--no-compile-autoload-bunfig",
    ...metafile ? [`--metafile=${metafile}`] : []],
    { cwd: root, stdout: "inherit", stderr: "inherit" });
  if (await proc.exited !== 0) throw new Error("Standalone compilation failed");
}

/** The real build: the embedded browser bundle, then the executable. Returns
 * every input file either build's metafile records as contributing bytes. */
export async function compileBundle(executable: string): Promise<string[]> {
  const web = await buildWeb();
  await mkdir(dirname(OUTFILE), { recursive: true });
  await Bun.write(OUTFILE, web.text);
  const scratch = await mkdtemp(join(tmpdir(), "mlx-bun-metafile-"));
  try {
    const metafile = join(scratch, "metafile.json");
    await compileApp(join(app, "src/cli/main.ts"), executable, metafile);
    return [...retainedInputs(web.metafile, process.cwd()), ...retainedInputs(JSON.parse(await readFile(metafile, "utf8")), root)];
  } finally { await rm(scratch, { recursive: true, force: true }); }
}

/** The installed Photon package (Pi's image dependency) supplies the WASM sidecar. */
function photonDirectory(base: string) {
  const pi = Bun.resolveSync("@earendil-works/pi-coding-agent", join(base, "apps/mlx-bun"));
  return dirname(Bun.resolveSync("@silvia-odwyer/photon-node", dirname(pi)));
}

async function noticeText(path: string): Promise<string> {
  const text = await readFile(path, "utf8").catch(() => "");
  if (!text.trim()) throw new Error(`Missing or empty bundle notice: ${path}`);
  return text;
}

async function installedManifest(directory: string): Promise<{ name: string; version: string; license: string }> {
  const manifest = JSON.parse(await noticeText(join(directory, "package.json")));
  if (!manifest.name || !manifest.version || !manifest.license) throw new Error(`Missing name, version or license: ${directory}/package.json`);
  return manifest;
}

/** Ordered sections of the bundle's THIRD_PARTY_NOTICES.md: the package and
 * app notices and Photon's installed license verbatim, then one section per
 * third-party package in `inputs` (the build's retained files). A package that
 * installs no license text needs its exact `name@version` named in one of the
 * package or app notices, as apps/mlx-bun/THIRD_PARTY_NOTICES.md does for Pi.
 * Throws unless those notices carry every CURATED section at its reviewed hash. */
export async function bundleNotices(inputs: string[], base = root): Promise<string[]> {
  const photon = photonDirectory(base);
  const photonPackage = await installedManifest(photon);
  const own: Record<string, string> = {};
  for (const name of ["mlx", "inference"])
    own[`@mlx-bun/${name}`] = await noticeText(join(base, "packages", name, "THIRD_PARTY_NOTICES.md"));
  const appNotice = await noticeText(join(base, "apps/mlx-bun/THIRD_PARTY_NOTICES.md"));
  checkCurated({ "apps/mlx-bun/THIRD_PARTY_NOTICES.md": appNotice, "packages/inference/THIRD_PARTY_NOTICES.md": own["@mlx-bun/inference"]! });
  // Photon's section below already carries its installed license verbatim.
  const packages = (await retainedPackages(inputs)).filter(({ id }) => id !== `${photonPackage.name}@${photonPackage.version}`);
  return [
    ...Object.entries(own).map(([title, text]) => `# ${title}\n\n${text}`),
    `# ${photonPackage.name}@${photonPackage.version}\n\nCovers the bundled \`photon_rs_bg.wasm\`. License: ${photonPackage.license}.\n\n${await noticeText(join(photon, "LICENSE.md"))}`,
    `# mlx-bun\n\n${appNotice}`,
    ...await packageNotices(packages, { ...own, "mlx-bun": appNotice }),
  ];
}

/** Uses already staged package natives; does not download, sign for release,
 * publish, start a server, or load MLX. The complete directory is relocatable. */
export async function buildBinary(output = join(root, "dist/bundle")): Promise<string> {
  const out = resolve(output);
  const photon = join(photonDirectory(root), "photon_rs_bg.wasm");
  const copies: [string, string][] = [
    ...MLX_FILES.map(name => [join(MLX_DIR, name), name] as [string, string]),
    ...INFERENCE_FILES.map(name => [join(INFERENCE_DIR, name), name] as [string, string]),
    [MIC_CAPTURE_STAGED, MIC_CAPTURE_BINARY],
    [photon, "photon_rs_bg.wasm"], [join(root, "LICENSE"), "LICENSE"],
  ];
  for (const [source] of copies) {
    const info = await stat(source).catch(() => null);
    if (!info?.isFile() || !info.size) throw new Error(`Missing bundle input: ${source}. Stage package native files first.`);
  }
  await mkdir(out, { recursive: true });
  const executable = join(out, "mlx-bun");
  const notices = await bundleNotices(await compileBundle(executable));
  for (const [source, name] of copies) await copyFile(source, join(out, name));
  await Bun.write(join(out, "THIRD_PARTY_NOTICES.md"), notices.join("\n\n---\n\n"));
  for (const file of BUNDLE_FILES) {
    if (!(await stat(join(out, file))).size) throw new Error(`Empty bundle asset: ${file}`);
  }
  return executable;
}

if (import.meta.main) {
  if (process.argv.includes("--help")) console.log("Usage: bun scripts/build-binary.ts [output-directory]\nBuild a relocatable Apple Silicon app from staged natives; defaults to dist/bundle.");
  else console.log(`Bundle ready: ${await buildBinary(process.argv[2])}`);
}
