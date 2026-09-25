import type { ChatMessage, ChatTemplate, LoadedTokenizer } from "@mlx-bun/inference/input";

/** Template rendering shared by app surfaces. CLI excludes tokenizer-added
 * specials; HTTP preserves its existing encoding and duplicate-BOS correction. */
export function textPrompt(template: ChatTemplate, tokenizer: LoadedTokenizer,
  messages: ChatMessage[], options: Parameters<ChatTemplate["render"]>[1],
  addSpecialTokens?: boolean): { rendered: string; ids: number[] } {
  const rendered = template.render(messages, options);
  const ids = addSpecialTokens === undefined ? tokenizer.encode(rendered) : tokenizer.encode(rendered, addSpecialTokens);
  return { rendered, ids: addSpecialTokens === undefined && ids[0] === ids[1] && ids[0] === tokenizer.bosTokenId
    ? ids.slice(1) : ids };
}
