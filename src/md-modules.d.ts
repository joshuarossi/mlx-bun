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
