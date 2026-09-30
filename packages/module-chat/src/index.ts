import type { AppModule, ModuleRuntime } from "@mlx-bun/app-core";
import { createChatSocket, type ChatBackendFactory } from "./backend";
import { describeModel, type ServedModel } from "./describe";
import { createExtensionSurface } from "./extensions";
import { manifest } from "./manifest";
import { startModelBridge, type ModelBridge } from "./model-bridge";
import { createPiBackend } from "./pi-backend";
import { createChatHandlers } from "./routes";

export { manifest } from "./manifest";
export { createChatSocket } from "./backend";
export type { ChatBackend, ChatBackendFactory, SendFrame } from "./backend";
export { describeModel } from "./describe";
export type { ServedModel } from "./describe";
export { createExtensionSurface, piTool } from "./extensions";
export { generateThroughHost, startModelBridge } from "./model-bridge";
export type { ModelBridge } from "./model-bridge";
export { createPiBackend } from "./pi-backend";
export type { PiBackendOptions, PiBackendPaths } from "./pi-backend";
export { createChatHandlers } from "./routes";
export type { ChatRoutePaths } from "./routes";
export { readSessionFile, recordedSessionCwd, sessionEntries } from "./session-files";
export { searchSessions } from "./session-search";
export { isToolAlwaysAllowed, listAlwaysAllowedTools, loadToolApprovals, revokeToolAlwaysAllowed, setToolAlwaysAllowed } from "./tool-approvals";
export type * from "./protocol";

/** What a host decides for the chat beyond its services. */
export interface ChatModuleOptions {
  /** A read-only server: the agent gets no file-changing tool and every gated call is denied. Default false. */
  readOnly?: boolean;
  /** The working directory Pi's tools and the session header record; default the process's. */
  cwd?: string;
}

/** The chat module. The host implements `modelHost` (the current model's `generate`), `storage` (`sessions/`, `pi-sessions/`, `tool-approvals.json`) and `registry`. */
export function createChatModule(options: ChatModuleOptions = {}): AppModule<"modelHost" | "storage" | "registry"> {
  return {
    ...manifest,
    activate({ services }): ModuleRuntime {
      const { modelHost, storage, registry } = services;
      const paths = () => ({ agentDir: storage.path("agent"), sessionDir: storage.path("sessions"), toolApprovalsFile: storage.path("approvals") });
      let bridge: ModelBridge | undefined;
      const token = crypto.randomUUID();
      // The loopback Pi talks to starts with the first chat connection; the port is read when that connection's backend starts.
      const loopback = () => bridge ??= startModelBridge(modelHost, token);
      const surface = createExtensionSurface(registry);
      const factory: ChatBackendFactory = send => {
        // The model is described when the connection starts (its `ready` frame); its speech-to-text flag comes from the same reading.
        let served: ServedModel | undefined;
        return createPiBackend({
          paths: { ...paths(), ...(options.cwd ? { cwd: options.cwd } : {}) },
          port: () => loopback().port, apiKey: token,
          readOnly: options.readOnly ?? false, memory: surface,
          model: async () => {
            served = await describeModel(modelHost);
            return { modelId: served.modelId, contextWindow: served.contextWindow, vision: served.vision, audio: served.audio, thinking: served.thinking, genDefaults: served.genDefaults };
          },
          transcription: async () => served?.transcription ?? false,
        })(send);
      };
      const socket = createChatSocket(factory);
      return {
        routes: createChatHandlers({ sessionDir: () => storage.path("sessions"), approvalsFile: () => storage.path("approvals") }),
        sockets: { chat: socket },
        status: () => ({ chats: socket.connections, loopback: bridge !== undefined }),
        async dispose() {
          try { await socket.dispose(); } finally { await bridge?.close(); }
        },
      };
    },
  };
}

export default createChatModule();
