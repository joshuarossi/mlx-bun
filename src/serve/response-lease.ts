import type { DisposableResource } from "../contracts/resources";

/** Keep host activity owned through response EOF/error/cancel, without buffering
 * the response. The parent additionally drains worker cleanup before GPU jobs. */
export function retainResponseLease(response: Response, lease: DisposableResource): Response {
  if (!response.body) { lease.dispose(); return response; }
  const reader = response.body.getReader();
  let closed = false;
  const release = () => {
    if (closed) return;
    closed = true;
    reader.releaseLock(); lease.dispose();
  };
  return new Response(new ReadableStream<Uint8Array>({
    async pull(controller) {
      try {
        const item = await reader.read();
        if (item.done) { release(); controller.close(); }
        else controller.enqueue(item.value);
      } catch (error) { release(); controller.error(error); }
    },
    async cancel(reason) { try { await reader.cancel(reason); } finally { release(); } },
  }), { status: response.status, statusText: response.statusText, headers: response.headers });
}
