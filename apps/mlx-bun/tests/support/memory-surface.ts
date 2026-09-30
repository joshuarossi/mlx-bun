// What a chat session is built with when memory is the contributor: memory's module registers its tools and
// guidance through the registry, and the chat module reads them back as its session surface. Nothing here
// names memory from the chat side; the two meet only in the host's registry.
import { loadModules } from "@mlx-bun/app-host";
import { createExtensionSurface } from "@mlx-bun/module-chat";
import { createMemoryChatModule, type MemoryChatPaths } from "@mlx-bun/module-memory/chat";

export async function memorySurface(paths: MemoryChatPaths) {
  const loaded = await loadModules([createMemoryChatModule(paths)], { services: {} });
  const surface = createExtensionSurface(loaded.registry);
  return { surface, stop: () => loaded.stop() };
}
