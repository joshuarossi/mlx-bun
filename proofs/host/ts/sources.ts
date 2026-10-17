// Host TypeScript sources embedded verbatim in Lean (`host/ts/sources/`).
// `bun proofs/host/ts/sources.ts` regenerates the modules; SourceBinding.ts
// checks that every embedded literal equals its repository file byte for byte.
import { mkdir } from "node:fs/promises";
import { dirname } from "node:path";
import { pins } from "./SourceBinding.ts";

export const files = () => Object.keys(pins);

const pascal = (s: string) => s.split(/[-_.]/).map(p => p[0]!.toUpperCase() + p.slice(1)).join("");

/** `packages/mlx/src/ops.ts` → `host/ts/sources/mlx/Ops.lean`, module `host.ts.sources.mlx.Ops`. */
export function modulePath(file: string): string {
  const parts = file.replace(/^packages\//, "").replace(/\.ts$/, "").split("/").filter(p => p !== "src");
  return `host/ts/sources/${parts.slice(0, -1).join("/")}/${pascal(parts.at(-1)!)}.lean`;
}

function namespaceOf(file: string): string {
  return "Host.Ts.Sources." + modulePath(file).slice("host/ts/sources/".length, -".lean".length)
    .split("/").map(pascal).join(".");
}

/** Raw-literal delimiter: one more `#` than any `"#…` run in the text. */
export function hashes(text: string): string {
  let n = 0;
  for (const m of text.matchAll(/"(#*)/g)) n = Math.max(n, m[1]!.length);
  return "#".repeat(n + 1);
}

/** The literal between `r<h>"` and `"<h>`, as embedded by `render`. */
export function literalOf(lean: string): string {
  const m = lean.match(/^def source : String := r(#+)"/m);
  if (!m) throw new Error("No source literal");
  const start = m.index! + m[0].length;
  const end = lean.indexOf(`"${m[1]}\n`, start);
  if (end < 0) throw new Error("Unterminated source literal");
  return lean.slice(start, end);
}

export function render(file: string, text: string): string {
  const h = hashes(text);
  return `import host.ts.Source
namespace ${namespaceOf(file)}
set_option maxRecDepth 100000

/-- Verbatim \`${file}\`; \`host/ts/SourceBinding.ts\` checks the bytes. -/
def source : String := r${h}"${text}"${h}

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end ${namespaceOf(file)}
`;
}

if (import.meta.main) {
  const root = new URL("../../../", import.meta.url);
  const only = process.argv.slice(2);
  for (const file of files()) {
    if (only.length && !only.some(o => file.includes(o))) continue;
    const text = await Bun.file(new URL(file, root)).text();
    const out = new URL(`../../${modulePath(file)}`, import.meta.url);
    await mkdir(dirname(out.pathname), { recursive: true });
    await Bun.write(out, render(file, text));
    console.log(modulePath(file));
  }
}
