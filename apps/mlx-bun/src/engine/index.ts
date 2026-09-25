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
export * from "./cache-services";

/** Takes ownership of context and beforeModelDispose. Close cancels sessions,
 * drains work, then runs the hook and releases the context. A supplied binding
 * keeps replacement graphs independent of the built-in model classes. No server is started here. */
export async function createAppEngine(context: LoadedModelContext, options: {
  capacity: number; binding?: ModelBinding;
  gateway?: ConstructorParameters<typeof GenerationGateway>[2];
  /** Owned cleanup, invoked once after execution drains and before model release,
   * including construction failure. Use for cache flush and cache disposal. */
  beforeModelDispose?: () => void | Promise<unknown>;
}) {
  let createdGateway: GenerationGateway | undefined;
  try {
    const binding = await modelServingBinding(context, options.binding);
    const gateway = createdGateway = new GenerationGateway(binding.gateway, options.capacity, options.gateway);
    const completion = createSessionCompletionEngine(gateway, disposeUnstartedRequest);
    const preparation = createPreparationExecutor((work, signal) => gateway.runPreparation(work, signal), options.capacity);
    let closing: Promise<void> | undefined;
    return {
      context, binding, gateway, completion, preparation,
      close() {
        return closing ??= (async () => {
          await releaseAll([() => preparation.close(), () => completion.close(),
            () => gateway.close(), () => options.beforeModelDispose?.(), () => context.dispose()]);
        })();
      },
    };
  } catch (error) {
    await releaseAll([() => createdGateway?.close(), () => options.beforeModelDispose?.(),
      () => context.dispose()], [error]);
    throw error;
  }
}

/** Attempt owned asynchronous releases in order, preserving every failure. */
async function releaseAll(releases: readonly (() => void | Promise<unknown>)[], errors: unknown[] = []): Promise<void> {
  for (const release of releases) { try { await release(); } catch (error) { errors.push(error); } }
  if (errors.length === 1) throw errors[0];
  if (errors.length) throw new AggregateError(errors, "app engine cleanup failed");
}
