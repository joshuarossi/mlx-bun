import type { CliInvocation } from "@mlx-bun/app-core";

export const gb = (bytes: number): string => `${(bytes / 2 ** 30).toFixed(2)} GB`;

/** The verb's string option, or `fallback`. */
export function option(invocation: Pick<CliInvocation, "values">, name: string, fallback: string | null = null): string | null {
  const value = invocation.values[name];
  return typeof value === "string" ? value : fallback;
}
export const flag = (invocation: Pick<CliInvocation, "values">, name: string): boolean => invocation.values[name] === true;

/** Prints lines of the verb's output. */
export const printer = (invocation: Pick<CliInvocation, "stdout">) => (line = "") => { invocation.stdout(line + "\n"); };
