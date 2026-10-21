/** Each source's imports that are themselves sources, as source paths. */
export function localImports(sources: ReadonlyMap<string, string>): Map<string, string[]> {
  return new Map([...sources].map(([file, source]) => [file,
    [...source.matchAll(/^import\s+([^\n]+)/gm)]
      .flatMap(match => match[1]!.split(/\s+/))
      .map(name => name.replaceAll(".", "/") + ".lean")
      .filter(path => sources.has(path)),
  ]));
}

/** Build each proof only after its local imports succeed. Wait for every active
 * check before returning, including failures, so temporary output can be removed. */
export async function buildProofs(
  sources: ReadonlyMap<string, string>,
  jobs: number,
  check: (file: string, source: string) => Promise<void>,
): Promise<void> {
  if (!Number.isSafeInteger(jobs) || jobs < 1 || jobs > 64) {
    throw new Error("Proof build jobs must be an integer from 1 to 64.");
  }
  const imports = localImports(sources);
  const pending = new Set(sources.keys());
  const complete = new Set<string>();
  type Outcome = { file: string; ok: true } | { file: string; ok: false; error: unknown };
  const active = new Map<string, Promise<Outcome>>();
  let failure: { error: unknown } | undefined;
  while (pending.size || active.size) {
    if (!failure) {
      for (const file of pending) {
        if (active.size >= jobs) break;
        if (!imports.get(file)!.every(dependency => complete.has(dependency))) continue;
        pending.delete(file);
        const task = Promise.resolve().then(() => check(file, sources.get(file)!));
        active.set(file, task.then<Outcome, Outcome>(
          () => ({ file, ok: true }), error => ({ file, ok: false, error }),
        ));
      }
    }
    if (!active.size) {
      if (failure) throw failure.error;
      throw new Error(`Local proof import cycle: ${[...pending].join(", ")}`);
    }
    const result = await Promise.race(active.values());
    active.delete(result.file);
    if (result.ok) complete.add(result.file);
    else failure ??= { error: result.error };
  }
  if (failure) throw failure.error;
}
