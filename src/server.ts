// OpenAI-compatible HTTP server: /v1/chat/completions (+ SSE streaming)
// and /v1/models. Phase 4 core — tool calling, vision, and the
// byte-capped prompt cache land on top of this.
//
// Generation is serialized through a single queue (one GPU, batch=1).

import type { Server } from "bun";
import { loadModelConfig } from "./config";
import { Weights } from "./weights";
import { Gemma4Model } from "./model/gemma4";
import { generate, type GenerateOptions } from "./generate";
import { ChatTemplate, type ChatMessage } from "./chat-template";
import { loadTokenizer, type LoadedTokenizer } from "./tokenizer";

export interface ServerContext {
  model: Gemma4Model;
  tokenizer: LoadedTokenizer;
  template: ChatTemplate;
  modelId: string;
}

export async function loadContext(modelDir: string, modelId?: string): Promise<ServerContext> {
  const config = await loadModelConfig(modelDir);
  const weights = await Weights.open(modelDir);
  return {
    model: new Gemma4Model(weights, config),
    tokenizer: await loadTokenizer(modelDir),
    template: await ChatTemplate.load(modelDir),
    modelId: modelId ?? modelDir.split("/").filter(Boolean).at(-1)!,
  };
}

interface ChatRequest {
  messages: ChatMessage[];
  stream?: boolean;
  max_tokens?: number;
  max_completion_tokens?: number;
  temperature?: number;
  top_p?: number;
  top_k?: number;
  seed?: number;
  repetition_penalty?: number;
}

/** Incremental detokenizer: emits the longest stable decoded prefix. */
class StreamDecoder {
  #ids: number[] = [];
  #emitted = "";

  constructor(readonly tokenizer: LoadedTokenizer) {}

  push(token: number): string {
    this.#ids.push(token);
    const full = this.tokenizer.decode(this.#ids, true);
    // hold back a trailing replacement char (partial multi-byte sequence)
    const stable = full.endsWith("�") ? full.slice(0, -1) : full;
    if (!stable.startsWith(this.#emitted)) {
      // decoder revised earlier text (rare); re-emit from scratch
      const out = stable;
      this.#emitted = stable;
      return out;
    }
    const delta = stable.slice(this.#emitted.length);
    this.#emitted = stable;
    return delta;
  }

  flush(): string {
    const full = this.tokenizer.decode(this.#ids, true);
    const delta = full.slice(this.#emitted.length);
    this.#emitted = full;
    return delta;
  }
}

export function createServer(ctx: ServerContext, port = 0): Server<unknown> {
  let queue: Promise<unknown> = Promise.resolve();
  const enqueue = <T>(fn: () => Promise<T>): Promise<T> => {
    const run = queue.then(fn, fn);
    queue = run.catch(() => {});
    return run;
  };

  const toOptions = (req: ChatRequest): GenerateOptions => ({
    maxTokens: req.max_completion_tokens ?? req.max_tokens ?? 1024,
    temperature: req.temperature ?? 0.7,
    topP: req.top_p ?? 0,
    topK: req.top_k ?? 0,
    seed: req.seed ?? (Date.now() & 0xffffffff),
    repetitionPenalty: req.repetition_penalty,
  });

  const promptIdsFor = (messages: ChatMessage[]): number[] => {
    const rendered = ctx.template.render(messages);
    const ids = ctx.tokenizer.encode(rendered);
    // template includes <bos>; tokenizer post-processor also prepends one
    return ids[0] === ids[1] && ids[0] === ctx.tokenizer.bosTokenId ? ids.slice(1) : ids;
  };

  return Bun.serve({
    port,
    idleTimeout: 0,
    async fetch(request) {
      const url = new URL(request.url);

      if (url.pathname === "/v1/models" && request.method === "GET") {
        return Response.json({
          object: "list",
          data: [{ id: ctx.modelId, object: "model", created: 0, owned_by: "mlx-bun" }],
        });
      }

      if (url.pathname === "/v1/chat/completions" && request.method === "POST") {
        let body: ChatRequest;
        try {
          body = (await request.json()) as ChatRequest;
        } catch {
          return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
        }
        if (!Array.isArray(body.messages) || body.messages.length === 0)
          return Response.json({ error: { message: "messages required" } }, { status: 400 });

        const id = `chatcmpl-${crypto.randomUUID()}`;
        const created = Math.floor(Date.now() / 1000);
        let promptIds: number[];
        try {
          promptIds = promptIdsFor(body.messages);
        } catch (e) {
          return Response.json(
            { error: { message: `template render failed: ${(e as Error).message}` } },
            { status: 400 },
          );
        }
        const options = toOptions(body);

        if (body.stream) {
          const stream = new ReadableStream<Uint8Array>({
            async start(controller) {
              const enc = new TextEncoder();
              const send = (obj: unknown) =>
                controller.enqueue(enc.encode(`data: ${JSON.stringify(obj)}\n\n`));
              const chunk = (delta: Record<string, unknown>, finish: string | null) => ({
                id, object: "chat.completion.chunk", created, model: ctx.modelId,
                choices: [{ index: 0, delta, finish_reason: finish }],
              });
              try {
                await enqueue(async () => {
                  send(chunk({ role: "assistant", content: "" }, null));
                  const decoder = new StreamDecoder(ctx.tokenizer);
                  const gen = generate(ctx.model, promptIds, options);
                  for await (const t of gen) {
                    const text = decoder.push(t.token);
                    if (text) send(chunk({ content: text }, null));
                  }
                  const tail = decoder.flush();
                  if (tail) send(chunk({ content: tail }, null));
                  const s = gen.stats!;
                  const finish = s.generatedTokens >= (options.maxTokens ?? 1024) ? "length" : "stop";
                  send({
                    ...chunk({}, finish),
                    usage: {
                      prompt_tokens: s.promptTokens,
                      completion_tokens: s.generatedTokens,
                      total_tokens: s.promptTokens + s.generatedTokens,
                    },
                  });
                  send("[DONE]");
                });
              } catch (e) {
                send({ error: { message: (e as Error).message } });
              } finally {
                controller.close();
              }
            },
          });
          return new Response(stream, {
            headers: {
              "content-type": "text/event-stream",
              "cache-control": "no-cache",
              connection: "keep-alive",
            },
          });
        }

        try {
          return await enqueue(async () => {
            const out: number[] = [];
            const gen = generate(ctx.model, promptIds, options);
            for await (const t of gen) out.push(t.token);
            const s = gen.stats!;
            const finish = s.generatedTokens >= (options.maxTokens ?? 1024) ? "length" : "stop";
            return Response.json({
              id, object: "chat.completion", created, model: ctx.modelId,
              choices: [{
                index: 0,
                message: { role: "assistant", content: ctx.tokenizer.decode(out, true) },
                finish_reason: finish,
              }],
              usage: {
                prompt_tokens: s.promptTokens,
                completion_tokens: s.generatedTokens,
                total_tokens: s.promptTokens + s.generatedTokens,
              },
            });
          });
        } catch (e) {
          return Response.json({ error: { message: (e as Error).message } }, { status: 500 });
        }
      }

      return Response.json({ error: { message: "not found" } }, { status: 404 });
    },
  });
}
