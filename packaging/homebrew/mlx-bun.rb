# Homebrew formula for mlx-bun — source of truth.
#
# This file lives in the main repo for review/version control. To publish,
# copy it to the TAP repo at  joshuarossi/homebrew-tap/Formula/mlx-bun.rb
# and push (scripts/publish-release.sh does this automatically). Users then
# install with:
#
#   brew install joshuarossi/tap/mlx-bun
#
# After each release, update `version`, `url`, and `sha256` from the values
# scripts/release-binary.sh prints.
class MlxBun < Formula
  desc "Native MLX inference for Bun on Apple Silicon — local LLM server + TS library"
  homepage "https://github.com/joshuarossi/mlx-bun"
  version "0.0.12"
  url "https://github.com/joshuarossi/mlx-bun/releases/download/v0.0.12/mlx-bun-v0.0.12-arm64.tar.gz"
  sha256 "64c4d697faba65789c2af7c1344ee39024f8a03bd6839d2c8df4ec7dce872a74"
  license "MIT"

  # Apple Silicon + Metal only. Bump the macOS floor if MLX needs newer.
  depends_on arch: :arm64
  depends_on macos: :sonoma

  def install
    # The whole self-contained bundle (binary + dylibs + metallib + pi
    # assets) goes in libexec; the dylibs and assets resolve next to the
    # executable via dirname(realpath(process.execPath)) — Bun realpaths
    # execPath, so the bin/ symlink resolves back here correctly.
    libexec.install Dir["*"]
    bin.install_symlink libexec/"mlx-bun"
  end

  test do
    assert_match "mlx-bun #{version}", shell_output("#{bin}/mlx-bun --version")
  end
end
