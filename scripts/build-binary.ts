import { copyFile, mkdir, readdir, readFile, stat } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { NATIVE_DIR as MLX_DIR, NATIVE_FILES as MLX_FILES } from "../packages/mlx/src/native";
import { NATIVE_DIR as INFERENCE_DIR, NATIVE_FILES as INFERENCE_FILES } from "../packages/inference/src/runtime/native";
import { buildWebBundle, OUTFILE } from "../apps/mlx-bun/src/web/build";
import { BUNDLE_FILES } from "./bundle-files";

import { MIC_CAPTURE_STAGED, MIC_CAPTURE_BINARY } from "../apps/mlx-bun/src/engine/mic-capture";

const root = resolve(import.meta.dir, "..");
const app = join(root, "apps/mlx-bun");

/** Both the real executable and the verification consumer use this asset list.
 * Bun preserves each asset directory's basename below /$bunfs/root/. The
 * generated JS is embedded as /$bunfs/root/app.js, which web/assets.ts selects
 * only in standalone execution; source checkouts retain dist/web fallback. */
export async function compileApp(entry: string, output: string): Promise<void> {
  const proc = Bun.spawn([process.execPath, "build", "--compile", entry, "--outfile", output,
    "--asset", join(app, "src/web/public"), "--asset", OUTFILE,
    "--asset", join(app, "src/memory/skills"),
    "--no-compile-autoload-dotenv", "--no-compile-autoload-bunfig"],
    { cwd: root, stdout: "inherit", stderr: "inherit" });
  if (await proc.exited !== 0) throw new Error("Standalone compilation failed");
}

/** Installed package directories: Pi is compiled into the executable and
 * Photon (Pi's image dependency) supplies the WASM sidecar. */
function installedDependencies(base: string) {
  const from = join(base, "apps/mlx-bun"), pi = Bun.resolveSync("@earendil-works/pi-coding-agent", from);
  return { pi: dirname(Bun.resolveSync("@earendil-works/pi-coding-agent/package.json", from)),
    photon: dirname(Bun.resolveSync("@silvia-odwyer/photon-node", dirname(pi))) };
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

/** Ordered sections of the bundle's THIRD_PARTY_NOTICES.md, verbatim from the
 * workspace and installed packages. Pi 0.80.3's npm package ships no license
 * file, so its section states the license its manifest declares. */
export async function bundleNotices(base = root): Promise<string[]> {
  const { pi, photon } = installedDependencies(base);
  const [piPackage, photonPackage] = await Promise.all([installedManifest(pi), installedManifest(photon)]);
  const piLicense = (await readdir(pi)).find(name => /^licen[cs]e(\.md|\.txt)?$/i.test(name));
  return [
    ...await Promise.all(["mlx", "inference"].map(async name =>
      `# @mlx-bun/${name}\n\n${await noticeText(join(base, "packages", name, "THIRD_PARTY_NOTICES.md"))}`)),
    `# ${photonPackage.name}@${photonPackage.version}\n\nCovers the bundled \`photon_rs_bg.wasm\`. License: ${photonPackage.license}.\n\n${await noticeText(join(photon, "LICENSE.md"))}`,
    `# ${piPackage.name}@${piPackage.version}\n\nCompiled into the \`mlx-bun\` executable. License: ${piPackage.license}` + (piLicense
      ? `.\n\n${await noticeText(join(pi, piLicense))}`
      : " (declared in the installed package.json; the package ships no license file).\n"),
  ];
}

/** Uses already staged package natives; does not download, sign for release,
 * publish, start a server, or load MLX. The complete directory is relocatable. */
export async function buildBinary(output = join(root, "dist/bundle")): Promise<string> {
  const out = resolve(output);
  const photon = join(installedDependencies(root).photon, "photon_rs_bg.wasm");
  const copies: [string, string][] = [
    ...MLX_FILES.map(name => [join(MLX_DIR, name), name] as [string, string]),
    ...INFERENCE_FILES.map(name => [join(INFERENCE_DIR, name), name] as [string, string]),
    [MIC_CAPTURE_STAGED, MIC_CAPTURE_BINARY],
    [photon, "photon_rs_bg.wasm"], [join(root, "LICENSE"), "LICENSE"],
  ];
  const notices = await bundleNotices();
  for (const [source] of copies) {
    const info = await stat(source).catch(() => null);
    if (!info?.isFile() || !info.size) throw new Error(`Missing bundle input: ${source}. Stage package native files first.`);
  }
  await mkdir(out, { recursive: true });
  await mkdir(dirname(OUTFILE), { recursive: true });
  await Bun.write(OUTFILE, await buildWebBundle());
  const executable = join(out, "mlx-bun");
  await compileApp(join(app, "src/cli/main.ts"), executable);
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
