# src/web/vendor/ — vendored, no-CDN web assets

Assets here are bundled locally and served same-origin by `src/server.ts`
(`GET /assets/<name>`, `with { type: "text" }` import — same pattern as
`src/web/app.html` itself). Nothing in this app loads a script or
stylesheet from a CDN; this directory is where that tradeoff lives.

## hljs.js — syntax highlighting

`hljs.js` is [highlight.js](https://github.com/highlightjs/highlight.js)
(BSD-3-Clause, license text in `hljs-LICENSE`) core engine + a curated
language set: javascript/typescript, python, bash/shell, json, html/xml,
css, c/cpp, rust, go, sql, yaml, markdown, diff, plaintext. Registered
languages expose themselves as `class="language-<name>"` on `<code>`
elements — see `mdCodeBlock()` and `highlightIn()` in `app.html`.

To rebuild (e.g. to bump the version or change the language set):

```sh
mkdir /tmp/hljs-build && cd /tmp/hljs-build
npm init -y
npm install highlight.js@<version> --no-save
```

Write an `entry.js` that imports `highlight.js/lib/core` and
`highlight.js/lib/languages/<lang>` for each language you want, calling
`hljs.registerLanguage(name, lang)` for each (see mlx-bun's own build log /
commit that introduced this file for the exact entry.js used), then:

```sh
globalThis.hljs = hljs;   # inside entry.js, after registering
bun build ./entry.js --minify --outfile=hljs.bundle.js
```

Prepend a short license/provenance header comment (BSD-3-Clause,
upstream URL, rebuild instructions — copy the one already at the top of
`hljs.js`) and copy the result over `src/web/vendor/hljs.js`.

**Size discipline:** the hygiene gate (`scripts/check-hygiene.ts`) fails
any tracked file over 1 MB unless it's on the explicit allowlist. The
current bundle (core + 14 languages) is ~83 KB — comfortably under the
cap. If you add enough languages to bust 1 MB, either trim the language
list or add a justified, size-capped `ALLOW` entry in
`scripts/check-hygiene.ts` (see the existing entries there for the
pattern) — don't silently let it grow past the cap.

`hljs-theme.css` is NOT generated from highlight.js's stock themes — it's
hand-written, mapping the standard `hljs-*` token classes onto mlx-bun's
own design tokens (see the file's own header comment) so code blocks match
the app's palette in both light and dark.

## KaTeX (math) — deliberately not vendored

Investigated for the same treatment; skipped. KaTeX's CSS depends on its
own bundled math font (`dist/fonts/`, ~60 files / ~1.1 MB of woff2/woff/ttf)
for correct glyph metrics — there's no clean "system font fallback" path
that renders math correctly. Vendoring it would mean adding ~1 MB of
binary font files, which the hygiene gate is specifically designed to keep
out of this repo (see `scripts/check-hygiene.ts`'s header). Needs the
build-step/asset-hosting decision from `docs/design/web-chat-redesign.md`
§7 before it's worth revisiting.
