// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c),
// src/atif_scan/rules.py, src/atif_scan/engine.py and src/atif_scan/policy.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Declarative expressions in strong Kleene three-valued logic, and their dependency-ordered
// evaluation with isolated failures: a check that throws is an `error` result, never a crash and
// never a match.
import { checkSpec, detection, identifier, regexDetector, SEVERITY, type CheckSpec, type Detection, type Detector, type SeverityName } from "./checks";
import type { Channel, Locator, Trace } from "./model";

export type Truth = boolean | null;
type Results = ReadonlyMap<string, Detection>;

export interface Expression {
  dependencies(): ReadonlySet<string>;
  evaluate(results: Results): Truth;
}

const union = (children: readonly Expression[]): ReadonlySet<string> => new Set(children.flatMap(child => [...child.dependencies()]));

export class Ref implements Expression {
  constructor(readonly id: string) { identifier(id); }
  dependencies(): ReadonlySet<string> { return new Set([this.id]); }
  evaluate(results: Results): Truth {
    const status = results.get(this.id)!.status;
    return status === "match" ? true : status === "no_match" ? false : null;
  }
}

export class Not implements Expression {
  constructor(readonly child: Expression) {}
  dependencies(): ReadonlySet<string> { return this.child.dependencies(); }
  evaluate(results: Results): Truth {
    const value = this.child.evaluate(results);
    return value === null ? null : !value;
  }
}

export class All implements Expression {
  constructor(readonly children: readonly Expression[]) {}
  dependencies(): ReadonlySet<string> { return union(this.children); }
  evaluate(results: Results): Truth {
    const values = this.children.map(child => child.evaluate(results));
    return values.includes(false) ? false : values.includes(null) ? null : true;
  }
}

export class AnyOf implements Expression {
  constructor(readonly children: readonly Expression[]) {}
  dependencies(): ReadonlySet<string> { return union(this.children); }
  evaluate(results: Results): Truth {
    // A check that doesn't apply can't have matched: it doesn't make "any of" unknown.
    const values = this.children
      .filter(child => !(child instanceof Ref && results.get(child.id)!.status === "not_applicable"))
      .map(child => child.evaluate(results));
    return values.includes(true) ? true : values.includes(null) ? null : false;
  }
}

/** A finding when the antecedent is true and the consequent is false. */
export class Requires implements Expression {
  constructor(readonly antecedent: Expression, readonly consequent: Expression) {}
  dependencies(): ReadonlySet<string> { return union([this.antecedent, this.consequent]); }
  evaluate(results: Results): Truth { return new All([this.antecedent, new Not(this.consequent)]).evaluate(results); }
}

function evaluateExpression(expression: Expression, results: Results): Detection {
  const truth = expression.evaluate(results);
  if (truth === null) return detection("unknown");
  // Short-circuit truth can be known even when an irrelevant input is unknown.
  if (truth === false) return detection("no_match");
  const dependencies = [...expression.dependencies()].sort().map(id => results.get(id)!);
  const evidence: Locator[] = [];
  for (const result of dependencies) if (result.status === "match") evidence.push(...result.evidence);
  return detection("match", evidence, dependencies.every(result => result.complete));
}

/** Combines already-evaluated results; a match cites its matched dependencies' evidence. */
export class Rule {
  constructor(readonly spec: CheckSpec, readonly expression: Expression) {}
  get dependencies(): string[] { return [...this.expression.dependencies()].sort(); }
  evaluate(results: Results): Detection { return evaluateExpression(this.expression, results); }
}

/** Declares that matches of `covers` are expected. It never changes what a detector found: while
 * `when` is true (or absent), the matches it covers are excused. An unknown `when` excuses nothing. */
export class Allowance {
  constructor(readonly spec: CheckSpec, readonly covers: ReadonlySet<string>, readonly when: Expression | null = null) {
    if (!covers.size) throw new Error("allowance_must_cover_checks");
    for (const id of covers) identifier(id);
  }
  get dependencies(): string[] { return this.when ? [...this.when.dependencies()].sort() : []; }
  evaluate(results: Results): Detection { return this.when ? evaluateExpression(this.when, results) : detection("match"); }
}

export type Check = Detector | Rule | Allowance;

export interface Assessment {
  readonly spec: CheckSpec;
  readonly result: Detection;
  readonly kind: "detector" | "rule" | "allowance";
  /** Applied allowances covering this match. */
  readonly expectedBy: readonly string[];
  /** An unexcused finding. */
  readonly counts: boolean;
}

/** Check IDs with every rule after its dependencies (ties in ID order). */
function dependencyOrder(checks: ReadonlyMap<string, Detector | Rule>): string[] {
  const order: string[] = [], active = new Set<string>(), done = new Set<string>();
  const visit = (id: string): void => {
    if (active.has(id)) throw new Error("dependency_cycle");
    if (done.has(id)) return;
    const check = checks.get(id);
    if (!check) throw new Error(`missing_dependency: ${id}`);
    active.add(id);
    if (check instanceof Rule) for (const dependency of check.dependencies) visit(dependency);
    active.delete(id);
    done.add(id);
    order.push(id);
  };
  for (const id of [...checks.keys()].sort()) visit(id);
  return order;
}

/** Evaluates detectors and rules in dependency order, then allowances. Allowances may reference
 * detectors and rules; nothing may reference an allowance. */
export class Engine {
  readonly #allowances: Allowance[];
  readonly #checks = new Map<string, Detector | Rule>();
  readonly #order: string[];

  constructor(checks: readonly Check[]) {
    const ids = checks.map(check => check.spec.id);
    if (new Set(ids).size !== ids.length) throw new Error(`duplicate_check_id: ${ids.find((id, index) => ids.indexOf(id) !== index)}`);
    this.#allowances = checks.filter(check => check instanceof Allowance).sort((a, b) => (a.spec.id < b.spec.id ? -1 : 1));
    for (const check of checks) if (!(check instanceof Allowance)) this.#checks.set(check.spec.id, check);
    this.#order = dependencyOrder(this.#checks);
    for (const allowance of this.#allowances)
      for (const id of [...allowance.dependencies, ...allowance.covers])
        if (!this.#checks.has(id)) throw new Error(`missing_dependency: ${id}`);
  }

  /** Every check this engine runs, sorted by ID. */
  catalog(): CheckSpec[] {
    return [...this.#checks.values(), ...this.#allowances].map(check => check.spec).sort((a, b) => (a.id < b.id ? -1 : 1));
  }

  evaluate(trace: Trace): Assessment[] {
    const results = new Map<string, Detection>();
    const run = (check: Check): Detection => {
      // A check that throws or returns evidence outside the trace is an error result for that check alone.
      try {
        const result = check instanceof Rule || check instanceof Allowance ? check.evaluate(results) : check.evaluate(trace);
        validateEvidence(trace, result);
        return result;
      } catch {
        return detection("error");
      }
    };
    for (const id of this.#order) results.set(id, run(this.#checks.get(id)!));
    const excused = new Map<string, string[]>();
    const allowed: Assessment[] = [];
    for (const allowance of this.#allowances) {
      const result = run(allowance);
      if (result.status === "match")
        for (const id of allowance.covers) excused.set(id, [...(excused.get(id) ?? []), allowance.spec.id]);
      allowed.push({ spec: allowance.spec, result, kind: "allowance", expectedBy: [], counts: false });
    }
    const assessments = this.#order.map((id): Assessment => {
      const check = this.#checks.get(id)!, result = results.get(id)!;
      const expectedBy = result.status === "match" ? excused.get(id) ?? [] : [];
      return { spec: check.spec, result, kind: check instanceof Rule ? "rule" : "detector", expectedBy,
        counts: result.status === "match" && !expectedBy.length };
    });
    return [...assessments, ...allowed];
  }
}

/** Reject locators pointing outside the trace. */
function validateEvidence(trace: Trace, result: Detection): void {
  for (const at of result.evidence) {
    const step = trace.steps[at.step];
    if (!step) throw new Error("invalid_evidence_locator");
    if (at.call !== undefined && at.call >= step.calls.length) throw new Error("invalid_call_locator");
    if (at.field !== undefined && (at.call === undefined || at.field >= step.calls[at.call]!.fields.length)) throw new Error("invalid_field_locator");
    if (at.observation !== undefined && at.observation >= step.observations.length) throw new Error("invalid_observation_locator");
  }
}

// --- Policy files -------------------------------------------------------------------------------
// atif-scan's JSON rule language (`{"rules": [...], "allow": [...]}`), with no evaluation of code.
// `detectors` is this port's addition: SafeAgents loads custom checks from Python plugin modules,
// which a Bun server cannot run, so the plugin's most common check, a regular expression over
// chosen argument channels (atif-scan's `RegexDetector`), is declared as data instead.

const MAX_DEPTH = 32;
const DETECTOR_CHANNELS: ReadonlySet<string> = new Set(["command", "path", "query", "url", "arguments", "payload"]);

function expression(value: unknown, depth = 0): Expression {
  if (depth > MAX_DEPTH) throw new Error("expression_too_deep");
  if (typeof value === "string") return new Ref(value);
  if (typeof value !== "object" || value === null || Array.isArray(value) || Object.keys(value).length !== 1) throw new Error("invalid_expression");
  const [operator, argument] = Object.entries(value)[0]!;
  if (operator === "not") return new Not(expression(argument, depth + 1));
  if (!["all", "any", "requires"].includes(operator) || !Array.isArray(argument) || !argument.length) throw new Error("invalid_expression");
  const children = argument.map(child => expression(child, depth + 1));
  if (operator === "all") return new All(children);
  if (operator === "any") return new AnyOf(children);
  if (children.length !== 2) throw new Error("invalid_expression");
  return new Requires(children[0]!, children[1]!);
}

function record(raw: unknown, allowed: readonly string[], required: readonly string[], error: string): Record<string, unknown> {
  if (typeof raw !== "object" || raw === null || Array.isArray(raw)) throw new Error(error);
  const entry = raw as Record<string, unknown>;
  if (Object.keys(entry).some(key => !allowed.includes(key)) || required.some(key => !(key in entry))) throw new Error(error);
  return entry;
}

function severity(value: unknown): SeverityName {
  const name = typeof value === "string" ? value.toLowerCase() : "";
  if (!Object.hasOwn(SEVERITY, name)) throw new Error("invalid_severity");
  return name as SeverityName;
}

const title = (entry: Record<string, unknown>): string => {
  if (entry.title !== undefined && typeof entry.title !== "string") throw new Error("invalid_check_title");
  return entry.title ?? "";
};

/** Parse `{"detectors": [...], "rules": [...], "allow": [...]}`; any section may be omitted. */
export function loadPolicy(value: unknown): Check[] {
  if (typeof value !== "object" || value === null || Array.isArray(value)) throw new Error("invalid_policy");
  const policy = value as Record<string, unknown>;
  const sections = Object.keys(policy);
  if (!sections.length || sections.some(key => !["detectors", "rules", "allow"].includes(key)) || Object.values(policy).some(section => !Array.isArray(section)))
    throw new Error("invalid_policy");
  const detectors = ((policy.detectors ?? []) as unknown[]).map((raw): Check => {
    const entry = record(raw, ["id", "severity", "title", "pattern", "channels"], ["id", "severity", "pattern"], "invalid_detector");
    const channels = entry.channels ?? ["command", "arguments"];
    if (typeof entry.pattern !== "string" || !Array.isArray(channels) || !channels.length || channels.some(channel => !DETECTOR_CHANNELS.has(channel as string)))
      throw new Error("invalid_detector");
    return regexDetector(checkSpec(entry.id as string, severity(entry.severity), title(entry)), entry.pattern, new Set(channels as Channel[]));
  });
  const rules = ((policy.rules ?? []) as unknown[]).map((raw): Check => {
    const entry = record(raw, ["id", "severity", "when", "title"], ["id", "severity", "when"], "invalid_rule");
    return new Rule(checkSpec(entry.id as string, severity(entry.severity), title(entry)), expression(entry.when));
  });
  const allowances = ((policy.allow ?? []) as unknown[]).map((raw): Check => {
    const entry = record(raw, ["id", "covers", "when", "title"], ["id", "covers"], "invalid_allowance");
    if (!Array.isArray(entry.covers) || !entry.covers.length || entry.covers.some(id => typeof id !== "string")) throw new Error("invalid_allowance");
    return new Allowance(checkSpec(entry.id as string, "info", title(entry)), new Set(entry.covers as string[]), "when" in entry ? expression(entry.when) : null);
  });
  return [...detectors, ...rules, ...allowances];
}
