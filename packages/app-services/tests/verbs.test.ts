import { expect, test } from "bun:test";
import type { CliVerbSpec } from "@mlx-bun/app-core";
import { parseVerb, positionalUsage, verbArguments, verbHelp, verbUsage } from "../src";

const spec: CliVerbSpec = {
  name: "clip", summary: "Cut a clip", usage: "usage: prog clip <file> [more] [--len N]",
  positional: [{ name: "file", summary: "input", required: true }, { name: "more", summary: "another" }],
  options: [
    { name: "len", type: "number", summary: "Seconds [default: 5]" },
    { name: "name", type: "string", summary: "Output name" },
    { name: "loud", type: "boolean", summary: "Louder" },
    { name: "key", type: "number", optionalValue: true, default: 61, summary: "Key [default: 61]" },
    { name: "tag", type: "string", repeatable: true, summary: "Tags" },
  ],
};

test("options and positionals parse against the manifest: numbers as numbers, absent flags undefined", () => {
  expect(parseVerb("prog", spec, ["a.wav", "--len", "2.5", "--loud", "--name=x", "b.wav"]))
    .toEqual({ values: { len: 2.5, loud: true, name: "x" }, positionals: ["a.wav", "b.wav"] });
  expect(parseVerb("prog", spec, ["a.wav"]).values).toEqual({});
  expect(parseVerb("prog", spec, ["a.wav", "--tag", "x", "--tag", "y"]).values).toEqual({ tag: ["x", "y"] });
});

test("a flag with an optional value takes the next token unless it looks like a flag, else its default", () => {
  expect(parseVerb("prog", spec, ["a", "--key"]).values.key).toBe(61);
  expect(parseVerb("prog", spec, ["a", "--key", "55"]).values.key).toBe(55);
  expect(parseVerb("prog", spec, ["--key=55", "a"]).values.key).toBe(55);
  expect(parseVerb("prog", spec, ["a", "--key", "--loud"]).values).toEqual({ key: 61, loud: true });
  expect(parseVerb("prog", spec, ["a", "--key", "abc"]).values.key).toBe(61);
  expect(parseVerb("prog", spec, ["--key", "0", "a"]).values.key).toBe(61);
});

test("errors: usage for a missing required positional or a valueless option, too many arguments, unknown flags, invalid numbers", () => {
  expect(() => parseVerb("prog", spec, [])).toThrow("usage: prog clip <file> [more] [--len N]");
  expect(() => parseVerb("prog", spec, ["a", "--name"])).toThrow("usage: prog clip <file> [more] [--len N]");
  expect(() => parseVerb("prog", spec, ["a", "b", "c"])).toThrow("Too many arguments for clip");
  expect(() => parseVerb("prog", spec, ["a", "--bogus"])).toThrow("Unknown option '--bogus'");
  for (const bad of [["--len", "x"], ["--len", ""]]) expect(() => parseVerb("prog", spec, ["a", ...bad])).toThrow(/^invalid --len: /);
  expect(verbUsage("prog", { ...spec, usage: undefined })).toBe("usage: prog clip <file> [more]");
  expect(positionalUsage({ ...spec, positional: [{ name: "f", summary: "", repeatable: true }] })).toBe("[f...]");
});

test("help lists the description, usage and one row per option", () => {
  expect(verbHelp("prog", spec)).toBe(`prog clip — Cut a clip

Usage: prog clip <file> [more] [options]

Options:
  --len <value>            Seconds [default: 5]
  --name <value>           Output name
  --loud                   Louder
  --key <value>            Key [default: 61]
  --tag <value>            Tags
  -h, --help               Show help`);
});

test("a verb's details paragraph is printed between the usage line and the options", () => {
  const help = verbHelp("prog", { ...spec, details: "Subcommands:\n  a   First\n  b   Second" });
  expect(help).toContain("Usage: prog clip <file> [more] [options]\n\nSubcommands:\n  a   First\n  b   Second\n\nOptions:\n  --len <value>");
  expect(verbHelp("prog", spec)).not.toContain("Subcommands");
});

test("a short spelling parses and is listed, and a flag can name its own message for a missing value", () => {
  const withShort: CliVerbSpec = { name: "cut", summary: "Cut", options: [
    { name: "quiet", type: "boolean", short: "q", summary: "Say less" },
    { name: "repo", type: "string", missingValue: "--repo expects a repo id (org/name)", summary: "Target" },
  ] };
  expect(parseVerb("prog", withShort, ["-q"]).values).toEqual({ quiet: true });
  expect(verbHelp("prog", withShort)).toContain("  -q, --quiet              Say less");
  expect(() => parseVerb("prog", withShort, ["--repo"])).toThrow("--repo expects a repo id (org/name)");
  expect(() => parseVerb("prog", withShort, ["--repo", "-q"])).toThrow("--repo expects a repo id (org/name)");
  expect(() => parseVerb("prog", { ...withShort, options: [{ name: "repo", type: "string", summary: "" }] }, ["--repo"])).toThrow("argument missing");
});

test("values parsed elsewhere (another spelling of the verb) get the same positional rules and number coercion", () => {
  expect(verbArguments("prog", spec, { len: "3", loud: true, ignored: "x" }, ["a"])).toEqual({ values: { len: 3, loud: true }, positionals: ["a"] });
  expect(() => verbArguments("prog", spec, {}, [])).toThrow("usage: prog clip <file> [more] [--len N]");
  expect(() => verbArguments("prog", spec, {}, ["a", "b", "c"])).toThrow("Too many arguments for clip");
  expect(() => verbArguments("prog", spec, { len: "x" }, ["a"])).toThrow("invalid --len: x");
});
