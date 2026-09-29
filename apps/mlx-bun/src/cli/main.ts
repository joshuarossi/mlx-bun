#!/usr/bin/env bun
import "../jobs/executable";
import { commandInvocation, help, isCommand, parseCommand } from "./args";
import { invokedAlias, translateAlias, type AliasResult } from "./mlx-lm-aliases";
import { installedVerbs, runInstalledVerb } from "./module-verbs";
import { renderHelp } from "./terminal";
import pkg from "../../package.json" with { type: "json" };

try {
  // Started as `mlx-bun.<cmd>` (an mlx-lm alias): the verb and its arguments come from the translation.
  const alias = invokedAlias();
  const aliased: AliasResult | undefined = alias ? translateAlias(alias, process.argv.slice(2)) : undefined;
  const { command, args } = aliased && "command" in aliased ? { command: aliased.command as string, args: [] as string[] }
    : commandInvocation(process.argv.slice(2));
  const parsedArgs = aliased && "parsed" in aliased ? aliased.parsed : undefined;
  if (aliased && "help" in aliased) {
    console.log(renderHelp(aliased.help));
  } else if (command === "__job") {
    process.exit(await (await import("./job-entry")).runJobEntry(args[0]));
  } else if (command === "__worker") {
    // Private: the isolation worker a parent spawns (jobs/worker-process.ts);
    // its launch record arrives on stdin. No user flag selects this mode.
    process.exit(await (await import("./worker-entry")).runWorkerEntry());
  } else if (["--version", "-v", "version"].includes(command ?? "")) {
    console.log(`mlx-bun ${pkg.version}`);
  } else if (command === "help" || command === "--help" || command === "-h") {
    console.log(renderHelp(help(args[0])));
  } else if (installedVerbs().has(command)) {
    // A verb an installed module declares (`src/modules.ts`); an alias (`mlx-bun.convert`) arrives already translated to the verb's options.
    if (args.includes("--help") || args.includes("-h")) console.log(renderHelp(help(command)));
    else process.exitCode = await runInstalledVerb(command, parsedArgs ?? args);
  } else if (!isCommand(command)) {
    throw new Error(`Unknown command: ${command}. Use mlx-bun --help.`);
  } else if (args.includes("--help") || args.includes("-h")) {
    console.log(renderHelp(help(command)));
  } else {
    const parsed = parsedArgs ?? parseCommand(command, args);
    if (command === "serve") {
      const { runServe } = await import("./serve");
      await runServe(parsed);
    } else if (command === "generate" || command === "embed" || command === "upload") {
      // SIGINT/SIGTERM abort the one-shot work; the verb rejects with the reason and exits 1.
      const cancellation = new AbortController();
      const stop = () => cancellation.abort(new Error(`${command === "upload" ? "upload" : "inference"} cancelled`));
      process.on("SIGINT", stop); process.on("SIGTERM", stop);
      try {
        if (command === "upload") await (await import("./upload")).runUpload(parsed, {}, cancellation.signal);
        else await (await import("./inference")).runInference(command, parsed, {}, cancellation.signal);
      } finally { process.off("SIGINT", stop); process.off("SIGTERM", stop); }
    } else if (command === "memory" || command === "setup") {
      await (await import("./memory")).runMemory(parsed);
    } else if (command === "draft") {
      const cancellation = new AbortController();
      const stop = () => cancellation.abort(new Error("draft cancelled"));
      process.on("SIGINT", stop); process.on("SIGTERM", stop);
      try { await (await import("./draft")).runDraft(parsed, {}, cancellation.signal); }
      finally { process.off("SIGINT", stop); process.off("SIGTERM", stop); }
    } else if (command === "train" || command === "fuse" || command === "train-watch") {
      const { runTrain, runFuse, runTrainWatch } = await import("./train");
      const cancellation = new AbortController();
      const stop = () => cancellation.abort(new Error(`${command === "train" ? "training" : command === "fuse" ? "fuse" : "watch"} cancelled`));
      process.on("SIGINT", stop); process.on("SIGTERM", stop);
      try {
        if (command === "train") await runTrain(parsed, {}, cancellation.signal);
        else if (command === "fuse") await runFuse(parsed, {}, cancellation.signal);
        else await runTrainWatch(parsed, {}, cancellation.signal);
      } finally { process.off("SIGINT", stop); process.off("SIGTERM", stop); }
    } else {
      const { runHub } = await import("./hub");
      await runHub(command, parsed);
    }
  }
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
