// The composer's attachments: files and images read in the browser, the attach row of chips above the message box,
// the attach button and file picker, clipboard paste and drag-and-drop onto the composer, and the outgoing prompt text
// that carries attached text files. Small text attachments are inlined verbatim; past `rag.ts`'s threshold only the
// most relevant excerpts are sent as a numbered context block, and the reply gets a Sources panel for them.
import { $, el } from "@mlx-bun/web-kit";
import { toast } from "../host";
import { ICON } from "../icons";
import { buildContextBlock, retrieve, shouldRetrieve, type Citation } from "../rag";
import type { Attachment, ComposerState } from "./state";


const MAX_TEXT_BYTES = 256 * 1024;
const TEXT_EXTS = /\.(txt|md|markdown|csv|tsv|json|jsonl|ya?ml|toml|ini|cfg|conf|log|xml|html?|css|scss|js|mjs|cjs|ts|tsx|jsx|py|rs|go|java|c|h|cpp|hpp|cc|cs|rb|php|sh|bash|zsh|fish|sql|swift|kt|lua|r|jl|tex|svg|env|gitignore|dockerfile|makefile)$/i;

function isTextFile(file: File): boolean {
  if (file.type.startsWith("text/")) return true;
  if (/(json|xml|javascript|yaml|x-sh|x-toml|csv|markdown)/i.test(file.type)) return true;
  return TEXT_EXTS.test(file.name || "");
}
function readDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader(); reader.onerror = reject;
    reader.onload = () => { const s = String(reader.result); const i = s.indexOf(","); resolve(i >= 0 ? s.slice(i + 1) : s); };
    reader.readAsDataURL(file);
  });
}
function readText(file: File): Promise<string> {
  return new Promise((resolve, reject) => { const reader = new FileReader(); reader.onerror = reject; reader.onload = () => resolve(String(reader.result)); reader.readAsText(file); });
}

export async function addFiles(state: ComposerState, files: File[]): Promise<void> {
  for (const file of files) {
    if (file.type.startsWith("image/")) {
      if (!state.visionCapable) { toast("This model cannot read images. Serve a model tagged vision on the Models page to attach one.", "err"); continue; }
      try { state.attachments.push({ id: ++state.attachSeq, kind: "image", name: file.name || "image", mimeType: file.type, data: await readDataUrl(file) }); }
      catch { toast("Could not read " + (file.name || "the image") + ".", "err"); }
    } else if (isTextFile(file)) {
      try {
        let text = await readText(file); const truncated = text.length > MAX_TEXT_BYTES; if (truncated) text = text.slice(0, MAX_TEXT_BYTES);
        state.attachments.push({ id: ++state.attachSeq, kind: "text", name: file.name || "file", text, truncated });
      } catch { toast("Could not read " + (file.name || "the file") + ".", "err"); }
    } else {
      toast("Cannot attach " + (file.name || "this file") + ": attach text files or images.", "err");
    }
  }
  renderAttachments(state);
}

export function renderAttachments(state: ComposerState): void {
  const box = $("chat-attach");
  box.innerHTML = "";
  box.style.display = state.attachments.length ? "flex" : "none";
  // Whether text files are retrieved rather than inlined is a property of the whole attached set (buildMessageText sums
  // every text file), so every text chip shows the tag together.
  const totalTextChars = state.attachments.reduce((n, a) => n + (a.kind === "text" ? (a.text || "").length : 0), 0);
  const retrievalMode = shouldRetrieve(totalTextChars);
  for (const attachment of state.attachments) {
    const chip = el("div", "attach-chip", box);
    chip.dataset.attId = String(attachment.id); // the mention picker pulses it
    if (attachment.kind === "image") { const image = el("img", "", chip); image.src = "data:" + attachment.mimeType + ";base64," + attachment.data; image.alt = attachment.name; }
    else el("span", "att-ico", chip).innerHTML = ICON.file;
    el("span", "att-name", chip).textContent = attachment.name + (attachment.truncated ? " (truncated)" : "");
    if (attachment.kind === "text" && retrievalMode) {
      const tag = el("span", "att-tag tag accent", chip);
      tag.textContent = "excerpts";
      tag.title = "These files are long, so only the passages most relevant to your message are sent";
    }
    const remove = el("button", "att-x btn icon sm quiet", chip);
    remove.type = "button";
    remove.innerHTML = ICON.close;
    remove.setAttribute("aria-label", "Remove " + attachment.name);
    remove.onclick = () => { state.attachments = state.attachments.filter((item) => item.id !== attachment.id); renderAttachments(state); };
  }
}

export function clearAttachments(state: ComposerState): void { state.attachments = []; renderAttachments(state); }

/** The outgoing text the model sees, plus the citations a retrieval-mode send attaches to its reply's Sources panel
 * (empty when the files were inlined, or nothing was attached). */
export interface BuiltMessage {
  text: string;
  citations: Citation[];
}

/** Size-aware retrieval over attached text files, decided per send: up to the inline threshold every file is inlined
 * verbatim; above it the top excerpts (`rag.ts`'s BM25 over the files, scored against the message) go as a numbered
 * `[1]..[K]` context block. The user's visible message is untouched either way. */
export function buildMessageText(state: ComposerState, userText: string): BuiltMessage {
  const files = state.attachments.filter((a): a is Attachment & { text: string } => a.kind === "text" && a.text != null);
  if (!files.length) return { text: userText, citations: [] };
  const totalChars = files.reduce((n, a) => n + a.text.length, 0);
  if (!shouldRetrieve(totalChars)) {
    let pre = "";
    for (const a of files) pre += "Attached file: " + a.name + "\n```\n" + a.text + "\n```\n\n";
    return { text: pre + userText, citations: [] };
  }
  const citations = retrieve(files.map((a) => ({ id: a.id, name: a.name, text: a.text })), userText);
  if (!citations.length) return { text: userText, citations: [] }; // no term overlap at all: nothing useful to inject
  return { text: buildContextBlock(citations) + userText, citations };
}

/** The attach button's hint follows the model's vision; the mic shows only when the server can transcribe. */
export function updateAttachHint(state: ComposerState): void {
  const button = $("chat-attach-btn");
  if (button) {
    const hint = state.visionCapable ? "Attach files or images" : "Attach files (this model cannot read images)";
    button.title = hint;
    button.setAttribute("aria-label", hint);
  }
  const mic = $("chat-mic-btn");
  if (mic) mic.style.display = state.transcriptionCapable ? "" : "none";
}

/** Wires the attach button and file picker, paste into the message box, and drag-and-drop onto the composer. */
export function initAttachments(state: ComposerState, box: HTMLTextAreaElement): void {
  const input = $("chat-file-input") as HTMLInputElement;
  ($("chat-attach-btn") as HTMLButtonElement).onclick = () => input.click();
  input.addEventListener("change", () => { void addFiles(state, [...input.files || []]); input.value = ""; });
  box.addEventListener("paste", (event) => {
    const items = event.clipboardData?.items;
    if (!items) return;
    const files: File[] = [];
    for (const item of items) if (item.kind === "file") { const file = item.getAsFile(); if (file) files.push(file); }
    if (files.length) { event.preventDefault(); void addFiles(state, files); }
  });
  const zone = document.querySelector<HTMLElement>("#chat-foot .composer");
  if (!zone) return;
  for (const type of ["dragenter", "dragover"]) zone.addEventListener(type, (event) => { event.preventDefault(); zone.classList.add("dragover"); });
  for (const type of ["dragleave", "drop"]) {
    zone.addEventListener(type, (event) => {
      event.preventDefault();
      const drag = event as DragEvent;
      if (type === "drop" && drag.dataTransfer?.files.length) void addFiles(state, [...drag.dataTransfer.files]);
      if (type === "drop" || !zone.contains(drag.relatedTarget as Node | null)) zone.classList.remove("dragover");
    });
  }
}
