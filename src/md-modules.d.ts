// Ambient type for `import md from "./foo.md" with { type: "text" }`.
// Bun reads the file as a string, but bun-types only declares .txt/.html,
// not .md — so we declare it here (used by src/web/skills.ts).
declare module "*.md" {
  const content: string;
  export default content;
}

// Same deal for vendored text-imported assets under src/web/vendor/ (see
// that dir's README) — served as raw strings via `with { type: "text" }`,
// but bun-types has no ambient declaration for .js/.css read as text.
// Scoped to the vendor path (not a blanket "*.js"/"*.css") so ordinary JS/CSS
// module resolution elsewhere in the repo is untouched.
declare module "./web/vendor/*.js" {
  const content: string;
  export default content;
}
declare module "./web/vendor/*.css" {
  const content: string;
  export default content;
}

// The frontend bundle (plan §7/§9 Phase 2 module split): GENERATED from
// src/web/src/*.ts by scripts/build-web.ts into src/web/app.js, imported as
// raw text in src/server.ts the same way as the vendored assets above.
// Must stay a glob ("./web/*.js"), not the exact "./web/app.js" path — TS's
// ambient-module resolution only matches the real on-disk src/web/app.js
// against a wildcard pattern here, not an exact-path declaration (verified
// 2026-07: an exact-path declare module silently failed to match while the
// file existed, and "cannot find module" once it didn't — a TS quirk, not
// intentional design; keep the glob if this ever needs revisiting).
declare module "./web/*.js" {
  const content: string;
  export default content;
}
