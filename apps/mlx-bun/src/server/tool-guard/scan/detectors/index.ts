// The built-in check set, in atif-scan's report order. Each family file names the atif-scan module it ports.
//
// atif-scan 0.8.23 registers about 140 checks. The ones here are those that read what a tool call
// is about to do. Not ported: the families that judge a finished benchmark run rather than a
// pending call (awareness, recall, lookup of benchmark material, lures, tamper, watchers, harness,
// sweeps, integrity, context and the per-benchmark packs), and outbound-credential tracking, which
// reads Python programs with Python's own parser.
import { checkSpec, regexDetector, SEVERITY } from "../checks";
import type { Check } from "../engine";
import { delegationDetectors } from "./delegation";
import { hostFileDetectors } from "./host-files";
import { installDetectors } from "./installs";
import { orchestratorDetectors } from "./orchestrator";
import { providerKeyDetectors } from "./provider-keys";
import { sideChannelDetectors } from "./side-channel";

/** Behaviour SafeAgents checks beside atif-scan's own set (its `EXTRA_DETECTORS`, src/safeagents/scan.py;
 * Copyright 2026 the HuggingFace Inc. team, Apache License 2.0). */
const namespaceEscape = () => regexDetector(
  checkSpec("safeagents.namespace_escape", "medium", "Creates or enters Linux namespaces"),
  String.raw`\b(?:unshare|nsenter)\b`,
  new Set(["command"]),
);

export function builtinChecks(): Check[] {
  return [
    ...sideChannelDetectors(), ...hostFileDetectors(), ...providerKeyDetectors(), ...orchestratorDetectors(),
    ...delegationDetectors(), ...installDetectors(), namespaceEscape(),
    // The guard reports nothing at `info`, so those checks are not run.
  ].filter(check => SEVERITY[check.spec.severity] > SEVERITY.info);
}
