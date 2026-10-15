/** An executable example's body for a code block: the source without its
 * `import.meta.main` runner. The landing page imports the examples' source at
 * build time and keeps no copy; a file that lost its runner fails the build. */
export function exampleBody(source: string, path: string): string {
  const runner = "\nif (import.meta.main)";
  const end = source.indexOf(runner);
  if (end < 0) throw new Error(`${path}: expected an import.meta.main runner to trim`);
  return `${source.slice(0, end).trimEnd()}\n`;
}
