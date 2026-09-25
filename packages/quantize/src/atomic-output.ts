import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  renameSync,
  rmdirSync,
  rmSync,
  statSync,
} from "node:fs";
import { basename, dirname, join, resolve } from "node:path";

/** Build a complete directory beside its destination, then publish it with a
 * single same-filesystem rename. Failed writers leave no partial destination. */
export async function writeAtomicDirectory<T>(
  outDir: string,
  write: (stagingDir: string) => Promise<T>,
): Promise<T> {
  const destination = resolve(outDir);
  const replaceEmptyDestination = existsSync(destination);
  if (
    replaceEmptyDestination &&
    (!statSync(destination).isDirectory() || readdirSync(destination).length !== 0)
  ) throw new Error(`output directory already exists: ${outDir}`);

  const parent = dirname(destination);
  mkdirSync(parent, { recursive: true });
  const staging = mkdtempSync(join(parent, `.${basename(destination)}.tmp-`));
  try {
    const result = await write(staging);
    if (replaceEmptyDestination) rmdirSync(destination);
    renameSync(staging, destination);
    return result;
  } catch (error) {
    rmSync(staging, { recursive: true, force: true });
    throw error;
  }
}
