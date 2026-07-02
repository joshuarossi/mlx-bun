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
  version "0.0.9"
  url "https://github.com/joshuarossi/mlx-bun/releases/download/v0.0.9/mlx-bun-v0.0.9-arm64.tar.gz"
  sha256 "17b1ff81ef203a83ffd37c8b63aced6e7433e5dd87a8ed01bcae8fb47aea0b7a"
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
