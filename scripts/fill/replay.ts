#!/usr/bin/env bun
// Replay recorded agent sessions against ONE running server (K3d).
//
//   bun scripts/fill.ts replay --sessions <file.jsonl|dir> --server-url http://127.0.0.1:8080 \
//     [--model <id>] [--max-tokens 512] [--max-turns 0] [--label on] [--out reports/fill-replay.jsonl]
//
// Every assistant message in a session becomes one request: the conversation
// up to that point, with tool results MOCKED VERBATIM from the recording. The
// transcript is the environment — a model cannot tell an executed result from
// a recorded one — so the replay is deterministic and side-effect-free, and
// the whole corpus can be replayed without touching a filesystem or a network
// beyond the served model.
//
// Writes one JSONL row per turn (see TurnRecord) for `fill report` to
// aggregate. Josh's shell runs this against a server he started; nothing here
// starts one.
import { appendFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";
import { arg, loadSessions, num } from "./args";
import { armRates, renderArm, type TurnRecord } from "./metrics";
import { replaySession } from "./runner";

const SESSIONS = arg("sessions");
const URL = arg("server-url", "http://127.0.0.1:8080")!;
if (!SESSIONS) {
  console.error(
    "usage: bun scripts/fill.ts replay --sessions <file.jsonl|dir> " +
    "[--server-url http://127.0.0.1:8080] [--model <id>] [--max-tokens 512] " +
    "[--max-turns 0] [--label on] [--out <file.jsonl>]",
  );
  process.exit(2);
}
const OUT = arg("out");
const LABEL = arg("label", "replay")!;
const MODEL = arg("model");
const MAX_TOKENS = num("max-tokens", 512);
const MAX_TURNS = num("max-turns", 0);
const TEMPERATURE = num("temperature", 0);

if (OUT) mkdirSync(dirname(OUT), { recursive: true });

const sessions = loadSessions(SESSIONS);
console.log(
  `replaying ${sessions.length} session(s), ` +
  `${sessions.reduce((n, s) => n + s.turns.length, 0)} assistant turns, ` +
  `against ${URL} (arm "${LABEL}")`,
);
for (const s of sessions)
  console.log(`  ${s.name}: ${s.turns.length} turns, ${s.tools.length} tools inferred ` +
    `(${s.tools.map((t) => t.function.name).join(", ") || "none"})`);

const all: TurnRecord[] = [];
for (const session of sessions) {
  const records = await replaySession(
    session,
    { label: LABEL, url: URL },
    {
      ...(MODEL ? { model: MODEL } : {}),
      maxTokens: MAX_TOKENS,
      temperature: TEMPERATURE,
      maxTurns: MAX_TURNS,
      onTurn: (r) => {
        const fill = r.fill;
        console.log(
          `  ${r.session}#${r.turn} ${r.wallMs.toFixed(0)}ms ` +
          `${r.completionTokens} tok` +
          (fill ? ` fill ${fill.injected} (${fill.events} spans)` : "") +
          ` ${r.taskMatch ? "match" : "DIFFER"}` +
          (r.error ? ` ERROR ${r.error}` : ""),
        );
        if (OUT) appendFileSync(OUT, `${JSON.stringify(r)}\n`);
      },
    },
  );
  all.push(...records);
}

console.log("");
console.log(renderArm(LABEL, armRates(all)));
if (OUT) console.log(`\nwrote ${all.length} rows to ${OUT}`);
