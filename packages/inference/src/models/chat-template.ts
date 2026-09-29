import { ChatTemplate } from "../input/chat-template";
import { chatTemplateFallbackFor, type ResolvedModelProfile } from "./profile";

/** Load the chat template of a resolved model: the artifact's own, else the
 * renderer its profile declares for artifacts that ship none. */
export function loadModelChatTemplate(
  modelDir: string, resolved: ResolvedModelProfile, options: { disableThinking?: boolean } = {},
): Promise<ChatTemplate> {
  return ChatTemplate.load(modelDir, { ...options, fallback: chatTemplateFallbackFor(resolved) ?? undefined });
}
