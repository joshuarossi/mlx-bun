// Native runtime pack (decision 2026-06-12, "one binary" discussion):
// the mlx-bun executable ships alone (~61 MB, 100% our code + Bun); the
// MLX native runtime (libmlx, libmlxc, libjaccl, mlx.metallib) is a
// separate versioned tarball downloaded ON FIRST RUN into
// ~/Library/Caches/mlx-bun/native-v<ver>-<arch>/ — resumable and
// sha256-verified through the same downloadOne machinery as model
// downloads, visible on the status page /downloads tracker.
//
// Resolution order for the libs (mirrored in src/mlx/ffi.ts):
//   MLX_BUN_LIBMLXC env > beside the executable (sidecar dist/ layout,
//   docs/embedding.md) > the native-pack cache dir > homebrew.
// Dev trees and embedders therefore never download anything.

import { existsSync, mkdirSync, renameSync, rmSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { downloadOne } from "./download";

export const NATIVE_PACK_VERSION = "0.1.0";
export const NATIVE_PACK_FILES = [
  "libmlxc.dylib", "libmlx.dylib", "libjaccl.dylib", "mlx.metallib",
] as const;

const SHA256: Record<string, string> = {
  arm64: "90fa6a85bae648910bb957df3757270d581caf3294a06fb5195b44c5937d99da",
};
const SIZE: Record<string, number> = {
  arm64: 52_300_530,
};

export function nativePackName(arch = process.arch): string {
  return `mlx-bun-native-v${NATIVE_PACK_VERSION}-${arch}.tar.gz`;
}

/** GitHub release asset; override with MLX_BUN_NATIVE_PACK_URL. While
 *  the repo is private the download needs a token (GITHUB_TOKEN or
 *  `gh auth token`); once public it works anonymously. */
export function nativePackUrl(arch = process.arch): string {
  return process.env.MLX_BUN_NATIVE_PACK_URL ??
    `https://github.com/joshuarossi/mlx-bun/releases/download/native-v${NATIVE_PACK_VERSION}/${nativePackName(arch)}`;
}

export function nativePackDir(arch = process.arch): string {
  return join(homedir(), "Library", "Caches", "mlx-bun", `native-v${NATIVE_PACK_VERSION}-${arch}`);
}

/** Where the native runtime currently resolves from, or null if absent
 *  everywhere (= a fresh machine that needs the pack). */
export function nativeRuntimeDir(): string | null {
  if (process.env.MLX_BUN_LIBMLXC) return dirname(process.env.MLX_BUN_LIBMLXC);
  const candidates = [
    dirname(process.execPath),
    nativePackDir(),
    "/opt/homebrew/lib",
    "/usr/local/lib",
  ];
  for (const dir of candidates)
    if (existsSync(join(dir, "libmlxc.dylib"))) return dir;
  return null;
}

async function githubToken(): Promise<string | null> {
  if (process.env.GITHUB_TOKEN) return process.env.GITHUB_TOKEN;
  try {
    const proc = Bun.spawn(["gh", "auth", "token"], { stdout: "pipe", stderr: "ignore" });
    const out = (await new Response(proc.stdout).text()).trim();
    return (await proc.exited) === 0 && out ? out : null;
  } catch {
    return null;
  }
}

/** Map a github.com/<o>/<r>/releases/download/<tag>/<name> URL to a
 *  presigned asset URL via the API. Returns null when no token is
 *  available or the lookup fails (caller falls back to the plain URL,
 *  which works for public repos). */
async function resolveGithubAssetUrl(url: string): Promise<string | null> {
  const m = /^https:\/\/github\.com\/([^/]+)\/([^/]+)\/releases\/download\/([^/]+)\/(.+)$/.exec(url);
  const token = await githubToken();
  if (!m || !token) return null;
  try {
    const [, owner, repo, tag, name] = m;
    const rel = await fetch(`https://api.github.com/repos/${owner}/${repo}/releases/tags/${tag}`, {
      headers: { authorization: `Bearer ${token}`, accept: "application/vnd.github+json" },
    });
    if (!rel.ok) return null;
    const assets = ((await rel.json()) as { assets: Array<{ name: string; url: string }> }).assets;
    const asset = assets.find((a) => a.name === name);
    if (!asset) return null;
    const head = await fetch(asset.url, {
      redirect: "manual",
      headers: { authorization: `Bearer ${token}`, accept: "application/octet-stream" },
    });
    return head.headers.get("location"); // presigned; no auth needed past here
  } catch {
    return null;
  }
}

export interface EnsureNativeOptions {
  url?: string;
  sha256?: string;
  sizeBytes?: number;
  destDir?: string;
  onProgress?: (received: number, total: number) => void;
}

/** Make the native runtime available; returns its directory. No-op when
 *  any resolution candidate already has it. */
export async function ensureNativeRuntime(opts: EnsureNativeOptions = {}): Promise<string> {
  const existing = nativeRuntimeDir();
  if (existing && !opts.destDir) return existing;

  const arch = process.arch;
  const url = opts.url ?? nativePackUrl(arch);
  const sha256 = opts.sha256 ?? SHA256[arch];
  const sizeBytes = opts.sizeBytes ?? SIZE[arch];
  const destDir = opts.destDir ?? nativePackDir(arch);
  if (existsSync(join(destDir, "libmlxc.dylib"))) return destDir;
  if (!sha256 || !sizeBytes)
    throw new Error(`no native pack published for ${arch} — set MLX_BUN_LIBMLXC or install mlx via homebrew`);

  const tarPath = join(tmpdir(), `mlx-bun-native-${sha256.slice(0, 12)}.tar.gz`);
  let fetchUrl = url;
  let token: string | null = null;
  if (url.startsWith("https://github.com/")) {
    // Public repo: the releases/download URL works anonymously. Private
    // repo: it 404s — resolve the asset's signed URL via the API
    // (Accept: octet-stream + token → 302 with a presigned location).
    const resolved = await resolveGithubAssetUrl(url);
    if (resolved) fetchUrl = resolved;
    else token = await githubToken(); // public-repo path; token unused but harmless
  }
  await downloadOne(fetchUrl, token, tarPath, { size: sizeBytes, sha256, name: nativePackName(arch) },
    (_file, received, total) => opts.onProgress?.(received, total));

  // Extract to a staging dir, then rename into place (atomic-ish: a
  // crashed extract never leaves a half-populated cache dir).
  const staging = `${destDir}.staging-${process.pid}`;
  rmSync(staging, { recursive: true, force: true });
  mkdirSync(staging, { recursive: true });
  const untar = Bun.spawn(["tar", "-xzf", tarPath, "-C", staging], { stderr: "pipe" });
  if ((await untar.exited) !== 0)
    throw new Error(`native pack extract failed: ${await new Response(untar.stderr).text()}`);
  for (const f of NATIVE_PACK_FILES)
    if (!existsSync(join(staging, f))) throw new Error(`native pack missing ${f}`);
  rmSync(destDir, { recursive: true, force: true });
  mkdirSync(dirname(destDir), { recursive: true });
  renameSync(staging, destDir);
  rmSync(tarPath, { force: true });
  return destDir;
}
