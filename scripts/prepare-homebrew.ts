import { createHash } from "node:crypto";
import { readFile, writeFile } from "node:fs/promises";
import { basename, dirname, join, resolve } from "node:path";
import { NATIVE_FILES as MLX_FILES } from "../packages/mlx/src/native";
import { NATIVE_FILES as INFERENCE_FILES } from "../packages/inference/src/runtime/native";

/** Prepare a reviewable formula from a local release tarball; never install,
 * sign, publish, clone, or write to the user's Homebrew tap. */
export async function prepareHomebrew(archive: string, output = join(dirname(archive), "mlx-bun.rb")): Promise<string> {
  const name = basename(archive);
  const match = /^mlx-bun-v(\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?(?:\+[A-Za-z0-9.-]+)?)-arm64\.tar\.gz$/.exec(name);
  if (!match) throw new Error("Expected mlx-bun-v<version>-arm64.tar.gz");
  if (resolve(archive) === resolve(output)) throw new Error("Formula output must not overwrite the archive");
  const data = await readFile(archive);
  if (!data.length) throw new Error("Release archive is empty");
  const listing = Bun.spawn(["tar", "-tzf", resolve(archive)], { stdout: "pipe", stderr: "pipe" });
  const [files, error, code] = await Promise.all([
    new Response(listing.stdout).text(), new Response(listing.stderr).text(), listing.exited,
  ]);
  if (code !== 0) throw new Error(`Invalid release archive: ${error}`);
  const entries = new Set(files.trim().split("\n").map(name => name.replace(/^\.\//, "")));
  for (const file of ["mlx-bun", ...MLX_FILES, ...INFERENCE_FILES, "photon_rs_bg.wasm", "LICENSE", "THIRD_PARTY_NOTICES.md"])
    if (!entries.has(file)) throw new Error(`Incomplete release archive: ${file}`);
  const checksum = createHash("sha256").update(data).digest("hex");
  await writeFile(output, `# Generated from ${name}; review before publishing to joshuarossi/homebrew-tap.
class MlxBun < Formula
  desc "Local AI on Apple Silicon"
  homepage "https://github.com/joshuarossi/mlx-bun"
  version "${match[1]}"
  url "https://github.com/joshuarossi/mlx-bun/releases/download/v${match[1]}/${name}"
  sha256 "${checksum}"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"mlx-bun"
  end

  test do
    assert_equal "mlx-bun #{version}\\n", shell_output("#{bin}/mlx-bun --version")
  end
end
`);
  return output;
}

if (import.meta.main) {
  const args = process.argv.slice(2);
  if (args[0] === "--help") console.log("Usage: bun scripts/prepare-homebrew.ts mlx-bun-v<version>-arm64.tar.gz [output.rb]\nPrepare a local formula with the archive SHA256; does not publish or install.");
  else {
    if (!args[0] || args.length > 2) throw new Error("Use --help for usage");
    console.log(await prepareHomebrew(args[0], args[1]));
  }
}
