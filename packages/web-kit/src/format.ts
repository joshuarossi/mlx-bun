// Formatting shared by every surface that shows a measurement, so a size, a rate or a duration reads the same on
// the status strip, the Models page and the metrics tables. Missing values read as an em dash, never "undefined".

const NONE = "—";

export const num = (value: number | null | undefined, digits = 0): string =>
  value == null || !Number.isFinite(value) ? NONE : value.toLocaleString(undefined, { maximumFractionDigits: digits, minimumFractionDigits: digits });

export const gb = (bytes: number | null | undefined, digits = 1): string => bytes == null ? NONE : `${(bytes / 2 ** 30).toFixed(digits)} GB`;
export const mb = (bytes: number | null | undefined, digits = 1): string => bytes == null ? NONE : `${(bytes / 2 ** 20).toFixed(digits)} MB`;

/** The largest unit that keeps the number short: 371 GB, 612 MB, 41 KB, 12 B. */
export function bytes(value: number | null | undefined): string {
  if (value == null || !Number.isFinite(value)) return NONE;
  if (value >= 2 ** 30) return `${(value / 2 ** 30).toFixed(value >= 10 * 2 ** 30 ? 1 : 2)} GB`;
  if (value >= 2 ** 20) return `${(value / 2 ** 20).toFixed(0)} MB`;
  if (value >= 2 ** 10) return `${(value / 2 ** 10).toFixed(0)} KB`;
  return `${Math.round(value)} B`;
}

/** Milliseconds as a duration: 410 ms, 1.25 s, 2.4 min. */
export function ms(value: number | null | undefined): string {
  if (value == null || !Number.isFinite(value)) return NONE;
  if (value >= 90_000) return `${(value / 60_000).toFixed(1)} min`;
  if (value >= 1000) return `${(value / 1000).toFixed(2)} s`;
  return `${value.toFixed(0)} ms`;
}

/** Seconds of uptime: 42 s, 18 min, 1.5 h, 3.2 d. */
export function uptime(seconds: number | null | undefined): string {
  if (seconds == null || !Number.isFinite(seconds)) return NONE;
  if (seconds < 90) return `${Math.round(seconds)} s`;
  if (seconds < 5400) return `${Math.round(seconds / 60)} min`;
  if (seconds < 172_800) return `${(seconds / 3600).toFixed(1)} h`;
  return `${(seconds / 86_400).toFixed(1)} d`;
}

/** Tokens per second, with two decimals under 10. */
export const rate = (value: number | null | undefined): string =>
  value == null || !Number.isFinite(value) ? NONE : `${value.toFixed(value < 10 ? 2 : 1)} tok/s`;

/** A fraction as a percentage: 0.62 reads 62%. */
export const percent = (fraction: number | null | undefined, digits = 0): string =>
  fraction == null || !Number.isFinite(fraction) ? NONE : `${(fraction * 100).toFixed(digits)}%`;

/** Token counts the way the composer shows them: 1.2k, 33k, 1.5M. */
export function tokens(value: number | null | undefined): string {
  if (value == null || !Number.isFinite(value)) return NONE;
  if (value >= 1e6) return `${(value / 1e6).toFixed(1)}M`;
  if (value >= 1e3) return `${(value / 1e3).toFixed(value >= 1e4 ? 0 : 1)}k`;
  return String(Math.round(value));
}

/** How long ago an epoch-millisecond time was: just now, 5 min ago, 3 h ago, yesterday, 4 d ago, then a date. */
export function relativeTime(at: number | null | undefined, now = Date.now()): string {
  if (at == null || !Number.isFinite(at)) return NONE;
  const seconds = Math.max(0, (now - at) / 1000);
  if (seconds < 45) return "just now";
  if (seconds < 3600) return `${Math.round(seconds / 60)} min ago`;
  if (seconds < 86_400) return `${Math.round(seconds / 3600)} h ago`;
  const days = Math.floor(seconds / 86_400);
  if (days < 2) return "yesterday";
  if (days < 30) return `${days} d ago`;
  try { return new Date(at).toLocaleDateString(); } catch { return NONE; }
}

/** The repository's own name without its namespace: `mlx-community/Qwen3-8B-4bit` reads `Qwen3-8B-4bit`. */
export const shortName = (repoId: string): string => repoId.split("/").pop() || repoId;
