import { cleanupFailure } from "@mlx-bun/inference/runtime/resources";
import { GenerationGateway, disposeUnstartedRequest } from "./generation-gateway";
import { createSessionCompletionEngine } from "./session-completion-engine";
import { createPreparationExecutor } from "./preparation";
import { modelServingBinding } from "./model-serving";
import type { LoadedModelContext } from "./model-host";
import type { ModelBinding } from "./model-binding";

export * from "./model-host";
export * from "./model-binding";
export * from "./model-serving";
export * from "./generation-gateway";
export * from "./completion";
export * from "./preparation";
export * from "./session-completion-engine";

/** Takes ownership of context. Close cancels sessions, drains work, then releases
 * the context. A supplied binding keeps replacement graphs independent of the
 * built-in model classes. No server is started here. */
export async function createAppEngine(context: LoadedModelContext, options: {
  capacity: number; binding?: ModelBinding;
  gateway?: ConstructorParameters<typeof GenerationGateway>[2];
}) {
  let gateway: GenerationGateway;
  try {
    const binding = await modelServingBinding(context, options.binding);
    gateway = new GenerationGateway(binding.gateway, options.capacity, options.gateway);
    const completion = createSessionCompletionEngine(gateway, disposeUnstartedRequest);
    const preparation = createPreparationExecutor((work, signal) => gateway.runPreparation(work, signal), options.capacity);
    let closing: Promise<void> | undefined;
    return {
      context, binding, gateway, completion, preparation,
      close() {
        return closing ??= (async () => {
          preparation.close();
          try { await completion.close(); }
          finally { try { await gateway.close(); } finally { context.dispose(); } }
        })();
      },
    };
  } catch (error) { return cleanupFailure(error, () => context.dispose()); }
}
