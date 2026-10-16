import { readFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { join } from "node:path";

/** Read the user-supplied Strata checkout. Keep its experimental kernels out
 * of the library and record the exact source used in the screen. */
export function strataSource(root: string, file: string) {
  const source = readFileSync(join(root, "metal/kernels", file), "utf8");
  return { source, sha256: createHash("sha256").update(source).digest("hex") };
}
export function body(source: string, name: string): string {
  const start = source.indexOf(`kernel void ${name}(`);
  if (start < 0) throw new Error(`Strata source has no kernel ${name}`);
  const brace = source.indexOf("{", start);
  let level = 1, end = brace + 1;
  while (level && end < source.length) {
    if (source[end] === "{") ++level;
    else if (source[end] === "}") --level;
    ++end;
  }
  if (level) throw new Error(`Unbalanced source for ${name}`);
  return source.slice(brace + 1, end - 1);
}

/** Source adaptations must match once; in particular, a missed state-write
 * adaptation must never turn an immutable MLX input into in-place storage. */
export function replaceOnce(source: string, from: string, to: string): string {
  if (source.split(from).length !== 2) throw new Error(`Strata source adaptation needs exactly one match: ${from}`);
  return source.replace(from, to);
}
