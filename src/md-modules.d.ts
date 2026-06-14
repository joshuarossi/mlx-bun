// Ambient type for `import md from "./foo.md" with { type: "text" }`.
// Bun reads the file as a string, but bun-types only declares .txt/.html,
// not .md — so we declare it here (used by src/web/skills.ts).
declare module "*.md" {
  const content: string;
  export default content;
}
