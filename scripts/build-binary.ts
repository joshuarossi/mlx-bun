import { copyFile, mkdir, readFile, stat } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { NATIVE_DIR as MLX_DIR, NATIVE_FILES as MLX_FILES } from "../packages/mlx/src/native";
import { NATIVE_DIR as INFERENCE_DIR, NATIVE_FILES as INFERENCE_FILES } from "../packages/inference/src/runtime/native";
import { buildWebBundle, OUTFILE } from "../apps/mlx-bun/src/web/build";
import { BUNDLE_FILES } from "./bundle-files";

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

/** Uses already staged package natives; does not download, sign for release,
 * publish, start a server, or load MLX. The complete directory is relocatable. */
export async function buildBinary(output = join(root, "dist/bundle")): Promise<string> {
  const out = resolve(output);
  const pi = Bun.resolveSync("@earendil-works/pi-coding-agent", app);
  const photon = join(dirname(Bun.resolveSync("@silvia-odwyer/photon-node", dirname(pi))), "photon_rs_bg.wasm");
  const copies: [string, string][] = [
    ...MLX_FILES.map(name => [join(MLX_DIR, name), name] as [string, string]),
    ...INFERENCE_FILES.map(name => [join(INFERENCE_DIR, name), name] as [string, string]),
    [photon, "photon_rs_bg.wasm"], [join(root, "LICENSE"), "LICENSE"],
  ];
  const notices = await Promise.all(["mlx", "inference"].map(async name => {
    const source = join(root, "packages", name, "THIRD_PARTY_NOTICES.md");
    const text = await readFile(source, "utf8");
    if (!text.trim()) throw new Error(`Empty bundle notice: ${source}`);
    return `# @mlx-bun/${name}\n\n${text}`;
  }));
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
