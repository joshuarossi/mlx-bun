#!/usr/bin/env bun
import "../jobs/executable";
import { commandInvocation, help, isCommand, parseCommand } from "./args";
import { renderHelp } from "./terminal";
import pkg from "../../package.json" with { type: "json" };

try {
  const { command, args } = commandInvocation(process.argv.slice(2));
  if (command === "__job") {
    process.exit(await (await import("./job-entry")).runJobEntry(args[0]));
  } else if (["--version", "-v", "version"].includes(command ?? "")) {
    console.log(`mlx-bun ${pkg.version}`);
  } else if (command === "help" || command === "--help" || command === "-h") {
    console.log(renderHelp(help(args[0])));
  } else if (!isCommand(command)) {
    throw new Error(`Unknown command: ${command}. Use mlx-bun --help.`);
  } else if (args.includes("--help") || args.includes("-h")) {
    console.log(renderHelp(help(command)));
  } else if (command === "convert") {
    const { parseConvertArgs, runConvert } = await import("./convert");
    const parsed = parseConvertArgs(args);
    const cancellation = new AbortController();
    const stop = () => cancellation.abort(new Error("convert cancelled"));
    process.on("SIGINT", stop); process.on("SIGTERM", stop);
    try { await runConvert(parsed, {}, cancellation.signal); }
    finally { process.off("SIGINT", stop); process.off("SIGTERM", stop); }
  } else if (command === "transcribe" || command === "dictate") {
    // SIGINT/SIGTERM abort the signal: transcribe rejects and exits 1; dictate stops the take, joins the sidecar, and exits 0 as main did.
    const cancellation = new AbortController();
    const stop = () => cancellation.abort(new Error(`${command === "transcribe" ? "transcription" : "dictation"} cancelled`));
    process.on("SIGINT", stop); process.on("SIGTERM", stop);
    try {
      if (command === "transcribe") { const { parseTranscribeArgs, runTranscribe } = await import("./transcribe"); await runTranscribe(parseTranscribeArgs(args), {}, cancellation.signal); }
      else { const { parseDictateArgs, runDictate } = await import("./dictate"); await runDictate(parseDictateArgs(args), {}, cancellation.signal); }
    } finally { process.off("SIGINT", stop); process.off("SIGTERM", stop); }
  } else {
    const parsed = parseCommand(command, args);
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
