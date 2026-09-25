import type { AgentSessionEvent } from "@earendil-works/pi-coding-agent";
import type { ServerMessage } from "./protocol";

/**
 * Translate one pi AgentSessionEvent into zero or more WS frames.
 *
 * Pure and side-effect-free so it can be unit-tested without a live
 * session. The approval gate is handled separately (in the tool_call
 * extension handler), so the tool_execution_start event here simply
 * renders the tool card; it does not itself request approval.
 *
 * Returns [] for events that have no browser-facing representation.
 */
export function mapEventToFrames(event: AgentSessionEvent): ServerMessage[] {
  switch (event.type) {
    case "turn_start":
      return [{ type: "turn_start" }];
    case "turn_end": {
      // A turn can complete with stopReason "error" (e.g. the model request
      // 400'd) WITHOUT any error being thrown up to the WS message handler, so
      // it would otherwise vanish — the browser just sees an empty turn ("no
      // messages"). Surface it as an error frame so the UI can show it.
      const msg = (event as { message?: { stopReason?: string; errorMessage?: string; responseId?: string } }).message;
      if (msg?.stopReason === "error") {
        return [
          { type: "error", message: msg.errorMessage || "the model request failed" },
          { type: "turn_end" },
        ];
      }
      return [{ type: "turn_end" }];
    }
    case "message_update": {
      const ame = event.assistantMessageEvent;
      if (ame.type === "text_delta") return [{ type: "text_delta", delta: ame.delta }];
      if (ame.type === "thinking_delta") return [{ type: "thinking_delta", delta: ame.delta }];
      return [];
    }
    case "tool_execution_start":
      return [
        {
          type: "tool_start",
          callId: event.toolCallId,
          tool: event.toolName,
          args: event.args,
        },
      ];
    case "tool_execution_update":
      return [
        {
          type: "tool_update",
          callId: event.toolCallId,
          chunk: event.partialResult,
        },
      ];
    case "tool_execution_end":
      return [
        {
          type: "tool_end",
          callId: event.toolCallId,
          ok: !event.isError,
          result: event.result,
        },
      ];
    case "queue_update":
      return [
        {
          type: "queue_update",
          steering: event.steering,
          followUp: event.followUp,
        },
      ];
    default:
      return [];
  }
}
