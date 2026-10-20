// Toast notifications in the host's `#toasts` container: short, dismissed on their own, announced to assistive
// technology through the container's live region. A host without the container shows none.
import { el } from "@mlx-bun/web-kit";

export type ToastKind = "" | "ok" | "err";

export function toast(message: string, kind: ToastKind = "", ms = 4200): void {
  const container = document.getElementById("toasts");
  if (!container) return;
  const item = el("div", "toast " + kind, container);
  item.setAttribute("role", kind === "err" ? "alert" : "status");
  item.textContent = message;
  setTimeout(() => {
    item.classList.add("leaving");
    setTimeout(() => item.remove(), 240);
  }, ms);
}
