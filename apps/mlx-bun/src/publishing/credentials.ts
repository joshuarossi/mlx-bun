import { chmodSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { hfToken, type HfTokenOptions } from "@mlx-bun/hub/download";

/** The app owns its saved token. Hub owns the shared environment/cache fallback.
 * Explicit paths and environment isolate embedded consumers and tests. */
export function createHfCredentials(options: HfTokenOptions & { tokenFile?: string } = {}) {
  const environment = () => options.environment ?? process.env;
  const file = () => options.tokenFile ?? join(environment().HOME || homedir(), ".mlx-bun", "hf.json");
  return {
    get(): string | null {
      try {
        const saved: unknown = JSON.parse(readFileSync(file(), "utf8"));
        if (saved && typeof saved === "object" && "token" in saved && typeof saved.token === "string" && saved.token.trim())
          return saved.token.trim();
      } catch { /* Missing or malformed app settings fall back to shared credentials. */ }
      const env = environment();
      return hfToken({ environment: { HOME: env.HOME, HF_TOKEN: env.HF_TOKEN?.trim() || undefined },
        cacheTokenPath: options.cacheTokenPath });
    },
    save(token: string): void {
      const trimmed = token.trim();
      if (!trimmed) throw new Error("saveHfToken: token is empty");
      const target = file();
      mkdirSync(dirname(target), { recursive: true });
      writeFileSync(target, JSON.stringify({ token: trimmed, savedAt: new Date().toISOString() }, null, 2) + "\n", { mode: 0o600 });
      chmodSync(target, 0o600);
    },
  };
}
