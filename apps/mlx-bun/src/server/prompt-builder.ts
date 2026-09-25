import type { LoadedModelContext as ModelContext } from "../engine/model-host";
import type { ModelPromptBuilder } from "./prompt-contracts";
export function modelPromptBuilder(context: ModelContext): ModelPromptBuilder {
  return async (body, tools, ownership, prep, nativeWork, objects) => {
    const media = body.messages.some(message => Array.isArray(message.content) && message.content.some(part => part.type !== "text"));
    if (media) {
      const { buildModelPrompt } = await import("./media-prompt");
      return buildModelPrompt(context, prep, body, tools, ownership, nativeWork, objects);
    }
    const text = prep.promptIdsFor(body, tools ?? null);
    return { promptIds: text.ids, vision: undefined, startInThinking: text.startInThinking, probeStableLen: true, diffusionPixels: null };
  };
}
