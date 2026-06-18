# Homebrew formula for mlx-bun — source of truth.
#
# This file lives in the main repo for review/version control. To publish,
# copy it to the TAP repo at  joshuarossi/homebrew-mlx-bun/Formula/mlx-bun.rb
# and push. Users then install with:
#
#   brew install joshuarossi/mlx-bun/mlx-bun
#
# After each release, update `version`, `url`, and `sha256` from the values
# scripts/release-binary.sh prints.
class MlxBun < Formula
  desc "Native MLX inference for Bun on Apple Silicon — local LLM server + TS library"
  homepage "https://github.com/joshuarossi/mlx-bun"
  version "0.0.4"
  url "https://github.com/joshuarossi/mlx-bun/releases/download/v0.0.4/mlx-bun-v0.0.4-arm64.tar.gz"
  sha256 "142eb420b1a708ac0a948d4db5f747c5502963c6c60145245245ff1b3b17b24c"
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
