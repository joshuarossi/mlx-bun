#!/usr/bin/env bun
import { help, isCommand, parseCommand } from "./args";
import { renderHelp } from "./terminal";
import pkg from "../../package.json" with { type: "json" };

try {
  const [first, ...rest] = process.argv.slice(2);
  const command = !first || (first.startsWith("--") && !["--help", "--version"].includes(first)) ? "serve" : first;
  const args = command === "serve" && first !== "serve" ? process.argv.slice(2) : rest;
  if (command === "__job") {
    process.exitCode = await (await import("./job-entry")).runJobEntry(args[0]);
  } else if (["--version", "-v", "version"].includes(command ?? "")) {
    console.log(`mlx-bun ${pkg.version}`);
  } else if (command === "help" || command === "--help" || command === "-h") {
    console.log(renderHelp(help(args[0])));
  } else if (!isCommand(command)) {
    throw new Error(`Unknown command: ${command}. Use mlx-bun --help.`);
  } else if (args.includes("--help") || args.includes("-h")) {
    console.log(renderHelp(help(command)));
  } else {
    const parsed = parseCommand(command, args);
    if (command === "serve") {
      const { runServe } = await import("./serve");
      await runServe(parsed);
    } else {
      const { runHub } = await import("./hub");
      await runHub(command, parsed);
    }
  }
} catch (error) {
  console.error(error instanceof Error ? (process.env.MLX_BUN_DEBUG ? error.stack ?? error.message : error.message) : String(error));
  process.exitCode = 1;
}
