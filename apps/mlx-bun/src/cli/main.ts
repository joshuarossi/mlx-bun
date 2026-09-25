#!/usr/bin/env bun
import { commandInvocation, help, isCommand, parseCommand } from "./args";
import { renderHelp } from "./terminal";
import pkg from "../../package.json" with { type: "json" };

try {
  const { command, args } = commandInvocation(process.argv.slice(2));
  if (["--version", "-v", "version"].includes(command ?? "")) {
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
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
