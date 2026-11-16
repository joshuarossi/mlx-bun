// Ported from SafeAgents (https://github.com/huggingface/safeagents, commit a8ee22d), src/safeagents/scan.py.
// Copyright 2026 the HuggingFace Inc. team. Apache License 2.0; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Runs the checks on the tool calls a response is about to make. Only findings whose evidence
// points at the pending call are kept.
import { SEVERITY, type SeverityName } from "./scan/checks";
import { builtinChecks } from "./scan/detectors";
import { Engine, type Check } from "./scan/engine";
import { callStep, parseTrace, type RawStep } from "./scan/trace";

export interface Signal {
  readonly id: string;
  readonly severity: SeverityName;
  readonly title: string;
}

export const signalText = (signal: Signal): string => `${signal.id} (${signal.severity})`;

export interface ScanResult {
  readonly signals: Signal[];
  /** Checks that failed on this trace, or `scanner` when the scan itself did. A failed check is
   * never a finding; the guard's error policy decides what a failure means for the call. */
  readonly errors: string[];
}

/** Runs the built-in checks and the `checks` a policy file adds. */
export class Scanner {
  readonly #engine: Engine;

  constructor(checks: readonly Check[] = []) {
    this.#engine = new Engine([...builtinChecks(), ...checks]);
  }

  /** Every check this scanner runs. */
  catalog() { return this.#engine.catalog(); }

  /** Findings on the last of `calls`, judged after the conversation `steps`. */
  scan(steps: readonly RawStep[], calls: readonly { name: string; arguments: string }[]): ScanResult {
    const lastStep = steps.length, lastCall = calls.length - 1;
    try {
      const signals: Signal[] = [], errors: string[] = [];
      for (const assessment of this.#engine.evaluate(parseTrace([...steps, callStep(calls)]))) {
        const { spec, result } = assessment;
        if (result.status === "error") errors.push(spec.id);
        if (!assessment.counts || SEVERITY[spec.severity] <= SEVERITY.info) continue;
        if (result.evidence.some(at => at.step === lastStep && at.call === lastCall))
          signals.push({ id: spec.id, severity: spec.severity, title: spec.title });
      }
      return { signals, errors };
    } catch {
      return { signals: [], errors: ["scanner"] };
    }
  }
}
