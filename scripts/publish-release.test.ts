import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { BUNDLE_FILES } from "./bundle-files";
import type { Preparation, Run } from "./prepare-release";
import { publicationInputs, publishRelease } from "./publish-release";

const hash = (bytes: Uint8Array | string) => createHash("sha256").update(bytes).digest("hex");
async function fixture() {
  const root = await mkdtemp(join(tmpdir(), "mlx-publish-test-"));
  const version = "0.6.0", head = "a".repeat(40), notes = join(root, "notes.md");
  for (const dir of ["bundle", "npm", "release"]) await mkdir(join(root, dir));
  const state: Preparation = { version, sourceHead: head, stage: "accepted", notarization: { id: "accepted", status: "Accepted", zipSha256: head },
    files: {}, packages: [], publication: { order: ["@mlx-bun/mlx", "mlx-bun"], pending: [] }, releaseFiles: {} };
  for (const name of BUNDLE_FILES) { await writeFile(join(root, "bundle", name), name); state.files[name] = hash(name); }
  const archive = "accepted archive", digest = hash(archive), formula = `version "${version}"\nsha256 "${digest}"\n`;
  for (const name of [`mlx-bun-v${version}-arm64.tar.gz`, "mlx-bun-arm64.tar.gz"]) {
    await writeFile(join(root, "release", name), archive); state.releaseFiles![name] = digest;
    const sidecar = `${digest}  ${name}\n`; await writeFile(join(root, "release", `${name}.sha256`), sidecar); state.releaseFiles![`${name}.sha256`] = hash(sidecar);
  }
  await writeFile(join(root, "release/mlx-bun.rb"), formula); state.releaseFiles!["mlx-bun.rb"] = hash(formula);
  for (const name of state.publication.order) {
    const bytes = `packed ${name}`, archive = `${name.replace(/^@/, "").replaceAll("/", "-")}.tgz`;
    await writeFile(join(root, "npm", archive), bytes);
    state.packages.push({ name, version, archive, sha256: hash(bytes), integrity: "sha512-" + createHash("sha512").update(bytes).digest("base64") });
  }
  await writeFile(notes, "Release notes\n");
  const save = () => writeFile(join(root, "preparation.json"), JSON.stringify(state));
  await save();
  const commands: string[][] = [], registry = new Map<string, string>(); let draft = true, tapContent: string | undefined;
  const execute: Run = async command => {
    commands.push(command);
    if (command[0] === "git") {
      if (command[1] === "branch") return "main\n";
      if (command[1] === "rev-parse") return `${head}\n`;
      return "";
    }
    if (command[0] === "npm") {
      if (command[1] === "view") { const value = registry.get(command[2]!); if (!value) throw Error("E404"); return JSON.stringify(value); }
      if (command[1] === "publish") { const pkg = state.packages.find(pkg => command[2]!.endsWith(pkg.archive))!; registry.set(`${pkg.name}@${version}`, pkg.integrity); }
      return "test-user";
    }
    if (command[0] === "gh") {
      if (command[1] === "auth") return "";
      if (command[1] === "release") {
        if (command[2] === "view") return JSON.stringify({ isDraft: draft, tagName: `v${version}`, assets: Object.keys(state.releaseFiles!).map(name => ({ name })) });
        if (command[2] === "edit") draft = false;
        return "";
      }
      if (command.includes("PUT")) { const body = JSON.parse(await readFile(command.at(-1)!, "utf8")); tapContent = body.content; return "{}"; }
      if (command.at(-1)!.includes("git/ref")) return JSON.stringify({ object: { type: "commit", sha: head } });
      if (!tapContent) throw Error("HTTP 404");
      return JSON.stringify({ content: tapContent, sha: "tap-commit" });
    }
    throw Error(`Unexpected command: ${command}`);
  };
  return { root, state, notes, save, commands, execute, registry, close: () => rm(root, { recursive: true, force: true }) };
}

test("accepted publication validates bytes, publishes dependencies first, and reads back npm/release/tap", async () => {
  const f = await fixture();
  try {
    await publicationInputs(f.root, f.notes); expect(f.commands).toEqual([]);
    expect(await publishRelease(f.root, f.notes, f.execute, f.root)).toEndWith("/v0.6.0");
    const published = f.commands.filter(command => command[0] === "npm" && command[1] === "publish");
    expect(published.map(command => command[2]!.split("/").at(-1))).toEqual(["mlx-bun-mlx.tgz", "mlx-bun.tgz"]);
    expect(f.commands.findIndex(command => command[2] === "edit")).toBeLessThan(f.commands.findIndex(command => command.includes("PUT")));
    await expect(publishRelease(f.root, f.notes, f.execute, f.root)).rejects.toThrow("already public");
  } finally { await f.close(); }
});

test("modified package, rejected notarization and unselected versions stop before external commands", async () => {
  const f = await fixture();
  try {
    f.state.stage = "unsigned"; await f.save(); await expect(publishRelease(f.root, f.notes, f.execute)).rejects.toThrow("Accepted notarization");
    f.state.stage = "accepted"; f.state.publication.pending = ["provisional"]; await f.save(); await expect(publishRelease(f.root, f.notes, f.execute)).rejects.toThrow("publication decisions");
    f.state.publication.pending = []; await f.save(); await writeFile(join(f.root, "npm", f.state.packages[0]!.archive), "changed");
    await expect(publishRelease(f.root, f.notes, f.execute)).rejects.toThrow("Package archive changed"); expect(f.commands).toEqual([]);
  } finally { await f.close(); }
});

test("an existing different npm version is never overwritten", async () => {
  const f = await fixture();
  try {
    f.registry.set("@mlx-bun/mlx@0.6.0", "different-integrity");
    await expect(publishRelease(f.root, f.notes, f.execute, f.root)).rejects.toThrow("Published package differs");
    expect(f.commands.some(command => command[0] === "npm" && command[1] === "publish")).toBe(false);
    expect(f.commands.some(command => command[2] === "edit" || command.includes("PUT"))).toBe(false);
  } finally { await f.close(); }
});
