// Response helpers shared by the module's handlers: the JSON envelopes the routes have always answered with.

/** The `{ ok: false, error }` envelope the hub, cache-cleanup and artifact routes use. */
export const jsonError = (error: string, status = 400): Response => Response.json({ ok: false, error }, { status });

/** The OpenAI-style envelope the adapter routes use. */
export const openAiError = (message: string, status = 400): Response => Response.json({ error: { message } }, { status });

export const errorMessage = (error: unknown): string => error instanceof Error ? error.message : String(error);

/** A cancelled request is a 499; anything else that got this far is a server error, logged with its stack. */
export function failure(error: unknown, context: string, signal: AbortSignal): Response {
  if (signal.aborted) return jsonError("request cancelled", 499);
  console.error(`[models] 500 on ${context}:\n${error instanceof Error ? error.stack ?? errorMessage(error) : errorMessage(error)}`);
  return jsonError(errorMessage(error), 500);
}

/** A JSON object body, or undefined when the body is not one. */
export async function objectBody(request: Request): Promise<Record<string, unknown> | undefined> {
  const body: unknown = await request.json().catch(() => undefined);
  return body && typeof body === "object" && !Array.isArray(body) ? body as Record<string, unknown> : undefined;
}
