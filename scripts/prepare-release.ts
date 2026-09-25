import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { copyFile, lstat, mkdir, readFile, readdir, rm, writeFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { buildBinary } from "./build-binary";
import { BUNDLE_FILES } from "./bundle-files";
import { prepareHomebrew } from "./prepare-homebrew";

const workspace = resolve(import.meta.dir, "..");
export type Run = (command: string[], cwd?: string) => Promise<string>;
const run: Run = async (command, cwd = workspace) => {
  const child = Bun.spawn(command, { cwd, stdin: "ignore", stdout: "pipe", stderr: "pipe",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/release-version-check" } });
  const [out, err, code] = await Promise.all([
    new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited,
  ]);
  if (code !== 0) throw new Error(`${command[0]} exited ${code}: ${out}\n${err}`);
  return out;
};
const sha = (data: Uint8Array) => createHash("sha256").update(data).digest("hex");

interface Manifest { name: string; version: string; private?: boolean; dependencies?: Record<string, string> }
export function publicationPlan(manifests: Manifest[]) {
  const byName = new Map(manifests.map(manifest => [manifest.name, manifest]));
  assert.equal(byName.size, manifests.length, "Duplicate package names");
  const order: string[] = [], visiting = new Set<string>();
  function visit(manifest: Manifest) {
    if (order.includes(manifest.name)) return;
    assert(!visiting.has(manifest.name), `Package dependency cycle at ${manifest.name}`);
    visiting.add(manifest.name);
    for (const [name, range] of Object.entries(manifest.dependencies ?? {})) {
      assert(!/^(workspace|file|link):/.test(range), `${manifest.name}: unpackaged dependency ${name}=${range}`);
      const dependency = byName.get(name);
      if (dependency) {
        assert(Bun.semver.satisfies(dependency.version, range), `${manifest.name}: ${name}@${range} excludes ${dependency.version}`);
        visit(dependency);
      } else assert(!name.startsWith("@mlx-bun/"), `Missing package archive: ${name}`);
    }
    visiting.delete(manifest.name); order.push(manifest.name);
  }
  for (const manifest of manifests) visit(manifest);
  return { order, pending: manifests.flatMap(manifest => [
    ...(manifest.private ? [`${manifest.name} is private; publication decision required`] : []),
    ...(manifest.version === "0.0.0" ? [`${manifest.name} uses provisional version 0.0.0`] : []),
  ]) };
}

interface Preparation {
  version: string;
  stage: "unsigned" | "signed" | "accepted";
  files: Record<string, string>;
  publication: ReturnType<typeof publicationPlan>;
  notarization?: { id: string; status: "Accepted"; zipSha256: string };
}
async function bundleFiles(directory: string): Promise<Record<string, string>> {
  const files: Record<string, string> = {};
  for (const name of (await readdir(directory)).sort()) {
    assert(/^[A-Za-z0-9][A-Za-z0-9._-]*$/.test(name), `Unsupported bundle path: ${name}`);
    const file = join(directory, name), info = await lstat(file);
    assert(info.isFile() && info.size > 0, `Bundle asset must be a nonempty regular file: ${name}`);
    files[name] = sha(await readFile(file));
  }
  for (const name of BUNDLE_FILES) assert(files[name], `Missing bundle asset: ${name}`);
  return files;
}
async function save(directory: string, state: Preparation) {
  await writeFile(join(directory, "preparation.json"), JSON.stringify(state, null, 2) + "\n");
}
async function checked(directory: string): Promise<Preparation> {
  const state: Preparation = JSON.parse(await readFile(join(directory, "preparation.json"), "utf8"));
  assert.deepEqual(await bundleFiles(join(directory, "bundle")), state.files, "Bundle changed since the previous stage; prepare again");
  return state;
}
async function versionCheck(directory: string, version: string, execute: Run) {
  assert.equal(await execute([join(directory, "mlx-bun"), "--version"]), `mlx-bun ${version}\n`, "Binary version differs from app manifest/archive version");
}
async function archiveBundle(directory: string, version: string, output: string, execute: Run, expected: Record<string, string>) {
  await versionCheck(directory, version, execute);
  assert.deepEqual(await bundleFiles(directory), expected, "Bundle changed before archiving");
  const files = Object.keys(expected);
  await mkdir(output);
  try {
    const versioned = `mlx-bun-v${version}-arm64.tar.gz`, stable = "mlx-bun-arm64.tar.gz";
    await execute(["tar", "-czf", join(output, versioned), "-C", directory, ...files]);
    assert.deepEqual(await bundleFiles(directory), expected, "Bundle changed during archiving");
    await copyFile(join(output, versioned), join(output, stable));
    const checksum = sha(await readFile(join(output, versioned)));
    for (const name of [versioned, stable]) await writeFile(join(output, `${name}.sha256`), `${checksum}  ${name}\n`);
    await prepareHomebrew(join(output, versioned));
  } catch (error) { await rm(output, { recursive: true, force: true }); throw error; }
}

/** Build and inspect unsigned local artifacts. Does not access signing identities,
 * notarize, publish packages/releases, or update the Homebrew tap. */
export async function prepareRelease(directory: string, root = workspace, execute: Run = run,
  build: (output: string) => Promise<string> = buildBinary) {
  const app = JSON.parse(await readFile(join(root, "apps/mlx-bun/package.json"), "utf8"));
  assert(/^\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?(?:\+[A-Za-z0-9.-]+)?$/.test(app.version), "Invalid app version");
  await mkdir(dirname(directory), { recursive: true });
  await mkdir(directory); // Refuse existing outputs instead of mixing release inputs.
  const bundle = join(directory, "bundle"); await build(bundle);
  await versionCheck(bundle, app.version, execute);
  const npm = join(directory, "npm"); await mkdir(npm);
  const manifests: Manifest[] = [];
  for (const path of [...new Bun.Glob("{apps,packages}/*/package.json").scanSync(root)].sort()) {
    const manifest = JSON.parse(await readFile(join(root, path), "utf8"));
    if (manifest.private && !manifest.bin) continue;
    const archive = join(npm, `${manifest.name.replace(/^@/, "").replaceAll("/", "-")}.tgz`);
    await execute([process.execPath, "pm", "pack", "--filename", archive, "--quiet"], resolve(root, path, ".."));
    const packed: Manifest = JSON.parse(await execute(["tar", "-xOf", archive, "package/package.json"]));
    assert.equal(packed.name, manifest.name, "Packed package name changed");
    assert.equal(packed.version, manifest.version, "Packed package version changed");
    manifests.push(packed);
  }
  assert.equal(manifests.find(manifest => manifest.name === app.name)?.version, app.version, "App version changed during preparation");
  const state: Preparation = { version: app.version, stage: "unsigned", files: await bundleFiles(bundle), publication: publicationPlan(manifests) };
  await archiveBundle(bundle, app.version, join(directory, "unsigned"), execute, state.files);
  await save(directory, state);
  return state;
}

/** Explicit Developer ID stage. Every Mach-O helper/dylib precedes the main
 * executable, including newly added helpers without filename special cases. */
export async function signRelease(directory: string, identity: string, execute: Run = run) {
  assert(identity.trim(), "An explicit signing identity is required");
  const state = await checked(directory), bundle = join(directory, "bundle");
  state.stage = "unsigned"; delete state.notarization; await save(directory, state);
  const native: string[] = [];
  for (const name of Object.keys(state.files)) {
    if (name === "mlx-bun") continue;
    if ((await execute(["file", "-b", join(bundle, name)])).includes("Mach-O")) native.push(join(bundle, name));
  }
  for (const file of native) await execute(["codesign", "--force", "--timestamp", "--options", "runtime", "--sign", identity, file]);
  const executable = join(bundle, "mlx-bun");
  await execute(["codesign", "--force", "--timestamp", "--options", "runtime", "--entitlements", join(workspace, "scripts/packaging/entitlements.plist"), "--sign", identity, executable]);
  for (const file of [...native, executable]) await execute(["codesign", "--verify", "--strict", "--verbose=2", file]);
  await versionCheck(bundle, state.version, execute);
  state.files = await bundleFiles(bundle); state.stage = "signed"; await save(directory, state);
}

/** Apple credentials are supplied only by the caller's named notary profile.
 * A successful process exit with Invalid status must never authorize packaging. */
export async function notarizeRelease(directory: string, profile: string, execute: Run = run) {
  assert(profile.trim(), "An explicit notary profile is required");
  const state = await checked(directory);
  assert.equal(state.stage, "signed", "Sign this preparation before notarizing");
  const zip = join(directory, "notarize.zip");
  try {
    await execute(["ditto", "-c", "-k", "--keepParent", join(directory, "bundle"), zip]);
    const zipSha256 = sha(await readFile(zip));
    const result = JSON.parse(await execute(["xcrun", "notarytool", "submit", zip, "--keychain-profile", profile, "--wait", "--output-format", "json"]));
    assert.equal(result.status, "Accepted", `Notarization was not accepted: ${result.status}`);
    assert(typeof result.id === "string" && result.id.length > 0, "Missing notarization submission ID");
    await checked(directory);
    state.notarization = { id: result.id, status: "Accepted", zipSha256 }; state.stage = "accepted";
    await save(directory, state);
  } finally { await rm(zip, { force: true }); }
}

export async function packageRelease(directory: string, execute: Run = run) {
  const state = await checked(directory);
  assert(state.stage === "accepted" && state.notarization?.status === "Accepted", "Accepted notarization is required; unsigned artifacts are local preparation only");
  await archiveBundle(join(directory, "bundle"), state.version, join(directory, "release"), execute, state.files);
}

if (import.meta.main) {
  const [command, path, credential, ...extra] = process.argv.slice(2);
  if (command === "--help") console.log(`Usage: bun scripts/prepare-release.ts <stage> <new-or-existing-directory> [credential]
  prepare   NEW directory: staged native build, package graph, unsigned archives/formula
  sign      prepared directory + explicit Developer ID identity
  notarize  signed directory + explicit notarytool keychain profile
  package   accepted directory: release archives, checksums and Homebrew formula
prepare is local/unsigned. sign accesses the named identity; notarize submits to Apple.
No stage publishes to GitHub/npm, updates the tap, or chooses release versions.
Publication order and pending private/version decisions appear in preparation.json.`);
  else {
    assert(path && !extra.length, "Use --help for usage");
    assert(process.platform === "darwin" && process.arch === "arm64", "Release preparation requires Apple Silicon macOS");
    const directory = resolve(path);
    if (command === "prepare" && !credential) console.log(JSON.stringify(await prepareRelease(directory), null, 2));
    else if (command === "sign" && credential) await signRelease(directory, credential);
    else if (command === "notarize" && credential) await notarizeRelease(directory, credential);
    else if (command === "package" && !credential) await packageRelease(directory);
    else throw new Error("Use --help for usage");
  }
}
