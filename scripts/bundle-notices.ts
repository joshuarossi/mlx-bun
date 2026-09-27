import { createHash } from "node:crypto";
import { readdir, readFile } from "node:fs/promises";
import { dirname, join, relative, resolve, sep } from "node:path";

/** The part of a Bun metafile that records what reached each output. */
export interface Metafile { outputs: Record<string, { inputs: Record<string, { bytesInOutput: number }> }> }

/** Input files that contributed bytes to a build. Bun records metafile input
 * paths relative to the directory the build ran in. */
export function retainedInputs(metafile: Metafile, cwd: string): string[] {
  return Object.values(metafile.outputs).flatMap(output => Object.entries(output.inputs)
    .filter(([, input]) => input.bytesInOutput > 0).map(([path]) => resolve(cwd, path)));
}

export interface RetainedPackage { id: string; name: string; version: string; directory: string; files: string[] }

/** Groups retained files by the nearest package.json with a name and version.
 * Workspace packages (outside node_modules) are skipped: they ship their own notices. */
export async function retainedPackages(inputs: string[]): Promise<RetainedPackage[]> {
  const manifests = new Map<string, { name?: string; version?: string } | null>();
  const packages = new Map<string, RetainedPackage>();
  for (const input of inputs) {
    let directory = dirname(input);
    while (true) {
      if (!manifests.has(directory))
        manifests.set(directory, await readFile(join(directory, "package.json"), "utf8").then(JSON.parse, () => null));
      const manifest = manifests.get(directory);
      if (manifest?.name && manifest.version) break;
      if (directory === dirname(directory)) throw new Error(`No package.json with a name and version above ${input}`);
      directory = dirname(directory);
    }
    if (!directory.split(sep).includes("node_modules")) continue;
    const { name, version } = manifests.get(directory) as { name: string; version: string }, id = `${name}@${version}`;
    const found = packages.get(id) ?? { id, name, version, directory, files: [] };
    packages.set(id, found);
    const file = relative(directory, input);
    if (!found.files.includes(file)) found.files.push(file);
  }
  return [...packages.values()].sort((a, b) => a.id < b.id ? -1 : 1);
}

/** Reviewed facts bound to one installed version; any other version fails the
 * build until reviewed. `headers`: vendored code with its own license header,
 * as 1-based inclusive line ranges copied verbatim. `sha256`: a package whose
 * every retained file must match a recorded hash, because a curated notice
 * section (CURATED) covers code it embeds. */
export type Reviewed = Record<string, { version: string; headers?: Record<string, [number, number]>; sha256?: Record<string, string> }>;
export const REVIEWED: Reviewed = {
  "@earendil-works/pi-coding-agent": { version: "0.80.3", headers: { "dist/utils/ansi.js": [1, 27] } },
  "@earendil-works/pi-tui": { version: "0.80.3", headers: { "dist/stdin-buffer.js": [16, 17] } },
  "@mistralai/mistralai": { version: "2.2.6", headers: { "esm/lib/dlv.js": [5, 26], "esm/lib/is-plain-object.js": [5, 26] } },
  // lib/parse.js copies BSD-3 code: the app notice's "json-bigint 1.0.0 copied code" section.
  "json-bigint": { version: "1.0.0", headers: { "lib/parse.js": [3, 5] }, sha256: {
    "index.js": "eb50baf4489e9f949347338ec8ed669404a2bad6f410d7aa90d80c95899080a2",
    "lib/parse.js": "a0d37ada5af598f4285e465ebf428ef03d570305a2437aa0cd2653861061cc4f",
    "lib/stringify.js": "04e4d734559017bbcb259b01e04334f7c8ccd991b29a7833aabfff5e7af5f728",
  } },
  // Emscripten WASM build of upstream commit ace2321a29471130f3f64fb1882741a5547c6f36, by an
  // unrecorded toolchain whose runtime glue is a release-era match for Emscripten 3.1.56 (inferred
  // from two runtime-glue fingerprints: WebAssembly-check absence and Module["ready"] presence):
  // the inference notice's XGrammar section (LICENSE, NOTICE, picojson's header and 3.1.56's
  // Emscripten, musl, libc++ and libc++abi texts).
  "@mlc-ai/web-xgrammar": { version: "0.1.27", sha256: {
    "lib/index.js": "803713906fb3e53483ab03f33244a64d8ed818820be9abe520e615754bfd3e24",
  } },
  // Rspack prebundle: upstream commit fd3bb289b75ed207edfb686d671ed50144f7e90f, npm integrity
  // sha512-AC/7JofJvZGrrneWNaEnJeOLUx+JlGt7tNa0wZiRPT4MY1wmfKjt2+6O2p2uz2+skll8OZZmJMNqeke7kKbNgQ==.
  // The app notice's "Jiti 2.7.0 prebundle" section carries the notices it embeds.
  jiti: { version: "2.7.0", sha256: {
    "dist/babel.cjs": "b3bc89a8dc40860fb6a7a78512bdfe5976c6253e6ded74b7d96ece803cac8701",
    "dist/jiti.cjs": "a0b3b8d5e06a0519c66b62179e29200533057920f6f11370546e979dacd24c49",
    "lib/jiti-static.mjs": "0d873b8be0c9e08e1136ea428175de8cf8a200c67b6b83283a009b3f46ff4a3a",
  } },
};

/** Reviewed sha256 of each committed notice section copied from upstream, per
 * notice file: the text from its `## ` heading line up to the next `## ` heading. */
export const CURATED: Record<string, Record<string, string>> = {
  "apps/mlx-bun/THIRD_PARTY_NOTICES.md": {
    "## Pi": "9756bd6ea6b0f1528e2acd38b80268b093bc854fcd3e6d6aeb29f93c861ee2ff",
    "## Jiti 2.7.0 prebundle": "d92fcfa53e540b598d6842a20c90c29a92c142d9162226aacc5f0ff01312ec91",
    "## json-bigint 1.0.0 copied code": "eb03ce6552d2906b0662a905f1cfd63b902b5b05d8b0f7c2545b01c2c87a1d36",
  },
  "packages/inference/THIRD_PARTY_NOTICES.md": { "## XGrammar": "226e81596b8d905f71eaa95f54c380085efb7ecd640a4a6044f3da039e79d71d" },
};

/** The `## ` section of `notice` that starts with the line `heading`. */
export function noticeSection(notice: string, heading: string): string {
  const start = `\n${notice}`.indexOf(`\n${heading}\n`);
  if (start < 0) throw new Error(`Missing notice section: ${heading}`);
  const end = notice.indexOf("\n## ", start);
  return notice.slice(start, end < 0 ? undefined : end + 1);
}

/** Throws unless every curated section is present in its notice text (keyed by
 * file path) with the reviewed hash. */
export function checkCurated(notices: Record<string, string>, curated = CURATED): void {
  for (const [file, sections] of Object.entries(curated)) for (const [heading, sha256] of Object.entries(sections)) {
    if (notices[file] === undefined) throw new Error(`Missing notice file: ${file}`);
    const actual = createHash("sha256").update(noticeSection(notices[file], heading)).digest("hex");
    if (actual !== sha256) throw new Error(`${file} "${heading}" (sha256 ${actual}) is not the reviewed text; review it and record its hash`);
  }
}

const NOTICE_FILE = /^(licen[cs]e|notice|copying)/i;

/** One `# name@version` section per package: its installed LICENSE, LICENCE,
 * NOTICE and COPYING files verbatim or, when none is installed, a pointer to
 * the committed fallback section (title → text) that names the exact
 * `name@version` in backticks; then its reviewed vendored headers. Throws for a
 * package with neither text nor fallback, or one that differs from its review. */
export async function packageNotices(packages: RetainedPackage[], fallbacks: Record<string, string>, reviewed = REVIEWED): Promise<string[]> {
  return Promise.all(packages.map(async ({ id, name, version, directory, files }) => {
    const review = reviewed[name];
    if (review && review.version !== version) throw new Error(`${id} was reviewed only at ${name}@${review.version}; review its notices`);
    if (review?.sha256) for (const file of files) {
      const actual = createHash("sha256").update(await readFile(join(directory, file))).digest("hex");
      if (review.sha256[file] !== actual) throw new Error(`${id} ${file} (sha256 ${actual}) is not a reviewed file`);
    }
    const parts: string[] = [];
    for (const notice of (await readdir(directory)).filter(file => NOTICE_FILE.test(file)).sort())
      parts.push(`## ${notice}\n\n${await readFile(join(directory, notice), "utf8")}`);
    if (!parts.length) {
      const title = Object.keys(fallbacks).find(title => fallbacks[title]!.includes(`\`${id}\``));
      if (!title) throw new Error(`${id} is compiled in but installs no license text and no notice names \`${id}\``);
      parts.push(`No license file is installed; the upstream text is in the \`${title}\` section.\n`);
    }
    for (const [file, [first, last]] of Object.entries(review?.headers ?? {})) {
      if (!files.includes(file)) continue;
      const header = (await readFile(join(directory, file), "utf8")).split("\n").slice(first - 1, last).join("\n");
      if (!/copyright|\(c\)/i.test(header)) throw new Error(`${id} ${file}:${first}-${last} is not a license header`);
      parts.push(`## ${file} (vendored; license header verbatim)\n\n${header}\n`);
    }
    return `# ${id}\n\n${parts.join("\n")}`;
  }));
}
