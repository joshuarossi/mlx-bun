// The hand-built fixture vault the read-path tests navigate: eight articles
// covering category membership, alias resolution, the infobox link graph, and
// a "lens" false-positive decoy. Main tracked these under tests/fixtures/wiki;
// here each test writes them into a fresh temporary vault.

import { mkdirSync, mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

export const FIXTURE_ARTICLES: Record<string, string> = {
  "L-Mount": `# L-Mount

categories: [[Category:Lens Mounts]]

\`\`\`info
type: lens mount
kind: standard
adaptable_from: [[M42]]; [[EF]]
native_lenses: [[Sigma 150-600]]; [[Lumix 75-300]]; [[Sigma 100-400]]
aliases: L-Mount, L mount, Leica L
\`\`\`

The **L-Mount** is the lens-mount standard shared across Josh's
[[Panasonic Lumix S5IIX]] body and his native telephoto glass.[^1] Its short
flange distance makes it broadly adaptable, so vintage [[M42]] and Canon [[EF]]
lenses mount with a simple adapter.

## Native lenses

Josh's native L-Mount glass includes the [[Sigma 150-600]], the
[[Lumix 75-300]], and the [[Sigma 100-400]].[^1]

## Adaptation

The short flange distance accepts adapted [[M42]] and [[EF]] lenses without
optics in the path, which is why he uses it as his adaptation base.[^1]

## See also

- [[Lens Mount Adaptation]]
- [[Panasonic Lumix S5IIX]]

## References

[^1]: \`conv:44444444\` (2024-12-05, gear) — mapped the L-Mount native + adapted lens lineup
`,
  "Lens_Mount_Adaptation": `# Lens Mount Adaptation

\`\`\`info
type: technique
kind: domain
aliases: Lens Mount Adaptation, mount adaptation, adapting lenses
\`\`\`

**Lens Mount Adaptation** is the practice Josh uses to mount older or
third-party glass on his [[L-Mount]] body, trading autofocus for access to
cheap vintage optics.[^1]

## Adaptable mounts

Josh adapts [[M42]] screw-mount and Canon [[EF]] lenses onto the [[L-Mount]]
via passive and electronic adapters — those are the two mounts he reaches for.[^1]

## See also

- [[L-Mount]]

## References

[^1]: \`conv:55555555\` (2024-12-06, gear) — which mounts adapt cleanly to L-Mount
`,
  "Lumix_75-300": `# Lumix 75-300

categories: [[Category:Lenses]]

\`\`\`info
type: lens
mount: [[L-Mount]]
focal_length: 75-300mm
kind: thing
owned: yes
aliases: Lumix 75-300, 75-300mm
\`\`\`

The **Lumix 75-300** is a compact telephoto zoom Josh owns for everyday reach on
the [[L-Mount]] system.[^1]

## References

[^1]: \`conv:11111111\` (2024-11-15, gear) — packed the 75-300 as the light reach option
`,
  "Panasonic_Lumix_S5IIX": `# Panasonic Lumix S5IIX

*Part of a series on [[Cameras]].*

categories: [[Category:Cameras]]

\`\`\`info
type: Mirrorless camera
mount: [[L-Mount]]
sensor: full-frame 24.2MP
kind: thing
owned: yes
acquired: 2024-12
used_for: video-conference camera; anamorphic
aliases: S5IIX, S5 IIX, Lumix S5IIX, LUMIX S5IIX
\`\`\`

The **Panasonic Lumix S5IIX** is a full-frame mirrorless camera Josh owns.[^1]
It sits on the [[L-Mount]] system, which lets him adapt vintage and third-party
glass onto one body.

## Use

Mostly a clean video-conference camera, occasionally the capture body for
anamorphic experiments.[^1]

## See also

- [[L-Mount]]

## References

[^1]: \`conv:00000000\` (2024-12-01, claude) — bought the S5IIX used and discussed its uses
`,
  "PETG": `# PETG

categories: [[Category:Materials]]

\`\`\`info
type: material
kind: standard
aliases: PETG, PET-G, polyethylene terephthalate glycol
\`\`\`

**PETG** is the 3D-printing filament Josh reaches for when a part needs more
toughness and heat resistance than PLA can offer.[^1]

## Print settings

Josh prints PETG hot — around a 240°C nozzle over a 70-80°C bed — with slower
speeds and a touch more retraction to keep stringing under control.[^1]

## References

[^1]: \`conv:66666666\` (2024-12-08, making) — dialed in PETG print settings
`,
  "Sigma_100-400": `# Sigma 100-400

categories: [[Category:Lenses]]

\`\`\`info
type: lens
mount: [[L-Mount]]
focal_length: 100-400mm
kind: thing
owned: no
aliases: Sigma 100-400, 100-400 Contemporary
\`\`\`

The **Sigma 100-400** is a lighter long-reach alternative on the [[L-Mount]]
system that Josh considered before the 150-600.[^1]

## References

[^1]: \`conv:22222222\` (2024-12-03, gear) — compared the 100-400 against the 150-600
`,
  "Sigma_150-600": `# Sigma 150-600

categories: [[Category:Lenses]]

\`\`\`info
type: lens
mount: [[L-Mount]]
focal_length: 150-600mm
kind: thing
owned: yes
aliases: Sigma 150-600, 150-600 Sport, Sigma 150-600mm
\`\`\`

The **Sigma 150-600** is the sane long-reach telephoto pick — at roughly $600 it
gets to 600mm without the four-figure price of the exotic options.[^1] It mounts
natively on the [[L-Mount]] system, so it pairs directly with the body.

## Verdict

For wildlife and the moon, this is the lens that isn't crazy expensive while
still reaching far enough.[^1]

## See also

- [[L-Mount]]

## References

[^1]: \`conv:00000000\` (2024-12-01, gear) — settled on the 150-600 as the long-reach value pick
`,
  "Toyota_Production_System": `# Toyota Production System

categories: [[Category:Manufacturing]]

\`\`\`info
type: methodology
kind: domain
aliases: TPS, Toyota Production System, lean manufacturing
\`\`\`

The **Toyota Production System** is a manufacturing philosophy Josh returns to as
a thinking lens, built on jidoka and just-in-time flow. It has nothing to do with
camera lenses despite the word "lens" appearing in discussions about it.[^1]

## Principles

Pull-based flow, stopping the line on defects, and continuous improvement.[^1]

## References

[^1]: \`conv:33333333\` (2024-10-02, ideas) — discussed TPS as a model for software flow
`,
};

/** Write the fixture vault into a fresh temporary directory and return its root. */
export function fixtureWiki(prefix = "mlxbun-fixture-wiki-"): string {
  const root = mkdtempSync(join(tmpdir(), prefix));
  mkdirSync(join(root, "articles"), { recursive: true });
  for (const [stem, content] of Object.entries(FIXTURE_ARTICLES)) writeFileSync(join(root, "articles", `${stem}.md`), content);
  return root;
}
