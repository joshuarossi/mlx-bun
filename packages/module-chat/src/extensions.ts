// What other modules contribute to a chat session through the registry: their tools (`chat.tool`)
// and the guidance for them (`chat.guidance`: a prompt hint and a skill). Read when each session is
// built, so a contributor that activates later, or whose tools become available later (a memory
// vault created after startup), is seen by the next chat. The chat never names a contributor.
import { defineTool } from "@earendil-works/pi-coding-agent";
import type { TSchema } from "typebox";
import type { ChatToolContribution, Registry } from "@mlx-bun/app-core";
import type { MemorySurface } from "./surface";

const available = async (contribution: { available?(): boolean | Promise<boolean> }): Promise<boolean> => {
  try { return await contribution.available?.() ?? true; } catch { return false; }
};

/** A contributed tool as a Pi tool definition: the same name, schema and text result, run with the turn's abort signal. */
export function piTool(contribution: ChatToolContribution) {
  return defineTool({
    name: contribution.name,
    label: contribution.label ?? contribution.name,
    description: contribution.description,
    parameters: contribution.parameters as unknown as TSchema,
    execute: async (_id, params, signal) => ({
      content: [{ type: "text" as const, text: await contribution.run(params as Record<string, unknown>, signal ?? new AbortController().signal) }],
      details: {},
    }),
  });
}

/** The registry's tools and guidance as the surface a session is built with; undefined when nothing is available. Only tools that attest `readOnly` are offered. */
export function createExtensionSurface(registry: Pick<Registry, "list">): () => Promise<MemorySurface | undefined> {
  return async () => {
    const tools = (await Promise.all(registry.list("chat.tool").map(async entry =>
      entry.contribution.readOnly === true && await available(entry.contribution) ? [entry.contribution] : []))).flat();
    const guidance = (await Promise.all(registry.list("chat.guidance").map(async entry => await available(entry.contribution) ? [entry.contribution] : []))).flat();
    if (!tools.length) return undefined;
    const skillPaths: string[] = [], hints: string[] = [];
    for (const item of guidance) {
      const path = await item.skillPath?.();
      if (path && !skillPaths.includes(path)) skillPaths.push(path);
      const hint = await item.hint?.();
      if (hint) hints.push(hint);
    }
    return { readOnly: true, toolNames: tools.map(tool => tool.name), customTools: tools.map(piTool), skillPaths, hint: hints.join("") };
  };
}
