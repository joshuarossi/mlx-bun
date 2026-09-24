import { copyFile, mkdir, stat } from "node:fs/promises";
import { join, resolve } from "node:path";
import { NATIVE_DIR, NATIVE_FILES } from "../src/native";

// Supply a built native directory to stage it, or omit it to validate before packing.
const source = resolve(process.argv[2] ?? NATIVE_DIR);
for (const name of NATIVE_FILES) {
  const path = join(source, name);
  const info = await stat(path).catch(() => null);
  if (!info?.isFile() || info.size === 0) {
    throw new Error(`Missing native artifact: ${path}. Build and stage the native inference support first.`);
  }
}
if (source !== resolve(NATIVE_DIR)) {
  await mkdir(NATIVE_DIR, { recursive: true });
  for (const name of NATIVE_FILES) {
    await copyFile(join(source, name), join(NATIVE_DIR, name));
  }
}
console.log(`Native inference support ready: ${NATIVE_DIR}`);
