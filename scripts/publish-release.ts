import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { readPreparation, type Run } from "./prepare-release";

const root = resolve(import.meta.dir, "..");
const repo = "joshuarossi/mlx-bun", tap = "joshuarossi/homebrew-tap";
const run: Run = async (command, cwd = root) => {
  const child = Bun.spawn(command, { cwd, stdin: "ignore", stdout: "pipe", stderr: "pipe" });
  const [out, err, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
  if (code) throw new Error(`${command[0]} exited ${code}: ${err}`);
  return out;
};
const sha = (bytes: Uint8Array) => createHash("sha256").update(bytes).digest("hex");

/** Read-only inspection of the exact accepted artifacts to be published. */
export async function publicationInputs(directory: string, notes: string) {
  const state = await readPreparation(directory);
  assert(state.stage === "accepted" && state.notarization?.status === "Accepted", "Accepted notarization is required");
  assert.equal(state.publication.pending.length, 0, "Resolve package publication decisions first");
  assert(/^[a-f0-9]{40}$/.test(state.sourceHead ?? ""), "Preparation must record its source revision");
  assert((await readFile(notes, "utf8")).trim(), "Release notes must be nonempty");
  const names = [`mlx-bun-v${state.version}-arm64.tar.gz`, "mlx-bun-arm64.tar.gz"];
  const expected = [...names, ...names.map(name => `${name}.sha256`), "mlx-bun.rb"].sort();
  assert.deepEqual(Object.keys(state.releaseFiles ?? {}).sort(), expected, "Package the accepted release first");
  for (const name of expected) assert.equal(sha(await readFile(join(directory, "release", name))), state.releaseFiles![name], `Release artifact changed: ${name}`);
  const digest = state.releaseFiles![names[0]!]!;
  assert.equal(state.releaseFiles![names[1]!], digest, "Stable and versioned archives differ");
  for (const name of names) assert.equal(await readFile(join(directory, "release", `${name}.sha256`), "utf8"), `${digest}  ${name}\n`);
  const formula = await readFile(join(directory, "release/mlx-bun.rb"), "utf8");
  assert(formula.includes(`sha256 "${digest}"`) && formula.includes(`version "${state.version}"`) && !formula.includes("UNSIGNED"), "Formula does not describe the accepted archive");
  assert.deepEqual(state.packages.map(pkg => pkg.name).sort(), [...state.publication.order].sort(), "Package publication inventory differs");
  for (const pkg of state.packages) {
    assert.equal(pkg.version, state.version, `Package version differs: ${pkg.name}`);
    assert(/^[A-Za-z0-9._-]+\.tgz$/.test(pkg.archive), "Invalid package archive path");
    const bytes = await readFile(join(directory, "npm", pkg.archive));
    assert.equal(sha(bytes), pkg.sha256, `Package archive changed: ${pkg.name}`);
    assert.equal("sha512-" + createHash("sha512").update(bytes).digest("base64"), pkg.integrity);
  }
  return { state, assets: expected.filter(name => name !== "mlx-bun.rb").map(name => join(directory, "release", name)), formula };
}

async function absentOrJson(execute: Run, command: string[]) {
  try { return JSON.parse(await execute(command)); }
  catch (error) {
    if (/E404|HTTP 404|release not found/i.test(String(error))) return undefined;
    throw error;
  }
}

/** Publish only the prepared clean main revision. Repeats reuse an identical npm
 * version and Git tag; differing bytes/revisions stop instead of overwriting. */
export async function publishRelease(directory: string, notes: string, execute: Run = run, workspace = root) {
  const { state, assets, formula } = await publicationInputs(directory, notes);
  await execute(["git", "fetch", "origin", "main"], workspace);
  assert.equal((await execute(["git", "status", "--porcelain"], workspace)).trim(), "", "Release checkout must be clean");
  assert.equal((await execute(["git", "branch", "--show-current"], workspace)).trim(), "main", "Release checkout must be main");
  for (const revision of ["HEAD", "origin/main"]) assert.equal((await execute(["git", "rev-parse", revision], workspace)).trim(), state.sourceHead, "Prepared source differs from clean origin/main");
  await execute(["npm", "whoami"]); await execute(["gh", "auth", "status"]);
  const tag = `v${state.version}`;
  const existing = await absentOrJson(execute, ["gh", "release", "view", tag, "--repo", repo, "--json", "isDraft,tagName"]);
  assert(!existing || existing.isDraft, "Release is already public; inspect its readback before making further changes");
  if (!existing) await execute(["gh", "release", "create", tag, "--repo", repo, "--target", state.sourceHead!, "--draft", "--title", tag, "--notes-file", notes]);
  const reference = JSON.parse(await execute(["gh", "api", `repos/${repo}/git/ref/tags/${tag}`]));
  const commit = reference.object.type === "tag" ? JSON.parse(await execute(["gh", "api", reference.object.url])).object.sha : reference.object.sha;
  assert.equal(commit, state.sourceHead, "Existing release tag points to another revision");
  await execute(["gh", "release", "upload", tag, ...assets, "--repo", repo, "--clobber"]);
  for (const name of state.publication.order) {
    const pkg = state.packages.find(pkg => pkg.name === name)!;
    const published = await absentOrJson(execute, ["npm", "view", `${name}@${pkg.version}`, "dist.integrity", "--json"]);
    if (published !== undefined) assert.equal(published, pkg.integrity, `Published package differs: ${name}`);
    else await execute(["npm", "publish", join(directory, "npm", pkg.archive), "--access", "public"]);
    assert.equal(JSON.parse(await execute(["npm", "view", `${name}@${pkg.version}`, "dist.integrity", "--json"])), pkg.integrity, `Published package readback differs: ${name}`);
  }
  await execute(["gh", "release", "edit", tag, "--repo", repo, "--draft=false", "--latest", "--notes-file", notes]);
  const path = `repos/${tap}/contents/Formula/mlx-bun.rb`;
  const current = await absentOrJson(execute, ["gh", "api", path]);
  if (!current || Buffer.from(current.content.replaceAll("\n", ""), "base64").toString() !== formula) {
    const scratch = await mkdtemp(join(tmpdir(), "mlx-release-tap-"));
    try {
      const body = join(scratch, "request.json");
      await writeFile(body, JSON.stringify({ message: `mlx-bun ${state.version}`, content: Buffer.from(formula).toString("base64"), ...(current ? { sha: current.sha } : {}) }));
      await execute(["gh", "api", "--method", "PUT", path, "--input", body]);
    } finally { await rm(scratch, { recursive: true, force: true }); }
  }
  const synced = JSON.parse(await execute(["gh", "api", path]));
  assert.equal(Buffer.from(synced.content.replaceAll("\n", ""), "base64").toString(), formula, "Tap readback differs");
  const published = JSON.parse(await execute(["gh", "release", "view", tag, "--repo", repo, "--json", "isDraft,tagName,assets"]));
  assert.equal(published.isDraft, false); assert.equal(published.tagName, tag);
  for (const asset of assets) assert(published.assets.some((item: { name: string }) => item.name === asset.split("/").at(-1)), "Published release asset missing");
  return `https://github.com/${repo}/releases/tag/${tag}`;
}

if (import.meta.main) {
  const [command, directory, notes, ...extra] = process.argv.slice(2);
  if (command === "--help") console.log("Usage: bun scripts/publish-release.ts <inspect|publish> PREPARED_DIRECTORY RELEASE_NOTES\ninspect reads accepted artifacts. publish requires clean main at origin/main, npm/GitHub auth, and publishes the prepared packages, release and Homebrew formula.");
  else {
    assert(directory && notes && !extra.length, "Use --help for usage");
    if (command === "inspect") console.log(JSON.stringify((await publicationInputs(resolve(directory), resolve(notes))).state, null, 2));
    else if (command === "publish") console.log(await publishRelease(resolve(directory), resolve(notes)));
    else throw new Error("Use --help for usage");
  }
}
