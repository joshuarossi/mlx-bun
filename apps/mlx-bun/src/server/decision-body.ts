import { gunzipSync, zstdDecompressSync } from "node:zlib";
import { RequestError } from "./pipeline";

const MAX_BYTES = 32 * 1024 * 1024;
/** Preserve compressed and multipart bodies through model routing. The same
 * parser finds the routing id and reads the final decision handler's input. */
export async function readDecisionBody(request: Request): Promise<unknown> {
  const contentType = request.headers.get("content-type") ?? "application/json";
  const encoding = request.headers.get("content-encoding")?.trim().toLowerCase();
  const reader = request.body?.getReader(), chunks: Uint8Array[] = [];
  let length = 0;
  if (reader) try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      length += value.length;
      if (length > MAX_BYTES) { await reader.cancel(); throw new RequestError(413, "decision body exceeds 32 MiB"); }
      chunks.push(value);
    }
  } finally { reader.releaseLock(); }
  let bytes: Uint8Array = Buffer.concat(chunks, length);
  try {
    if (encoding === "gzip" || encoding === "x-gzip") bytes = gunzipSync(bytes, { maxOutputLength: MAX_BYTES });
    else if (encoding === "zstd") bytes = zstdDecompressSync(bytes, { maxOutputLength: MAX_BYTES });
    else if (encoding && encoding !== "identity") throw new RequestError(415, `unsupported Content-Encoding: ${encoding}`);
  } catch (error) {
    if (error instanceof RequestError) throw error;
    if ((error as { code?: string }).code === "ERR_BUFFER_TOO_LARGE") throw new RequestError(413, "decompressed decision body exceeds 32 MiB");
    throw new RequestError(400, "malformed compressed decision body");
  }
  try {
    if (contentType.toLowerCase().startsWith("multipart/form-data")) {
      const form = await new Response(new Uint8Array(bytes), { headers: { "content-type": contentType } }).formData();
      const payload = form.get("request");
      if (!payload) throw new Error("multipart body needs a request part");
      const body = JSON.parse(typeof payload === "string" ? payload : await payload.text());
      const used = new Set<string>(["request"]);
      for (const asset of Object.values(body.assets ?? {}) as Record<string, unknown>[]) {
        if (typeof asset?.part !== "string") continue;
        if (used.has(asset.part)) throw new Error("duplicate image part");
        used.add(asset.part);
        const image = form.get(asset.part);
        if (!(image instanceof File)) throw new Error("missing image part");
        asset.format = asset.format ?? (image.type === "image/png" ? "png" : "jpg");
        asset.data_base64 = Buffer.from(await image.arrayBuffer()).toString("base64");
        delete asset.part;
      }
      if ([...form.keys()].some(key => !used.has(key)) || [...form.keys()].length !== used.size) throw new Error("unused or duplicate multipart part");
      return body;
    }
    const json = new TextDecoder("utf-8", { fatal: true }).decode(bytes);
    if (bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf) throw new Error("JSON BOM is unsupported");
    return JSON.parse(json);
  } catch (error) { throw new RequestError(400, error instanceof Error ? error.message : "invalid decision JSON body"); }
}
