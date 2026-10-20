// The composer's state: what is attached, what the served model can do (from `ready`), the sampling overrides and
// their scope, and this chat's system prompt. One instance per panel; the composer's parts read and write it.
import type { ReadyGenDefaults, SamplingOverrides } from "../../protocol";

/** A file or image attached to the next message, read in the browser. */
export interface Attachment {
  id: number;
  kind: "image" | "text";
  name: string;
  mimeType?: string;
  data?: string;
  text?: string;
  truncated?: boolean;
}

export class ComposerState {
  attachments: Attachment[] = [];
  /** From `ready`: image attachments need a vision model. */
  visionCapable = false;
  /** From `ready`: the hold-to-talk mic needs a transcription model. */
  transcriptionCapable = false;
  /** From `ready`: the Thinking toggle needs a reasoning channel. */
  thinkingCapable = false;
  /** On by default: with tools, the reasoning step gives a small model far better judgment about when to use them. */
  thinkingOn = true;
  attachSeq = 0;

  /** Per-request sampling: a number is the user's override, null the server's recommended default. */
  sampling: Required<SamplingOverrides> = {
    temperature: null, top_p: null, top_k: null, min_p: null,
    xtc_probability: null, xtc_threshold: null, repetition_penalty: null,
    repetition_context_size: null, presence_penalty: null, frequency_penalty: null,
    seed: null,
  };
  /** The model's recommended values from `ready`; null falls back to the constants below. */
  genDefaults: ReadyGenDefaults = { temperature: null, topP: null, topK: null };
  /** "session" keeps overrides until changed; "next_turn" sends the next change for one message only. */
  samplingScope: "session" | "next_turn" = "session";
  /** A next-message override is waiting for its turn (the Sampling dot's warning state). */
  oneShotArmed = false;
  /** This chat's custom system prompt, layered on the built-in one; null for none. */
  systemPrompt: string | null = null;

  recTemp(): number { return this.genDefaults.temperature != null ? this.genDefaults.temperature : (this.thinkingOn ? 0.9 : 0.7); }
  recTopP(): number { return this.genDefaults.topP != null ? this.genDefaults.topP : 0.95; }
  recTopK(): number { return this.genDefaults.topK != null ? this.genDefaults.topK : 0; }
}
