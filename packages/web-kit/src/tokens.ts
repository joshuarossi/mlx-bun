// The design tokens: one copy of the visual system, served to the host page as a stylesheet and cascading
// into every panel's shadow root (custom properties cross shadow boundaries). Dark is the default; the host
// sets `data-theme="light"` on the root element for the light values. Panels and the shell reference these
// names and never hard-code colours, sizes or easing.
//
// The system is a quiet instrument panel: layered neutral surfaces separated by hairlines, the platform's
// own type (the app runs offline, so no web fonts) with tabular numerals for every measurement, one accent for
// interaction and focus, and semantic colours only for state.
export const TOKENS_CSS = String.raw`
:root{
  color-scheme:dark;
  /* surfaces, from the page back to the controls on top of it */
  --bg:#101215;
  --surface:#15181d;
  --panel:#1a1e24;
  --raised:#22272e;
  --overlay:rgba(0,0,0,.55);
  /* ink */
  --ink:#e9ecef;
  --dim:#a4acb6;
  --dimmer:#6e7782;
  /* lines */
  --line:rgba(255,255,255,.08);
  --line-strong:rgba(255,255,255,.17);
  /* the one accent, for interaction and focus */
  --accent:#5b9cff;
  --accent-ink:#0b1220;
  --accent-soft:rgba(91,156,255,.16);
  /* state */
  --ok:#4ade80; --ok-soft:rgba(74,222,128,.14);
  --warn:#f6c453; --warn-soft:rgba(246,196,83,.16);
  --bad:#ff6b6b; --bad-soft:rgba(255,107,107,.14);
  /* code keeps its own dark surface in both themes, so monospace content reads the same everywhere */
  --code-bg:#0b0d10;
  --code-ink:#e9ecef;
  --code-line:rgba(255,255,255,.08);
  /* type */
  --font:-apple-system,BlinkMacSystemFont,"SF Pro Text","Helvetica Neue",Helvetica,Arial,sans-serif;
  --mono:"SF Mono",ui-monospace,Menlo,Monaco,Consolas,monospace;
  --text-xs:11.5px; --text-sm:12.5px; --text-md:13.5px; --text-lg:15px; --text-xl:18px; --text-2xl:22px; --text-3xl:28px;
  /* shape and motion */
  --radius-sm:6px; --radius-md:10px; --radius-lg:14px;
  --ease:cubic-bezier(.2,.7,.2,1);
  --fast:120ms; --base:200ms;
  --shadow:0 1px 2px rgba(0,0,0,.3),0 8px 24px rgba(0,0,0,.35);
  --shadow-lg:0 2px 6px rgba(0,0,0,.35),0 24px 64px rgba(0,0,0,.5);
  /* layout */
  --rail-w:224px;
  --topbar-h:52px;
  --content-w:1100px;
  --scrollbar:rgba(255,255,255,.14);
}
[data-theme="light"]{
  color-scheme:light;
  --bg:#f4f5f7;
  --surface:#ffffff;
  --panel:#ffffff;
  --raised:#eef0f3;
  --overlay:rgba(15,18,22,.38);
  --ink:#171b21;
  --dim:#5b6470;
  --dimmer:#8a929d;
  --line:rgba(23,27,33,.1);
  --line-strong:rgba(23,27,33,.22);
  --accent:#2563eb;
  --accent-ink:#ffffff;
  --accent-soft:rgba(37,99,235,.12);
  --ok:#15803d; --ok-soft:rgba(21,128,61,.12);
  --warn:#a16207; --warn-soft:rgba(161,98,7,.14);
  --bad:#dc2626; --bad-soft:rgba(220,38,38,.12);
  --code-bg:#14181e;
  --code-ink:#e9ecef;
  --code-line:rgba(255,255,255,.08);
  --shadow:0 1px 2px rgba(23,27,33,.08),0 8px 24px rgba(23,27,33,.1);
  --shadow-lg:0 2px 6px rgba(23,27,33,.1),0 24px 64px rgba(23,27,33,.18);
  --scrollbar:rgba(23,27,33,.18);
}
`;

/** The token names a stylesheet may use, for a host that wants to check its own page supplies them all. */
export const TOKEN_NAMES = [
  "--bg", "--surface", "--panel", "--raised", "--overlay", "--ink", "--dim", "--dimmer", "--line", "--line-strong",
  "--accent", "--accent-ink", "--accent-soft", "--ok", "--ok-soft", "--warn", "--warn-soft", "--bad", "--bad-soft",
  "--code-bg", "--code-ink", "--code-line", "--font", "--mono", "--text-xs", "--text-sm", "--text-md", "--text-lg",
  "--text-xl", "--text-2xl", "--text-3xl", "--radius-sm", "--radius-md", "--radius-lg", "--ease", "--fast", "--base",
  "--shadow", "--shadow-lg", "--rail-w", "--topbar-h", "--content-w", "--scrollbar",
] as const;
