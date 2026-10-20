// The panel's markup: the recent-chats sidebar, the conversation with its empty state, the composer, the adapter
// routing table's sheet and the narrow-screen drawer's backdrop. It is light DOM on the host page, so it uses the web
// kit's base vocabulary (`.btn`, `.input`, `.select`, `.tag`, `.dot`, `.notice`) directly. The ids are the panel's
// public surface: the element hands the sidebar entry, the consent card and the suggestion chips to a companion
// (`companionSlots()`), and the assistant snapshots the controls. `#chat-notice` is the chat's own live region for
// notices in a host without toasts. `data-spotlight` marks the controls the assistant can point at;
// `data-ui-chrome="content"` keeps the rendered conversation out of that snapshot (a link in a message is untrusted
// content, not app chrome).
import { esc, shortName } from "@mlx-bun/web-kit";
import { ICON } from "./icons";

const samplingRow = (id: string, label: string, min: number, max: number, step: number, aria: string, initial: string) =>
  `<div class="samprow"><label for="samp-${id}">${label}</label>` +
  `<input id="samp-${id}" type="range" min="${min}" max="${max}" step="${step}" aria-label="${aria}">` +
  `<output id="samp-${id}-val" class="samp-val auto">${initial}</output></div>`;

export const MARKUP = `
<aside id="chat-sidebar" aria-label="Recent chats">
  <button id="chat-new" class="btn sm" type="button" data-spotlight="new-chat" data-ui-label="New chat" title="Start a new chat (or type /new)">${ICON.plus}<span>New chat</span></button>
  <div class="cs-search">${ICON.search}<input class="input sm" type="search" id="chat-sess-search" data-spotlight="session-search" data-ui-label="Search chats" placeholder="Search chats" aria-label="Search chats" autocomplete="off"></div>
  <div id="chat-sessions" class="sesslist"></div>
  <button id="chat-memory-entry" data-spotlight="memory-entry" data-ui-label="Memory" type="button" style="display:none" aria-haspopup="dialog" aria-expanded="false">
    <span class="mi" aria-hidden="true">${ICON.memory}</span><span class="mt">Memory</span><span class="mcount" id="chat-memory-count">—</span>
  </button>
</aside>
<div id="chat-main">
  <div id="chat-scroll">
    <div id="chat-hello">
      <h1 class="hello-title">Start a chat</h1>
      <p id="chat-hello-sub" class="hello-sub">Connecting to the model server…</p>
      <p id="chat-hello-note" class="hello-note" hidden></p>
      <div class="chips" id="chat-hello-chips" role="group" aria-label="Suggestions">
        <button class="chip" type="button" data-q="What is mlx-bun and what can it do?">What can mlx-bun do?</button>
        <button class="chip" type="button" data-q="How do I load a bigger or different model?">Load a bigger model</button>
        <button class="chip" type="button" data-q="Is this really private? Where does my data go?">Where does my data go?</button>
        <button class="chip" type="button" data-q="What can you help me with right now?">What can you help with?</button>
      </div>
      <div id="chat-consent" role="group" aria-label="Memory setup">
        <span class="cc-icon" aria-hidden="true">${ICON.memory}</span>
        <span class="cc-text"><b>Let mlx-bun remember what matters?</b> It keeps a local, Git-tracked vault you can open any time.</span>
        <span class="cc-actions">
          <button class="btn quiet sm" id="chat-consent-skip" type="button">Not now</button>
          <button class="btn primary sm" id="chat-consent-yes" type="button">Set up memory</button>
        </span>
      </div>
    </div>
    <div id="chat-thread" role="log" aria-live="polite" aria-atomic="false" aria-label="Conversation" data-ui-chrome="content"></div>
  </div>
  <div id="chat-foot">
    <div id="chat-notice" role="status" aria-live="polite" hidden></div>
    <div class="queuebar" id="chat-queue" aria-live="polite"></div>
    <div class="composer">
      <div id="chat-attach" class="attach-row"></div>
      <div class="composer-field">
        <div id="chat-box-wrap">
          <textarea id="chat-box" data-spotlight="composer" data-ui-label="Message box" rows="1" placeholder="Message the local model" aria-label="Message"></textarea>
          <div id="chat-mention-pop" class="mentionpop" role="listbox" aria-label="Attach a file or recall a memory"></div>
        </div>
        <div class="cf-row">
          <button id="chat-attach-btn" class="btn icon sm quiet" type="button" title="Attach files or images" aria-label="Attach files or images">${ICON.attach}</button>
          <input type="file" id="chat-file-input" multiple hidden>
          <button id="chat-mic-btn" class="btn icon sm quiet" type="button" title="Hold to talk" aria-label="Hold to talk" style="display:none">${ICON.mic}</button>
          <span class="spacer"></span>
          <button id="chat-stop" class="btn sm" type="button" title="Stop the reply" style="display:none">${ICON.stop}<span>Stop</span></button>
          <button id="chat-send" class="btn primary sm" type="button" data-spotlight="send" data-ui-label="Send" title="Send (Enter)">${ICON.send}<span>Send</span></button>
        </div>
      </div>
      <div class="chat-toolbar" role="toolbar" aria-label="Chat settings">
        <span id="chat-sysprompt-wrap">
          <button id="chat-sysprompt" class="btn sm quiet tb" type="button" data-spotlight="prompt-pill" data-ui-label="System prompt" aria-haspopup="dialog" aria-expanded="false" aria-controls="chat-sysprompt-pop"
                  title="System prompt: shapes how the assistant replies in this chat"><span class="dot"></span>Prompt</button>
          <div id="chat-sysprompt-pop" class="samplepop sysprompt-pop" role="dialog" aria-label="System prompt">
            <h4>System prompt</h4>
            <textarea id="sysprompt-text" class="textarea" rows="6" maxlength="4000" placeholder="For example: Answer in French. Keep replies under three sentences." aria-label="Custom system prompt"></textarea>
            <div class="sysprompt-foot-row">
              <span class="note num" id="sysprompt-count">0 / 4000</span>
              <button id="sysprompt-clear" class="btn sm quiet" type="button">Clear</button>
            </div>
            <p class="note">Added on top of the built-in assistant prompt, not in place of it. It applies from your next message.</p>
            <div class="sysprompt-presets">
              <h4>Presets</h4>
              <div class="sysprompt-preset-row">
                <select id="sysprompt-preset-select" class="select sm" aria-label="Saved presets"><option value="">Choose a preset</option></select>
                <button id="sysprompt-preset-save" class="btn sm" type="button" title="Save the current prompt and sampling as a preset">Save</button>
                <button id="sysprompt-preset-delete" class="btn sm quiet" type="button" title="Delete the chosen preset">Delete</button>
              </div>
              <p class="note">A preset holds this prompt and the current sampling; choosing one applies both.</p>
            </div>
          </div>
        </span>
        <span id="chat-sampling-wrap">
          <button id="chat-sampling" class="btn sm quiet tb" type="button" data-spotlight="sampling-pill" data-ui-label="Sampling" aria-haspopup="dialog" aria-expanded="false" aria-controls="chat-sampling-pop"
                  title="Sampling: temperature, top_p, top_k and more"><span class="dot"></span>Sampling</button>
          <div id="chat-sampling-pop" class="samplepop" role="dialog" aria-label="Sampling">
            <div class="samp-head-row"><h4>Sampling</h4><span id="samp-oneshot-chip" class="tag warn" style="display:none">Next message only</span></div>
            <div class="samp-scope-row">
              <label for="samp-scope">Apply to</label>
              <select id="samp-scope" class="select sm" aria-label="Sampling scope">
                <option value="session">This chat</option>
                <option value="next_turn">The next message only</option>
              </select>
            </div>
            ${samplingRow("temp", "Temperature", 0, 2, 0.05, "Temperature", "0.70")}
            ${samplingRow("topp", "top_p", 0, 1, 0.01, "top_p", "0.95")}
            ${samplingRow("topk", "top_k", 0, 100, 1, "top_k", "off")}
            <details class="samp-adv" id="samp-advanced">
              <summary>${ICON.chevron}<span>Advanced</span></summary>
              ${samplingRow("minp", "min_p", 0, 0.5, 0.01, "min_p", "off")}
              ${samplingRow("xtcp", "XTC prob.", 0, 1, 0.01, "XTC probability", "off")}
              ${samplingRow("xtct", "XTC thresh.", 0, 1, 0.01, "XTC threshold", "off")}
              ${samplingRow("reppen", "Repetition", 1, 2, 0.01, "Repetition penalty", "off")}
              ${samplingRow("repctx", "Rep. window", 0, 1024, 16, "Repetition context size", "off")}
              ${samplingRow("prespen", "Presence", -2, 2, 0.05, "Presence penalty", "off")}
              ${samplingRow("freqpen", "Frequency", -2, 2, 0.05, "Frequency penalty", "off")}
              <div class="seed-row">
                <label for="samp-seed">Seed</label>
                <input id="samp-seed" class="input sm" type="text" inputmode="numeric" pattern="[0-9]*" placeholder="Random" aria-label="Seed">
              </div>
            </details>
            <div class="samppop-foot">
              <p class="note" id="samp-foot-note">Sliders start at this model's recommended values; temperature also follows Thinking.</p>
              <button id="samp-reset" class="btn sm" type="button">Reset</button>
            </div>
          </div>
        </span>
        <select id="chat-adapter" class="select sm" data-spotlight="adapter-select" data-ui-label="LoRA adapter" title="LoRA adapter for this chat (none is the base model)" aria-label="LoRA adapter">
          <option value="">No adapter</option>
        </select>
        <button id="adapters-manage" class="btn icon sm quiet" type="button" title="Manage adapters: routing, RAM cost, stacking" aria-label="Manage adapters"
                aria-haspopup="dialog" aria-controls="adapters-overlay" aria-expanded="false">${ICON.gear}</button>
        <button id="chat-think" class="btn sm quiet tb" type="button" aria-pressed="true" title="Toggle the model's reasoning" style="display:none"><span class="dot"></span>Thinking</button>
      </div>
      <div class="chat-meta">
        <span class="chat-conn"><span class="dot" id="chat-conn-dot"></span><span id="chat-status-line" role="status">Connecting to the model server…</span></span>
        <span id="chat-perf" class="num">
          <span class="pf-item" id="pf-tps" title="Decode speed of the current or last reply"></span>
          <span class="pf-item" id="pf-ttft" title="Time to the first token"></span>
          <span class="pf-item" id="pf-fill" title="Context window in use; the chat compacts before it fills"></span>
        </span>
      </div>
    </div>
  </div>
</div>
<div id="adapters-overlay">
  <div id="adapters-panel" role="dialog" aria-modal="true" aria-labelledby="adapters-title">
    <div class="ad-head">
      <h2 id="adapters-title">Adapters</h2>
      <button class="btn icon sm quiet" id="adapters-close" type="button" aria-label="Close the adapter table">${ICON.close}</button>
    </div>
    <div id="adapters-body"></div>
  </div>
</div>
<div id="chat-drawer-backdrop"></div>
`;

/** What the server reports, for the empty state's line about the served model. */
export interface ServedModel {
  model: string | null;
  online: boolean;
  download?: { repoId: string; percent: number } | null;
}

/** The empty state's line: which model answers, or what to do when none can. */
export function helloSubHtml(served: ServedModel, canNavigate = false): string {
  if (!served.online) return "The model server is not answering. The chat reconnects on its own once it is back.";
  if (!served.model) return canNavigate
    ? 'No model is serving yet. Choose one on the <button type="button" class="link" data-navigate="models">Models page</button>.'
    : "No model is serving yet. Choose one on the Models page.";
  return `<b class="mono" title="${esc(served.model)}">${esc(shortName(served.model))}</b> is serving. Every token of a reply is generated on this Mac.`;
}

/** The empty state's download note, or null for none. */
export function helloNoteText(served: ServedModel): string | null {
  return served.online && served.download ? `Downloading ${shortName(served.download.repoId)} in the background (${served.download.percent}%).` : null;
}
