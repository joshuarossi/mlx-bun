// Ported from SafeAgents (https://github.com/huggingface/safeagents, commit a8ee22d), src/safeagents/guard.py,
// src/safeagents/rewrite.py and src/safeagents/journal.py. Copyright 2026 the HuggingFace Inc. team.
// Apache License 2.0; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Decides, call by call, whether a response's tool calls reach the client.
//
// 1. A call to a tool the request never declared, or reaching a host that appears nowhere in the
//    conversation, is blocked outright.
// 2. Scanner findings at or above `blockSeverity` are blocked too.
// 3. Milder findings make a call suspicious: the judge, if there is one, decides. Without one,
//    suspicious calls are only logged.
//
// SafeAgents is a proxy that holds and rewrites another server's response bytes. Here the guard
// runs where the server's own tool calls are first complete (`CompletionExecutor`), before any
// protocol writes them, so there is nothing to hold or reassemble.
import { appendFileSync, mkdirSync, readFileSync } from "node:fs";
import { dirname } from "node:path";
import { SEVERITY, type SeverityName } from "./scan/checks";
import { loadPolicy } from "./scan/engine";
import { history, recent, type RawStep } from "./scan/trace";
import { Judge, JudgeError, taskText, type Decide } from "./judge";
import { DEFAULT_ALLOWED_HOSTS, RequestPolicy } from "./policy";
import { Scanner, signalText, type Signal } from "./scanner";

/** `serve --tool-guard` and its options, as plain data: the isolated host sends them to each model worker. */
export interface ToolGuardOptions {
  /** `block` replaces a flagged call with a text notice; `log` reports it and changes nothing. */
  mode: "log" | "block";
  /** Hosts calls may reach besides the built-in list, subdomains included. */
  allowHosts?: string[];
  /** false keeps the request-only checks and turns the scanner off. */
  scan?: boolean;
  /** Scanner findings at or above this block without asking the judge [high]. */
  blockSeverity?: Exclude<SeverityName, "info">;
  /** A JSON file of extra detectors, rules and allowances. */
  policyFile?: string;
  /** Ask the served model, as a local decision, about calls with milder findings. */
  judge?: boolean;
  /** What a scanner or judge failure means for the call it was reviewing [allow]. */
  onError?: "allow" | "block";
  /** A JSON-lines file keeping every call that was not simply passed, with its arguments. */
  journal?: string;
}

// Some of the ported patterns take time quadratic in the length of one line or token run, and the
// scan runs on the serving thread. These two bounds keep a hostile input from holding it for long.
/** Arguments longer than this are not scanned: the call is treated as a failed scan. */
export const MAX_SCANNED_ARGUMENTS = 262_144;
/** Each earlier tool result is read up to this many characters. */
export const MAX_SCANNED_RESULT = 16_384;

export interface GuardedCall {
  function: { name: string; arguments: string };
}

export type Verdict = "passed" | "suspicious" | "flagged" | "blocked";

/** What the guard found out about one call. */
export interface Review {
  /** Why the call is blocked; null when it may run. */
  reason: string | null;
  signals: Signal[];
  /** The judge's answer as "allow p=0.93", "block p=0.71" or "error: why". */
  judge: string | null;
}

export interface ReviewOutcome<Call> {
  /** The calls the client receives, in the model's order. */
  kept: Call[];
  /** One notice per blocked call. Empty in log mode. */
  notices: string[];
}

/** Reviews the tool calls of one response to one request. */
export type ToolCallReviewer = <Call extends GuardedCall>(calls: readonly Call[], signal?: AbortSignal) => Promise<ReviewOutcome<Call>>;

export interface ToolGuard {
  readonly options: ToolGuardOptions;
  /** The reviewer for one request: `request` is the chat body the model answered. */
  forRequest(request: { messages?: unknown; tools?: unknown }): ToolCallReviewer;
}

export const blockedNotice = (name: string, reason: string): string => `[mlx-bun tool-guard] blocked call to \`${name}\`: ${reason}`;

export interface ToolGuardDependencies {
  /** The served model's id, recorded in the journal. */
  model?: string;
  /** The served model's decision scoring; the judge needs it. */
  decide?: Decide;
  log?(line: string): void;
  now?(): number;
  judgeTimeoutMs?: number;
}

/** Build the guard once per served model: reads the policy file and fails on an invalid one. */
export function createToolGuard(options: ToolGuardOptions, dependencies: ToolGuardDependencies = {}): ToolGuard {
  const log = dependencies.log ?? (line => console.warn(line));
  const blockSeverity = SEVERITY[options.blockSeverity ?? "high"];
  const allowedHosts = [...DEFAULT_ALLOWED_HOSTS, ...(options.allowHosts ?? [])];
  const failClosed = options.onError === "block";
  let scanner: Scanner | null = null;
  if (options.scan !== false) {
    let checks: ReturnType<typeof loadPolicy> = [];
    if (options.policyFile !== undefined) {
      try { checks = loadPolicy(JSON.parse(readFileSync(options.policyFile, "utf8"))); }
      catch (error) { throw new Error(`--tool-guard-policy ${options.policyFile}: ${error instanceof Error ? error.message : String(error)}`); }
    }
    try { scanner = new Scanner(checks); }
    catch (error) { throw new Error(`--tool-guard-policy ${options.policyFile ?? ""}: ${error instanceof Error ? error.message : String(error)}`); }
  }
  const judge = options.judge
    ? new Judge(dependencies.decide ?? (async () => null), dependencies.model ?? "", dependencies.judgeTimeoutMs) : null;

  let journalFailed = false;
  const record = (entry: Record<string, unknown>): void => {
    if (options.journal === undefined) return;
    try {
      // Arguments can hold secrets, so the file is readable by its owner only.
      mkdirSync(dirname(options.journal), { recursive: true, mode: 0o700 });
      appendFileSync(options.journal, `${JSON.stringify(entry)}\n`, { mode: 0o600 });
    } catch (error) {
      if (!journalFailed) log(`[tool-guard] journal ${options.journal} is not writable: ${error instanceof Error ? error.message : String(error)}`);
      journalFailed = true;
    }
  };

  return {
    options,
    forRequest(request) {
      // Built for the first call: most responses make none.
      let policy: RequestPolicy | undefined;
      const calls: { name: string; arguments: string }[] = [];
      let steps: RawStep[] | undefined;

      const scan = async (name: string, args: string, signal?: AbortSignal): Promise<Review> => {
        if (!scanner) return { reason: null, signals: [], judge: null };
        steps ??= recent(history(request)).map(step => (step.results
          ? { ...step, results: step.results.map(result => ({ ...result, content: result.content.slice(0, MAX_SCANNED_RESULT) })) } : step));
        const { signals, errors } = args.length > MAX_SCANNED_ARGUMENTS
          ? { signals: [], errors: [`arguments over ${MAX_SCANNED_ARGUMENTS} characters`] }
          : scanner.scan(steps, calls.filter(call => call.arguments.length <= MAX_SCANNED_ARGUMENTS));
        const severe = signals.filter(found => SEVERITY[found.severity] >= blockSeverity);
        if (severe.length) return { reason: `scan: ${severe.map(signalText).join(", ")}`, signals, judge: null };
        if (errors.length) {
          log(`[tool-guard] scan failed on call to \`${name}\`: ${errors.join(", ")}`);
          if (failClosed) return { reason: `scan failed: ${errors.join(", ")}`, signals, judge: null };
        }
        if (!signals.length || !judge) return { reason: null, signals, judge: null };
        const findings = signals.map(signalText).join(", ");
        try {
          const verdict = await judge.review(request, name, args, signals, signal);
          return verdict.block
            ? { reason: `${findings}; judge: block ${verdict.reason}`.trimEnd(), signals, judge: `block ${verdict.reason}`.trimEnd() }
            : { reason: null, signals, judge: `allow ${verdict.reason}`.trimEnd() };
        } catch (error) {
          if (!(error instanceof JudgeError)) throw error;
          return { reason: failClosed ? `${findings}; judge unavailable` : null, signals, judge: `error: ${error.message}` };
        }
      };

      const review = async (name: string, args: string, signal?: AbortSignal): Promise<Review> => {
        calls.push({ name, arguments: args });
        try {
          const reason = (policy ??= new RequestPolicy(request, allowedHosts)).check(name, args);
          return reason === null ? await scan(name, args, signal) : { reason, signals: [], judge: null };
        } catch (error) {
          // A cancelled request forwards nothing; any other failure follows the error policy.
          if (signal?.aborted) throw error;
          const message = error instanceof Error ? error.message : String(error);
          log(`[tool-guard] review failed on call to \`${name}\`: ${message}`);
          return { reason: failClosed ? "review failed" : null, signals: [], judge: null };
        }
      };

      return async (pending, signal) => {
        const kept: (typeof pending)[number][] = [], notices: string[] = [];
        for (const call of pending) {
          signal?.throwIfAborted();
          const { name, arguments: args } = call.function;
          const result = await review(name, args, signal);
          const blocked = result.reason !== null && options.mode === "block";
          const verdict: Verdict = result.reason !== null ? (blocked ? "blocked" : "flagged") : result.signals.length ? "suspicious" : "passed";
          if (verdict !== "passed") {
            record({ time: (dependencies.now ?? Date.now)() / 1000, verdict, tool: name, arguments: args, reason: result.reason,
              signals: result.signals, judge: result.judge, model: dependencies.model ?? "", task: taskText(request) });
            const why = result.reason ?? result.signals.map(signalText).join(", ");
            // A block decision is already in the reason; an allow or a failure is not.
            log(`[tool-guard] ${verdict} call to \`${name}\`: ${why}${result.judge && !result.judge.startsWith("block") ? ` (judge ${result.judge})` : ""}`);
          }
          if (blocked) notices.push(blockedNotice(name, result.reason!));
          else kept.push(call);
        }
        return { kept, notices };
      };
    },
  };
}
