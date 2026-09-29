import { Glm52Model } from "../../models/glm52/model";
import type { DraftProvider } from "./source";
import { Glm52NativeMtpProvider } from "./sources/glm52-mtp-source";

/** The draft provider for a checkpoint-native draft head, over the model that
 * carries it. `OpenedRuntime.nativeDraftTokens` says whether one is planned. */
export function nativeDraftProvider(model: object): DraftProvider {
  if (model instanceof Glm52Model) return new Glm52NativeMtpProvider(model);
  throw new TypeError("this model has no checkpoint-native draft head");
}
