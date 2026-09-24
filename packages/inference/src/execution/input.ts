import type { ResolvedExecution } from "../contracts/portable/execution";
import type { OnToken } from "../contracts/portable/token-delivery";
import type { GenerateOptions,GenerateStats } from "../generation/types";
import type { PromptResponseTrace } from "../runtime/trace";
export type { OnToken } from "../contracts/portable/token-delivery";

/** The serial lane — exactly today's runGeneration (prompt-cache reuse + the
 *  generate() pipeline). The gateway calls it under the mutex. */
export type SerialRun = (
  promptIds: number[],
  options: GenerateOptions & { stopSequences?: string[] },
  onToken: OnToken,
  vision?: Vision,
  trace?: PromptResponseTrace,
  execution?: ResolvedExecution,
) => Promise<GenerateStats>;

import { Vision } from "../contracts/mlx/media";
