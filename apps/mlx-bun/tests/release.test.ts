import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { existsSync } from "node:fs";
import { mkdir, mkdtemp, readFile, readdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, dirname, join, resolve } from "node:path";
import { gitBlobSha1 } from "@mlx-bun/hub/download";
import { bundleNotices } from "../../../scripts/build-binary";
import { checkCurated, CURATED, noticeSection, packageNotices, retainedInputs, retainedPackages, REVIEWED, type Metafile } from "../../../scripts/bundle-notices";
import { BUNDLE_FILES } from "../../../scripts/bundle-files";
import { MIC_CAPTURE_BINARY } from "@mlx-bun/module-transcription/mic-capture";
import { packageRelease, notarizeRelease, prepareRelease, publicationPlan, signRelease, type Run, type Verify } from "../../../scripts/prepare-release";
// Importing the verifier must not build, parse argv, or exit.
import { verifyBundle } from "../../../scripts/verify-binary";

async function fixture() {
  const root = await mkdtemp(join(tmpdir(), "mlx-release-")), output = join(root, "prepared");
  const packages = [
    { name: "mlx-bun", version: "0.0.0", private: true, bin: { "mlx-bun": "bin.mjs" }, dependencies: { "@mlx-bun/mlx": "0.0.0" } },
    { name: "@mlx-bun/mlx", version: "0.0.0" },
  ];
  for (const [index, folder] of ["apps/mlx-bun", "packages/mlx"].entries()) {
    await mkdir(join(root, folder), { recursive: true });
    await writeFile(join(root, folder, "package.json"), JSON.stringify(packages[index]));
  }
  const commands: string[][] = [];
  let status = "Accepted", version = "0.0.0", corruptAfterNotary = false;
  const execute: Run = async (command, cwd) => {
    commands.push(command);
    if (basename(command[0]!) === "mlx-bun") return `mlx-bun ${version}\n`;
    if (command[1] === "pm") { await writeFile(command[4]!, "mock npm archive"); return ""; }
    if (command[0] === "tar" && command[1] === "-xOf")
      return JSON.stringify(command[2]!.includes("mlx-bun-mlx.tgz") ? packages[1] : packages[0]);
    if (command[0] === "file") return /dylib$|frame-extract$|mic-capture$|future-microphone-helper$/.test(command[2]!) ? "Mach-O 64-bit executable arm64" : "data";
    if (command[0] === "codesign") return "";
    if (command[0] === "ditto") { await writeFile(command.at(-1)!, "mock signed zip"); return ""; }
    if (command[0] === "xcrun") {
      if (corruptAfterNotary) await writeFile(join(output, "bundle/libmlx.dylib"), "changed during submission");
      return JSON.stringify({ status, id: "mock-submission" });
    }
    // Only local tar creation runs for real; signing and Apple requests above
    // are captured mocks and cannot access keychains or the network.
    expect(command[0]).toBe("tar");
    const child = Bun.spawn(command, { cwd, stdout: "pipe", stderr: "pipe" });
    const [out, err, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
    if (code !== 0) throw new Error(err);
    return out;
  };
  const notices = ["# @mlx-bun/mlx\n\nfixture mlx notice\n",
    "# @silvia-odwyer/photon-node@0.0.0-fixture\n\nCovers the bundled `photon_rs_bg.wasm`. License: Apache-2.0.\n\nfixture Apache-2.0 text\n",
    "# @earendil-works/pi-coding-agent@0.0.0-fixture\n\nCompiled into the `mlx-bun` executable. License: MIT.\n\nfixture MIT text\n"].join("\n\n---\n\n");
  const build = async (directory: string) => {
    await mkdir(directory);
    for (const name of [...BUNDLE_FILES, "future-microphone-helper"])
      await writeFile(join(directory, name), name === "THIRD_PARTY_NOTICES.md" ? notices : `fixture ${name}`);
    return join(directory, "mlx-bun");
  };
  // Records what the acceptance saw; the real verifier runs in verify:binary.
  const verified: { archive: string; version: string; unsigned: string[]; prepared: boolean }[] = [];
  const verify: Verify = async ({ archive, version }) => {
    verified.push({ archive, version, unsigned: (await readdir(dirname(archive))).sort(),
      prepared: existsSync(join(dirname(archive), "../preparation.json")) });
  };
  return { root, output, commands, execute, build, notices, verify, verified,
    invalid() { status = "Invalid"; }, wrongVersion() { version = "9.9.9"; }, corrupt() { corruptAfterNotary = true; },
    close: () => rm(root, { recursive: true, force: true }) };
}

test("unsigned preparation reports pending publication decisions and creates complete matching archives", async () => {
  const f = await fixture();
  try {
    const state = await prepareRelease(f.output, f.root, f.execute, f.build, f.verify);
    expect(state.stage).toBe("unsigned");
    expect(state.publication.order).toEqual(["@mlx-bun/mlx", "mlx-bun"]);
    expect(state.publication.pending).toContain("mlx-bun is private; publication decision required");
    expect(state.publication.pending).toContain("@mlx-bun/mlx uses provisional version 0.0.0");
    const dir = join(f.output, "unsigned"), archive = await readFile(join(dir, "mlx-bun-v0.0.0-arm64.tar.gz"));
    expect(await readFile(join(dir, "mlx-bun-arm64.tar.gz"))).toEqual(archive);
    const checksum = createHash("sha256").update(archive).digest("hex");
    expect(await readFile(join(dir, "mlx-bun-v0.0.0-arm64.tar.gz.sha256"), "utf8")).toBe(`${checksum}  mlx-bun-v0.0.0-arm64.tar.gz\n`);
    expect(await readFile(join(dir, "mlx-bun-arm64.tar.gz.sha256"), "utf8")).toBe(`${checksum}  mlx-bun-arm64.tar.gz\n`);
    const formula = await readFile(join(dir, "mlx-bun.rb"), "utf8");
    expect(formula).toStartWith("# UNSIGNED LOCAL PREPARATION ONLY; do not publish this formula.\n");
    expect(formula).toContain(checksum);
    expect(Object.keys(state.files)).toContain("LICENSE"); expect(Object.keys(state.files)).toContain("THIRD_PARTY_NOTICES.md");
    expect(f.verified).toEqual([{ archive: join(dir, "mlx-bun-v0.0.0-arm64.tar.gz"), version: "0.0.0", prepared: false,
      unsigned: ["mlx-bun-arm64.tar.gz", "mlx-bun-arm64.tar.gz.sha256", "mlx-bun-v0.0.0-arm64.tar.gz", "mlx-bun-v0.0.0-arm64.tar.gz.sha256", "mlx-bun.rb"] }]);
    const extracted = Bun.spawnSync(["tar", "-xOf", join(dir, "mlx-bun-v0.0.0-arm64.tar.gz"), "THIRD_PARTY_NOTICES.md"]);
    expect(extracted.exitCode).toBe(0);
    expect(extracted.stdout.toString()).toBe(f.notices);
    expect(f.notices).toContain("# @silvia-odwyer/photon-node@"); expect(f.notices).toContain("# @earendil-works/pi-coding-agent@");
    expect(f.commands.some(command => ["codesign", "security", "xcrun", "gh", "npm"].includes(command[0]!))).toBe(false);
    await expect(packageRelease(f.output, f.execute)).rejects.toThrow("Accepted notarization");
    await expect(prepareRelease(f.output, f.root, f.execute, f.build, f.verify)).rejects.toThrow("EEXIST");
  } finally { await f.close(); }
});

test("release preparation rejects a bundle missing the microphone helper", async () => {
  const f = await fixture();
  try {
    await expect(prepareRelease(f.output, f.root, f.execute, async directory => {
      const executable = await f.build(directory);
      await rm(join(directory, MIC_CAPTURE_BINARY), { force: true });
      return executable;
    }, f.verify)).rejects.toThrow(`Missing bundle asset: ${MIC_CAPTURE_BINARY}`);
    expect(await readdir(f.output)).not.toContain("unsigned");
  } finally { await f.close(); }
});

test("failed or bundle-mutating acceptance leaves no unsigned output and no preparation record", async () => {
  const f = await fixture();
  try {
    await expect(prepareRelease(f.output, f.root, f.execute, f.build, async () => {
      throw new Error("mock acceptance failed");
    })).rejects.toThrow("mock acceptance failed");
    const mutated = join(f.root, "mutated");
    await expect(prepareRelease(mutated, f.root, f.execute, f.build, async () => {
      await writeFile(join(mutated, "bundle/LICENSE"), "changed during acceptance");
    })).rejects.toThrow("Bundle changed during verification");
    for (const directory of [f.output, mutated]) {
      expect(await readdir(directory)).not.toContain("unsigned");
      expect(await readdir(directory)).not.toContain("preparation.json");
    }
  } finally { await f.close(); }
});

/** The texts of a notice's ```text blocks; the `### ` subsection of a notice section; the
 * git blobs a notice names; and a text's git blob. */
const fenced = (text: string) => [...text.matchAll(/```text\n([\s\S]*?)```/g)].map(match => match[1]!);
function subsection(section: string, heading: string): string {
  const start = section.indexOf(`\n${heading}\n`), end = section.indexOf("\n### ", start + 1);
  if (start < 0) throw new Error(`Missing notice subsection: ${heading}`);
  return section.slice(start, end < 0 ? undefined : end + 1);
}
const namedBlobs = (text: string) => [...text.matchAll(/git blob\s+`([0-9a-f]{40})`/g)].map(match => match[1]!);
const blobOf = (text: string) => gitBlobSha1(new TextEncoder().encode(text));
/** The upstream bytes of a reproduced text: restores the disclosed line-ending spaces (1-based
 * line → count) and, with `crlf`, the CRLF line endings; nothing else may differ. */
const upstream = (text: string, spaces: Record<number, number>, crlf = false) =>
  text.split("\n").map((line, index) => line + " ".repeat(spaces[index + 1] ?? 0)).join(crlf ? "\r\n" : "\n");

test("bundle notices carry the package notices, Photon's installed license and Pi's upstream license verbatim", async () => {
  expect(verifyBundle).toBeFunction();
  const app = resolve(import.meta.dir, ".."), root = resolve(app, "../..");
  const piDirectory = dirname(Bun.resolveSync("@earendil-works/pi-coding-agent/package.json", app));
  const photonDirectory = dirname(Bun.resolveSync("@silvia-odwyer/photon-node", dirname(Bun.resolveSync("@earendil-works/pi-coding-agent", app))));
  const photon = JSON.parse(await readFile(join(photonDirectory, "package.json"), "utf8"));
  const bundle = await bundleNotices([]);
  const [mlx, inference, photonNotice, appNotice, ...extra] = bundle;
  expect(extra).toEqual([]);
  // Every curated section reaches the bundle whole.
  for (const [file, sections] of Object.entries(CURATED)) for (const heading of Object.keys(sections))
    expect(bundle.join("\n\n---\n\n")).toContain(noticeSection(await readFile(join(root, file), "utf8"), heading));
  for (const [name, notice] of [["mlx", mlx], ["inference", inference]] as const)
    expect(notice).toBe(`# @mlx-bun/${name}\n\n${await readFile(join(root, "packages", name, "THIRD_PARTY_NOTICES.md"), "utf8")}`);
  const photonLicense = await readFile(join(photonDirectory, "LICENSE.md"), "utf8");
  expect(photonLicense).toContain("Apache License");
  expect(photonNotice).toBe(`# @silvia-odwyer/photon-node@${photon.version}\n\nCovers the bundled \`photon_rs_bg.wasm\`. License: Apache-2.0.\n\n${photonLicense}`);

  // Pi's npm packages ship no license file; the app notice carries the upstream
  // LICENSE blob it names, byte for byte, for every installed Pi package version.
  const notice = await readFile(join(app, "THIRD_PARTY_NOTICES.md"), "utf8"), pi = noticeSection(notice, "## Pi");
  expect(appNotice).toBe(`# mlx-bun\n\n${notice}`);
  for (const name of ["pi-coding-agent", "pi-ai", "pi-agent-core", "pi-tui"]) {
    const { version } = JSON.parse(await readFile(join(dirname(Bun.resolveSync(`@earendil-works/${name}/package.json`, piDirectory)), "package.json"), "utf8"));
    expect(pi).toContain(`\`@earendil-works/${name}@${version}\``);
  }
  const license = pi.slice(pi.indexOf("MIT License")).replace(/\n+$/, "");
  expect(license).toStartWith("MIT License\n\nCopyright (c) 2025 Mario Zechner\n");
  expect(license).toContain("The above copyright notice and this permission notice shall be included in all\ncopies or substantial portions of the Software.");
  const blob = pi.match(/git blob `([0-9a-f]{40})`/)![1];
  // The Jiti section groups the license texts of 57 of the 58 embedded package versions.
  const jiti = noticeSection(notice, "## Jiti 2.7.0 prebundle");
  expect(new Set(jiti.split("\n").filter(line => line.startsWith("### `")).flatMap(line => line.match(/`[^`]+@[^`]+`/g)!)).size).toBe(57);
  expect(gitBlobSha1(new TextEncoder().encode(license))).toBe(blob!);
  // The 58th has no license text; the section records its manifest's statement instead.
  expect(jiti.replace(/\s+/g, " ")).toContain('its `package.json`, `"author": "Warner"` and `"license": "MIT"`');
  // Code Jiti copies: the upstream license blobs named, byte for byte, except TypeScript's two
  // files, whose whole texts are those blobs once the disclosed whitespace is restored.
  for (const heading of ["### import-meta-env plugin code", "### import-meta-paths plugin code"]) {
    const part = subsection(jiti, heading);
    expect(fenced(part).map(blobOf)).toEqual(namedBlobs(part));
  }
  const typescript = subsection(jiti, "### TypeScript compiler code in the copied metadata plugin");
  const [copyright, apache] = fenced(typescript);
  expect([blobOf(upstream(copyright!, { 2: 1, 5: 2, 6: 1, 9: 1, 10: 1, 11: 1 })), blobOf(upstream(apache!, { 5: 1 }, true))])
    .toEqual(namedBlobs(typescript).slice(1));
});

async function packageTree(files: Record<string, string>) {
  const root = await mkdtemp(join(tmpdir(), "mlx-notices-"));
  for (const [path, text] of Object.entries(files)) {
    await mkdir(dirname(join(root, path)), { recursive: true });
    await writeFile(join(root, path), text);
  }
  return root;
}
const manifest = (name: string, version?: string) => JSON.stringify({ name, version });

test("notice coverage is every metafile input with output bytes, grouped by its nearest versioned package.json", async () => {
  const root = await packageTree({
    "node_modules/kept/package.json": manifest("kept", "1.0.0"), "node_modules/kept/LICENSE": "kept license\n",
    "node_modules/kept/NOTICE": "kept notice\n", "node_modules/kept/esm/package.json": '{"type":"module"}',
    "node_modules/kept/esm/index.js": "kept", "node_modules/kept/esm/unused.js": "unused",
    "node_modules/dropped/package.json": manifest("dropped", "2.0.0"), "node_modules/dropped/index.js": "dropped",
    "node_modules/other/package.json": manifest("other", "3.0.0"), "node_modules/other/licence.md": "other licence\n",
    "node_modules/other/index.js": "other",
    "packages/own/package.json": manifest("@mlx-bun/own", "0.0.0"), "packages/own/src/own.ts": "own",
  });
  try {
    const compiled: Metafile = { outputs: { "./mlx-bun": { inputs: {
      "node_modules/kept/esm/index.js": { bytesInOutput: 4 }, "node_modules/kept/esm/unused.js": { bytesInOutput: 0 },
      "node_modules/dropped/index.js": { bytesInOutput: 0 }, "packages/own/src/own.ts": { bytesInOutput: 3 } } } } };
    const browser: Metafile = { outputs: { "./main.js": { inputs: {
      "../other/index.js": { bytesInOutput: 5 }, "../kept/esm/index.js": { bytesInOutput: 4 } } } } };
    const packages = await retainedPackages([...retainedInputs(compiled, root), ...retainedInputs(browser, join(root, "node_modules/kept"))]);
    expect(packages).toEqual([
      { id: "kept@1.0.0", name: "kept", version: "1.0.0", directory: join(root, "node_modules/kept"), files: ["esm/index.js"] },
      { id: "other@3.0.0", name: "other", version: "3.0.0", directory: join(root, "node_modules/other"), files: ["index.js"] },
    ]);
    expect(await packageNotices(packages, {})).toEqual([
      "# kept@1.0.0\n\n## LICENSE\n\nkept license\n\n## NOTICE\n\nkept notice\n",
      "# other@3.0.0\n\n## licence.md\n\nother licence\n",
    ]);
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("a retained package without installed license text needs a fallback naming its exact version", async () => {
  const root = await packageTree({ "node_modules/bare/package.json": manifest("bare", "1.2.3"), "node_modules/bare/index.js": "bare" });
  try {
    const packages = await retainedPackages([join(root, "node_modules/bare/index.js")]);
    await expect(packageNotices(packages, {})).rejects.toThrow("bare@1.2.3");
    await expect(packageNotices(packages, { "mlx-bun": "Upstream text for `bare@1.2.4`." })).rejects.toThrow("bare@1.2.3");
    expect(await packageNotices(packages, { "@mlx-bun/inference": "none", "mlx-bun": "Upstream text for `bare@1.2.3`." }))
      .toEqual(["# bare@1.2.3\n\nNo license file is installed; the upstream text is in the `mlx-bun` section.\n"]);
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("reviewed vendored license headers are copied verbatim only for retained files at the reviewed version", async () => {
  const root = await packageTree({
    "node_modules/host/package.json": manifest("host", "1.0.0"), "node_modules/host/LICENSE": "host license\n",
    "node_modules/host/lib/vendor.js": "// host code\n/* Copyright (c) Vendor\n * MIT */\nexport {};\n",
    "node_modules/host/lib/unretained.js": "/* Copyright (c) Unretained */\n",
  });
  try {
    const packages = await retainedPackages([join(root, "node_modules/host/lib/vendor.js")]);
    const headers: Record<string, [number, number]> = { "lib/vendor.js": [2, 3], "lib/unretained.js": [1, 1] };
    expect(await packageNotices(packages, {}, { host: { version: "1.0.0", headers } })).toEqual([
      "# host@1.0.0\n\n## LICENSE\n\nhost license\n\n## lib/vendor.js (vendored; license header verbatim)\n\n/* Copyright (c) Vendor\n * MIT */\n",
    ]);
    await expect(packageNotices(packages, {}, { host: { version: "0.9.0", headers } })).rejects.toThrow("host@1.0.0 was reviewed only at host@0.9.0");
    await expect(packageNotices(packages, {}, { host: { version: "1.0.0", headers: { "lib/vendor.js": [1, 1] } } }))
      .rejects.toThrow("lib/vendor.js:1-1 is not a license header");
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("a missing or changed curated notice section fails the notice check", async () => {
  const root = resolve(import.meta.dir, "../../..");
  const notices: Record<string, string> = {};
  for (const file of Object.keys(CURATED)) notices[file] = await readFile(join(root, file), "utf8");
  checkCurated(notices);
  for (const [file, sections] of Object.entries(CURATED)) for (const heading of Object.keys(sections)) {
    const section = noticeSection(notices[file]!, heading);
    expect(() => checkCurated({ ...notices, [file]: notices[file]!.replace(section, "") })).toThrow(`Missing notice section: ${heading}`);
    const changed = section.replace(/(\S)(\s*)$/, (_, last: string, rest: string) => (last === "." ? "," : ".") + rest);
    expect(() => checkCurated({ ...notices, [file]: notices[file]!.replace(section, () => changed) })).toThrow(`${file} "${heading}" (sha256 `);
  }
  const app = "apps/mlx-bun/THIRD_PARTY_NOTICES.md", semver = notices[app]!.indexOf("### `semver@6.3.1`");
  const withoutSemver = notices[app]!.slice(0, semver) + notices[app]!.slice(notices[app]!.indexOf("### `std-env@", semver));
  expect(() => checkCurated({ ...notices, [app]: withoutSemver })).toThrow(`"## Jiti 2.7.0 prebundle" (sha256 `);
  // So is every reproduced text inside a section: one changed word of a copied plugin's
  // license, or a dropped Emscripten runtime subsection.
  expect(() => checkCurated({ ...notices, [app]: notices[app]!.replace("// javiertury\n", "// javier\n") }))
    .toThrow(`"## Jiti 2.7.0 prebundle" (sha256 `);
  const inference = "packages/inference/THIRD_PARTY_NOTICES.md", xgrammar = noticeSection(notices[inference]!, "## XGrammar");
  const withoutEmscripten = notices[inference]!.replace(xgrammar, () => xgrammar.slice(0, xgrammar.indexOf("\n### Emscripten") + 1));
  expect(() => checkCurated({ ...notices, [inference]: withoutEmscripten })).toThrow(`"## XGrammar" (sha256 `);
  expect(() => checkCurated({ [app]: notices[app]! })).toThrow("Missing notice file: packages/inference/THIRD_PARTY_NOTICES.md");
});

test("a changed byte in a pinned json-bigint or XGrammar file fails at the reviewed version", async () => {
  const app = resolve(import.meta.dir, ".."), root = resolve(app, "../..");
  const installed = (...chain: string[]) => chain.reduce((from, name) => Bun.resolveSync(name, dirname(from)), join(app, "package.json"));
  const bigint = await readFile(join(dirname(installed("@earendil-works/pi-ai", "@google/genai", "google-auth-library", "gcp-metadata", "json-bigint")), "lib/parse.js"));
  const xgrammar = await readFile(Bun.resolveSync("@mlc-ai/web-xgrammar", join(root, "packages/inference")));
  for (const [name, version, file, bytes] of [["json-bigint", "1.0.0", "lib/parse.js", bigint], ["@mlc-ai/web-xgrammar", "0.1.27", "lib/index.js", xgrammar]] as const) {
    const changed = Buffer.from(bytes), at = changed.length - 2;
    changed[at] = changed[at]! ^ 1;
    const tree = await packageTree({ [`node_modules/${name}/package.json`]: manifest(name, version), [`node_modules/${name}/${file}`]: "" });
    try {
      await writeFile(join(tree, "node_modules", name, file), changed);
      const hash = createHash("sha256").update(changed).digest("hex");
      await expect(packageNotices(await retainedPackages([join(tree, "node_modules", name, file)]), {}))
        .rejects.toThrow(`${name}@${version} ${file} (sha256 ${hash}) is not a reviewed file`);
    } finally { await rm(tree, { recursive: true, force: true }); }
  }
});

test("Jiti's prebundle files must match the reviewed hashes at the reviewed version", async () => {
  const root = await packageTree({
    "node_modules/jiti/package.json": manifest("jiti", "2.7.0"), "node_modules/jiti/LICENSE": "jiti license\n",
    "node_modules/jiti/dist/jiti.cjs": "changed", "node_modules/jiti/dist/extra.cjs": "new",
    "node_modules/newer/node_modules/jiti/package.json": manifest("jiti", "2.7.1"),
    "node_modules/newer/node_modules/jiti/dist/jiti.cjs": "newer",
  });
  try {
    const hash = createHash("sha256").update("changed").digest("hex");
    await expect(packageNotices(await retainedPackages([join(root, "node_modules/jiti/dist/jiti.cjs")]), {}))
      .rejects.toThrow(`jiti@2.7.0 dist/jiti.cjs (sha256 ${hash}) is not a reviewed file`);
    await expect(packageNotices(await retainedPackages([join(root, "node_modules/jiti/dist/extra.cjs")]), {}))
      .rejects.toThrow("jiti@2.7.0 dist/extra.cjs");
    await expect(packageNotices(await retainedPackages([join(root, "node_modules/newer/node_modules/jiti/dist/jiti.cjs")]), {}))
      .rejects.toThrow("jiti@2.7.1 was reviewed only at jiti@2.7.0");
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("the reviewed headers, Jiti hashes and XGrammar fallback match the installed packages", async () => {
  const app = resolve(import.meta.dir, ".."), root = resolve(app, "../..");
  const installed = (...chain: string[]) => chain.reduce((from, name) => Bun.resolveSync(name, dirname(from)), join(app, "package.json"));
  const packages = await retainedPackages([installed("@earendil-works/pi-coding-agent"),
    installed("@earendil-works/pi-coding-agent", "@earendil-works/pi-tui"), installed("@earendil-works/pi-coding-agent", "jiti"),
    installed("@earendil-works/pi-ai", "@mistralai/mistralai"),
    installed("@earendil-works/pi-ai", "@google/genai", "google-auth-library", "gcp-metadata", "json-bigint"),
    Bun.resolveSync("@mlc-ai/web-xgrammar", join(root, "packages/inference"))]);
  expect(packages.map(({ name }) => name).sort()).toEqual(Object.keys(REVIEWED).sort());
  const appNotice = await readFile(join(app, "THIRD_PARTY_NOTICES.md"), "utf8");
  const inference = await readFile(join(root, "packages/inference/THIRD_PARTY_NOTICES.md"), "utf8");
  const sections = await packageNotices(packages.map(found => ({ ...found,
    files: [...new Set([...Object.keys(REVIEWED[found.name]!.headers ?? {}), ...Object.keys(REVIEWED[found.name]!.sha256 ?? {})])] })),
  { "@mlx-bun/inference": inference, "mlx-bun": appNotice });
  expect(sections.join("").match(/\(vendored; license header verbatim\)/g)).toHaveLength(5);
  for (const text of ["Copyright (c) Sindre Sorhus", "MIT License - Copyright (c) 2025 opentui", "Copyright (c) 2024 Jason Miller", "(c) BSD-3-Clause"])
    expect(sections.join("")).toContain(text);

  // XGrammar's npm package ships no license file; the inference notice carries
  // the upstream LICENSE and NOTICE blobs it names for the installed version.
  const xgrammar = await retainedPackages([Bun.resolveSync("@mlc-ai/web-xgrammar", join(root, "packages/inference"))]);
  expect(await packageNotices(xgrammar, { "@mlx-bun/inference": inference }))
    .toEqual([`# ${xgrammar[0]!.id}\n\nNo license file is installed; the upstream text is in the \`@mlx-bun/inference\` section.\n`]);
  const whole = noticeSection(inference, "## XGrammar"), split = whole.indexOf("\n### picojson");
  const [section, picojson] = [whole.slice(0, split), subsection(whole, "### picojson in the XGrammar WASM")];
  const [license, notice] = [...section.matchAll(/```text\n([^`]*)```/g)].map(match => match[1]!);
  const blobs = [...section.matchAll(/git blob\s+`([0-9a-f]{40})`/g)].map(match => match[1]!);
  expect(license).toStartWith("                                 Apache License\n");
  expect([gitBlobSha1(new TextEncoder().encode(license)), gitBlobSha1(new TextEncoder().encode(notice!))]).toEqual(blobs);
  // picojson's header is the recorded lines of the header file, byte for byte.
  const header = picojson.match(/```text\n([^`]*)```/)![1]!;
  expect(header).toStartWith("/*\n * Copyright 2009-2010 Cybozu Labs, Inc.\n");
  expect(createHash("sha256").update(header).digest("hex")).toBe(picojson.match(/lines 1-27 \(sha256\s+`([0-9a-f]{64})`\)/)![1]!);
  // The Emscripten texts (3.1.56's, the release-era match) are the blobs named, byte for byte,
  // except the space ending its LICENSE's line 60.
  const emscripten = subsection(whole, "### Emscripten runtime in the XGrammar WASM (3.1.56 release-era match)");
  const [em, ...libraries] = fenced(emscripten);
  expect([blobOf(upstream(em!, { 60: 1 })), ...libraries.map(blobOf)]).toEqual(namedBlobs(emscripten));

  // What the notices say of the pinned bytes: Jiti's babel.cjs keeps the copied plugins and
  // the parameter decorator; XGrammar's runtime glue has both fingerprints of the 3.1.56
  // release-era match (Module["ready"] present, WebAssembly check absent), and its WASM keeps
  // musl, libc++ and libc++abi strings.
  const babel = await readFile(join(packages.find(({ name }) => name === "jiti")!.directory, "dist/babel.cjs"), "utf8");
  for (const text of ['name:"@import-meta-env/babel"', "require('url').pathToFileURL(__filename).toString()",
    "function serializeTypeList(", "babel-plugin-parameter-decorator@1.0.16/"]) expect(babel).toContain(text);
  const runtime = await readFile(join(xgrammar[0]!.directory, "lib/index.js"), "utf8");
  expect(runtime).toContain('Module["ready"]=new Promise');
  expect(runtime).not.toContain("no native wasm support");
  const wasm = Buffer.from(runtime.match(/"data:application\/octet-stream;base64,([A-Za-z0-9+/=]+)"/)![1]!, "base64").toString("latin1");
  for (const text of ["-+   0X0x", "(null)", "NSt3__28ios_baseE", "terminate_handler unexpectedly returned", "N10__cxxabiv117__class_type_infoE"])
    expect(wasm).toContain(text);
});

test("publication order rejects cycles, unpackaged ranges, missing packages and incompatible versions", () => {
  const a = { name: "@mlx-bun/a", version: "1.0.0", dependencies: { "@mlx-bun/b": "1.0.0" } };
  const b = { name: "@mlx-bun/b", version: "1.0.0" };
  expect(publicationPlan([a, b]).order).toEqual([b.name, a.name]);
  expect(() => publicationPlan([a])).toThrow("Missing package archive");
  expect(() => publicationPlan([a, { ...b, version: "2.0.0" }])).toThrow("excludes");
  expect(() => publicationPlan([{ ...a, dependencies: { [b.name]: "workspace:*" } }, b])).toThrow("unpackaged");
  expect(() => publicationPlan([a, { ...b, dependencies: { [a.name]: "1.0.0" } }])).toThrow("cycle");
});

test("signing handles every Mach-O before main, verifies each, and uses the preserved Bun entitlements", async () => {
  const f = await fixture();
  try {
    await prepareRelease(f.output, f.root, f.execute, f.build, f.verify);
    await signRelease(f.output, "MOCK Developer ID", f.execute);
    const signing = f.commands.filter(command => command[0] === "codesign" && command.includes("--sign"));
    expect(signing.at(-1)?.at(-1)?.endsWith("/bundle/mlx-bun")).toBe(true);
    expect(signing.some(command => command.at(-1)?.endsWith("future-microphone-helper"))).toBe(true);
    expect(signing.some(command => command.at(-1)?.endsWith(`/bundle/${MIC_CAPTURE_BINARY}`))).toBe(true);
    expect(signing.some(command => command.at(-1)?.endsWith("photon_rs_bg.wasm"))).toBe(false);
    for (const command of signing) {
      expect(command).toContain("--timestamp"); expect(command).toContain("runtime");
      expect(f.commands.some(check => check[0] === "codesign" && check.includes("--verify") && check.at(-1) === command.at(-1))).toBe(true);
    }
    const main = signing.at(-1)!;
    const entitlements = await readFile(main[main.indexOf("--entitlements") + 1]!, "utf8");
    for (const key of ["allow-jit", "allow-unsigned-executable-memory", "disable-library-validation"]) expect(entitlements).toContain(key);
    expect(JSON.parse(await readFile(join(f.output, "preparation.json"), "utf8")).stage).toBe("signed");
    expect(f.commands.at(-1)?.at(-1)).toBe("--version");
    expect(f.commands.at(-1)?.[0]?.endsWith("/bundle/mlx-bun")).toBe(true);
  } finally { await f.close(); }
});

test("a zero-exit Invalid notary result cannot unlock release packaging", async () => {
  const f = await fixture();
  try {
    await prepareRelease(f.output, f.root, f.execute, f.build, f.verify); await signRelease(f.output, "MOCK ID", f.execute);
    f.invalid();
    await expect(notarizeRelease(f.output, "MOCK_PROFILE", f.execute)).rejects.toThrow("not accepted");
    await expect(packageRelease(f.output, f.execute)).rejects.toThrow("Accepted notarization");
    expect(await readdir(f.output)).not.toContain("notarize.zip");
    const submission = f.commands.find(command => command[0] === "xcrun")!;
    expect(submission.slice(-2)).toEqual(["--output-format", "json"]);
  } finally { await f.close(); }
});

test("a partial signing failure preserves the original bytes and can be retried", async () => {
  const f = await fixture();
  try {
    const prepared = await prepareRelease(f.output, f.root, f.execute, f.build, f.verify);
    let signed = 0;
    const partial: Run = async (command, cwd) => {
      if (command[0] === "codesign" && command.includes("--sign")) {
        await writeFile(command.at(-1)!, "partially signed bytes");
        if (++signed === 2) throw Error("signing interrupted");
      }
      return f.execute(command, cwd);
    };
    await expect(signRelease(f.output, "MOCK ID", partial)).rejects.toThrow("interrupted");
    for (const [name, hash] of Object.entries(prepared.files))
      expect(createHash("sha256").update(await readFile(join(f.output, "bundle", name))).digest("hex")).toBe(hash);
    expect(JSON.parse(await readFile(join(f.output, "preparation.json"), "utf8")).stage).toBe("unsigned");
    expect((await readdir(f.output)).some(name => name.startsWith("sign-"))).toBe(false);
    await signRelease(f.output, "MOCK ID", f.execute);
    expect(JSON.parse(await readFile(join(f.output, "preparation.json"), "utf8")).stage).toBe("signed");
  } finally { await f.close(); }
});

test("a failed post-sign launch check cannot advance to notarization", async () => {
  const f = await fixture();
  try {
    await prepareRelease(f.output, f.root, f.execute, f.build, f.verify);
    f.wrongVersion();
    await expect(signRelease(f.output, "MOCK ID", f.execute)).rejects.toThrow("Binary version differs");
    await expect(notarizeRelease(f.output, "MOCK_PROFILE", f.execute)).rejects.toThrow("Sign this preparation");
    expect(f.commands.some(command => command[0] === "xcrun")).toBe(false);
  } finally { await f.close(); }
});

test("Accepted evidence is bound to bundle bytes and checked again before packaging", async () => {
  const f = await fixture();
  try {
    await prepareRelease(f.output, f.root, f.execute, f.build, f.verify); await signRelease(f.output, "MOCK ID", f.execute);
    await notarizeRelease(f.output, "MOCK_PROFILE", f.execute);
    await packageRelease(f.output, f.execute);
    expect(await readdir(join(f.output, "release"))).toContain("mlx-bun.rb");
    const formula = await readFile(join(f.output, "release/mlx-bun.rb"), "utf8");
    expect(formula).toStartWith("# Generated from mlx-bun-v0.0.0-arm64.tar.gz;");
    expect(formula).not.toContain("UNSIGNED LOCAL PREPARATION ONLY");
    expect(await readFile(join(f.output, "unsigned/mlx-bun.rb"), "utf8")).toStartWith("# UNSIGNED LOCAL PREPARATION ONLY;");
    await writeFile(join(f.output, "bundle/LICENSE"), "changed");
    await expect(packageRelease(f.output, f.execute)).rejects.toThrow("Bundle changed");
  } finally { await f.close(); }
});

test("mutations during notarization and binary version mismatches block advancement", async () => {
  const f = await fixture();
  try {
    await prepareRelease(f.output, f.root, f.execute, f.build, f.verify); await signRelease(f.output, "MOCK ID", f.execute);
    f.corrupt();
    await expect(notarizeRelease(f.output, "MOCK_PROFILE", f.execute)).rejects.toThrow("Bundle changed");
    expect(JSON.parse(await readFile(join(f.output, "preparation.json"), "utf8")).stage).toBe("signed");
    const other = join(f.root, "wrong-version"); f.wrongVersion();
    await expect(prepareRelease(other, f.root, f.execute, f.build, f.verify)).rejects.toThrow("Binary version differs");
    expect(await readdir(other)).not.toContain("unsigned");
  } finally { await f.close(); }
});
