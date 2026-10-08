// Theme: auto, dark or light, persisted, following prefers-color-scheme while the choice is "auto". The host page
// carries the `#theme-toggle` buttons (`data-theme-choice`) and defines its tokens under `[data-theme="light"]`.

export const THEME_KEY = "mlxbun.theme"; // "auto" | "dark" | "light"
export const THEME_CHOICES = ["auto", "dark", "light"] as const;

let media: MediaQueryList | undefined;
const lightMedia = (): MediaQueryList => media ??= window.matchMedia("(prefers-color-scheme: light)");

function effectiveTheme(choice: string): "dark" | "light" {
  if (choice === "dark" || choice === "light") return choice;
  return lightMedia().matches ? "light" : "dark";
}
function applyTheme(choice: string): void {
  document.documentElement.setAttribute("data-theme", effectiveTheme(choice));
  document.querySelectorAll<HTMLButtonElement>("#theme-toggle button").forEach((b) =>
    b.classList.toggle("active", b.dataset.themeChoice === choice));
}
export function setTheme(choice: string): void {
  localStorage.setItem(THEME_KEY, choice);
  applyTheme(choice);
}
/** The choice the toggle currently shows as active ("auto" when none). */
export function themeChoice(): string {
  const active = document.querySelector<HTMLButtonElement>("#theme-toggle button.active");
  return (active && active.dataset.themeChoice) || "auto";
}
/** auto, then dark, then light, then auto again. */
export function cycleTheme(): void {
  setTheme(THEME_CHOICES[(THEME_CHOICES.indexOf(themeChoice() as typeof THEME_CHOICES[number]) + 1) % THEME_CHOICES.length]!);
}
export function initTheme(): void {
  const saved = localStorage.getItem(THEME_KEY) || "auto";
  applyTheme(saved);
  document.querySelectorAll<HTMLButtonElement>("#theme-toggle button").forEach((b) =>
    b.addEventListener("click", () => setTheme(b.dataset.themeChoice || "auto")));
  // Live-follow the OS when the user's choice is "auto" (default).
  lightMedia().addEventListener("change", () => {
    if ((localStorage.getItem(THEME_KEY) || "auto") === "auto") applyTheme("auto");
  });
}
