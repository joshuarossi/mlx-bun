// Shared flag parsing + session loading for the `fill` jobs (K3d).
import { readdirSync, readFileSync, statSync } from "node:fs";
import { prepareSession, type LoadedSession } from "./runner";

export const arg = (name: string, fallback: string | null = null): string | null => {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : fallback;
};
export const flag = (name: string): boolean => process.argv.includes(`--${name}`);
export const num = (name: string, fallback: number): number => {
  const v = arg(name);
  if (v === null) return fallback;
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
};

/** `--sessions <file-or-dir>`: one JSONL transcript, or a directory of them. */
export function loadSessions(pathArg: string): LoadedSession[] {
  const st = statSync(pathArg);
  const files = st.isDirectory()
    ? readdirSync(pathArg).filter((f) => f.endsWith(".jsonl")).sort()
      .map((f) => `${pathArg.replace(/\/$/, "")}/${f}`)
    : [pathArg];
  return files.map((f) =>
    prepareSession(f.split("/").pop()!.replace(/\.jsonl$/, ""), readFileSync(f, "utf8")));
}

/** `--header k=v` (repeatable) → an extra header dict for an arm. */
export function headersFor(names: string[]): Record<string, string> {
  const out: Record<string, string> = {};
  for (const name of names) {
    for (let i = 0; i < process.argv.length; i++) {
      if (process.argv[i] !== `--${name}`) continue;
      const kv = process.argv[i + 1];
      if (!kv) continue;
      const eq = kv.indexOf("=");
      if (eq > 0) out[kv.slice(0, eq)] = kv.slice(eq + 1);
    }
  }
  return out;
}
