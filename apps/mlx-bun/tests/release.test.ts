import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { existsSync } from "node:fs";
import { mkdir, mkdtemp, readFile, readdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, dirname, join, resolve } from "node:path";
import { bundleNotices } from "../../../scripts/build-binary";
import { BUNDLE_FILES } from "../../../scripts/bundle-files";
import { MIC_CAPTURE_BINARY } from "../src/engine/mic-capture";
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

test("bundle notices carry the package notices and the installed Photon and Pi license texts verbatim", async () => {
  expect(verifyBundle).toBeFunction();
  const app = resolve(import.meta.dir, ".."), root = resolve(app, "../..");
  const piDirectory = dirname(Bun.resolveSync("@earendil-works/pi-coding-agent/package.json", app));
  const photonDirectory = dirname(Bun.resolveSync("@silvia-odwyer/photon-node", dirname(Bun.resolveSync("@earendil-works/pi-coding-agent", app))));
  const pi = JSON.parse(await readFile(join(piDirectory, "package.json"), "utf8"));
  const photon = JSON.parse(await readFile(join(photonDirectory, "package.json"), "utf8"));
  const [mlx, inference, photonNotice, piNotice, ...extra] = await bundleNotices();
  expect(extra).toEqual([]);
  for (const [name, notice] of [["mlx", mlx], ["inference", inference]] as const)
    expect(notice).toBe(`# @mlx-bun/${name}\n\n${await readFile(join(root, "packages", name, "THIRD_PARTY_NOTICES.md"), "utf8")}`);
  const photonLicense = await readFile(join(photonDirectory, "LICENSE.md"), "utf8");
  expect(photonLicense).toContain("Apache License");
  expect(photonNotice).toBe(`# @silvia-odwyer/photon-node@${photon.version}\n\nCovers the bundled \`photon_rs_bg.wasm\`. License: Apache-2.0.\n\n${photonLicense}`);
  expect(piNotice).toStartWith(`# @earendil-works/pi-coding-agent@${pi.version}\n\nCompiled into the \`mlx-bun\` executable. License: MIT`);
  const piLicense = (await readdir(piDirectory)).find(name => /^licen[cs]e(\.md|\.txt)?$/i.test(name));
  expect(piNotice).toContain(piLicense ? await readFile(join(piDirectory, piLicense), "utf8")
    : "declared in the installed package.json; the package ships no license file");
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
    expect(signing.at(-1)?.at(-1)).toBe(join(f.output, "bundle/mlx-bun"));
    expect(signing.some(command => command.at(-1)?.endsWith("future-microphone-helper"))).toBe(true);
    expect(signing.some(command => command.at(-1) === join(f.output, "bundle", MIC_CAPTURE_BINARY))).toBe(true);
    expect(signing.some(command => command.at(-1)?.endsWith("photon_rs_bg.wasm"))).toBe(false);
    for (const command of signing) {
      expect(command).toContain("--timestamp"); expect(command).toContain("runtime");
      expect(f.commands.some(check => check[0] === "codesign" && check.includes("--verify") && check.at(-1) === command.at(-1))).toBe(true);
    }
    const main = signing.at(-1)!;
    const entitlements = await readFile(main[main.indexOf("--entitlements") + 1]!, "utf8");
    for (const key of ["allow-jit", "allow-unsigned-executable-memory", "disable-library-validation"]) expect(entitlements).toContain(key);
    expect(JSON.parse(await readFile(join(f.output, "preparation.json"), "utf8")).stage).toBe("signed");
    expect(f.commands.at(-1)).toEqual([join(f.output, "bundle/mlx-bun"), "--version"]);
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
