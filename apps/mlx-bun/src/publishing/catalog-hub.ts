import type { CatalogHub } from "@mlx-bun/app-services";
import { createHfCredentials } from "./credentials";
import { createPublisher } from "./upload";

/** The Hub side of the model catalog: downloads through the hub library, and pushes with the app's saved token. */
export function createCatalogHub(credentials: Pick<ReturnType<typeof createHfCredentials>, "get"> = createHfCredentials()): CatalogHub {
  const publish = createPublisher({ credentials, getJob: () => null });
  return {
    // The hub download honors the signal at every checkpoint and keeps the blob's .incomplete prefix resumable.
    async download(id, { signal, onProgress }) {
      const { downloadModel } = await import("@mlx-bun/hub/download");
      return downloadModel(id, { onProgress, signal });
    },
    canPublish: () => credentials.get() !== null,
    publish: (directory, { repoId, signal }) => publish({ kind: "quantize", repoId, sourcePath: directory, signal }),
  };
}
