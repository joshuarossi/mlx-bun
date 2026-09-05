import { AsyncLocalStorage } from "node:async_hooks";

export type RuntimeKey = `MLX_BUN_${string}`;
export type RuntimeOverrides = Readonly<Partial<Record<RuntimeKey, string | undefined>>>;

export interface RuntimeConfig {
  readonly values: Readonly<Record<string, string | undefined>>;
  value(name: RuntimeKey): string | undefined;
  flag(name: RuntimeKey, defaultOn: boolean): boolean;
  number(name: RuntimeKey, fallback: number): number;
}

/** Build one immutable runtime snapshot. Only mlx-bun-owned keys cross this
 *  boundary; feature code never reads or mutates process.env. */
export function createRuntimeConfig(
  source: Readonly<Record<string, string | undefined>>,
): RuntimeConfig {
  const values = Object.freeze(Object.fromEntries(
    Object.entries(source).filter(([key, value]) =>
      key.startsWith("MLX_BUN_") && value !== undefined),
  ));
  return Object.freeze({
    values,
    value: (name: RuntimeKey) => values[name],
    flag: (name: RuntimeKey, defaultOn: boolean) => {
      const value = values[name];
      return value === "1" ? true : value === "0" ? false : defaultOn;
    },
    number: (name: RuntimeKey, fallback: number) => {
      const value = values[name];
      if (value === undefined) return fallback;
      const parsed = Number(value);
      return Number.isFinite(parsed) ? parsed : fallback;
    },
  });
}

let active = createRuntimeConfig(process.env);
const executionConfig = new AsyncLocalStorage<RuntimeConfig>();

/** Legacy kernels read through this port. A bound execution sees its own
 * immutable snapshot across awaits, independently of later host settings. */
export function withRuntimeConfig<T>(config: RuntimeConfig, run: () => T): T {
  return executionConfig.getStore() === config ? run() : executionConfig.run(config, run);
}

export function runtimeConfig(): RuntimeConfig {
  return executionConfig.getStore() ?? active;
}

export function runtimeValue(name: RuntimeKey): string | undefined {
  return runtimeConfig().value(name);
}

/** On/off env flag: an explicit "1"/"0" always wins; otherwise `defaultOn`.
 *  (Formerly src/flags.ts `flagOn` — same resolver, one module.) */
export function flagOn(name: RuntimeKey, defaultOn: boolean): boolean {
  return runtimeFlag(name, defaultOn);
}
export function runtimeFlag(name: RuntimeKey, defaultOn: boolean): boolean {
  return runtimeConfig().flag(name, defaultOn);
}

export function runtimeNumber(name: RuntimeKey, fallback: number): number {
  return runtimeConfig().number(name, fallback);
}

export function runtimeKey(name: string): RuntimeKey {
  if (!name.startsWith("MLX_BUN_"))
    throw new Error(`runtime flag must start with MLX_BUN_ (got ${name})`);
  return name as RuntimeKey;
}

/** Replace selected values by installing a new frozen snapshot. The CLI uses
 *  this once while resolving flags; tests may use the returned restore hook.
 *  No environment mutation is involved. */
export function configureRuntime(overrides: RuntimeOverrides): () => void {
  const previous = active;
  active = createRuntimeConfig({ ...previous.values, ...overrides });
  return () => { active = previous; };
}
