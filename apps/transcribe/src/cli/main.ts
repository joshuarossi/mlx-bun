#!/usr/bin/env bun
// mlx-bun-transcribe: the transcription module as a standalone host. Its
// verbs are the module's (`transcribe`, `dictate`) and its own `serve`.
import { createHostServices, runVerb, verbHelp } from "@mlx-bun/app-services";
import pkg from "../../package.json" with { type: "json" };
import { installedModules, manifests } from "../modules";
import { PROGRAM, runServe, serveVerb } from "./serve";

const installed = new Map(manifests.flatMap(manifest => (manifest.verbs ?? []).map(spec => [spec.name, spec] as const)));
const verbs = new Map([[serveVerb.name, serveVerb], ...installed]);

const overview = () => {
  const column = Math.max(...[...verbs.keys()].map(name => name.length));
  return `${PROGRAM} — speech-to-text on Apple Silicon\n\nUsage: ${PROGRAM} <command> [options]\n\nCommands:\n${[...verbs.values()].map(spec => `  ${spec.name.padEnd(column + 1)} ${spec.summary}`).join("\n")}\n\nOptions:\n  -h, --help     Show help\n  -v, --version  Show version`;
};

try {
  const [command = "--help", ...args] = process.argv.slice(2);
  if (["--version", "-v", "version"].includes(command)) console.log(`${PROGRAM} ${pkg.version}`);
  else if (["help", "--help", "-h"].includes(command)) {
    const spec = command === "help" ? verbs.get(args[0] ?? "") : undefined;
    if (command === "help" && args[0] && !spec) throw new Error(`Unknown command: ${args[0]}`);
    console.log(spec ? verbHelp(PROGRAM, spec) : overview());
  } else if (!verbs.has(command)) throw new Error(`Unknown command: ${command}. Use ${PROGRAM} --help.`);
  else if (args.includes("--help") || args.includes("-h")) console.log(verbHelp(PROGRAM, verbs.get(command)!));
  else if (command === serveVerb.name) process.exitCode = await runServe(args);
  else process.exitCode = await runVerb({ program: PROGRAM, spec: installed.get(command)!, argv: args, modules: installedModules, services: createHostServices({ log() {} }) });
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
