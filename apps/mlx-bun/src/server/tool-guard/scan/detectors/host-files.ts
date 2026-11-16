// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c), src/atif_scan/detectors/host_files.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// Files copied into the sandbox from the harness host.
//
// A harness that relays actions from outside the sandbox can upload host files: SLAI Agent
// Runtime's TB2.1 submission (`tb_bridge.upload`, `host_path: D:\terminal_bench_slai\…`)
// uploaded portable toolchains, prepared per-task scripts and, in 4 tasks, the task's own
// `tasks\<task>\solution\solve.sh` from a benchmark checkout. What arrives is a host file,
// not anything the trace shows a model writing. Read from tool arguments: a host-path key
// (`host_path`, `local_path`) on any call, or a Windows drive or UNC path a write names.
import { checkSpec, detectionOf, type CheckSpec, type Detection, type Detector, type Unread } from "../checks";
import type { Channel, Locator, Step, ToolCall, Trace } from "../model";
import { hostPaths } from "../tools";

// A prepared answer: a file named as a solution, answer or oracle, or a task folder's
// `solution/` (a benchmark checkout on the host).
// `(?=\n?$)` is Python's `$` without MULTILINE: the end, or just before a final newline.
const SOLUTION_FILE = /(?<![a-z])(?:solution|solve|answers?|oracle)[^\\/]*(?=\n?$)|[\\/]solution[\\/]/i;

const HOST_PATH_CHANNELS: ReadonlySet<Channel> = new Set<Channel>(["path", "arguments"]);

/** The call's field holding `value` (its arguments' order), else the call. */
function located(step: Step, call: ToolCall, value: string): Locator {
  const index = call.fields.findIndex(([, c]) => c.text === value);
  const field = call.fields[index];
  if (field === undefined) return { step: step.index, channel: "arguments", call: call.index };
  return { step: step.index, channel: field[0], call: call.index, field: index };
}

/** Calls naming a host file `accept`s; unknown when an argument that could name one
 * wasn't read. */
class HostFileUpload implements Detector {
  constructor(
    readonly spec: CheckSpec,
    private readonly accept: (value: string) => boolean,
  ) {}

  evaluate(trace: Trace): Detection {
    const hits: Locator[] = [];
    const unread: Unread[] = [];
    for (const [step, call] of trace.agentCalls()) {
      for (const [i, [channel, value]] of call.fields.entries())
        if (HOST_PATH_CHANNELS.has(channel) && !value.understood)
          unread.push({ reason: "unreadable", at: { step: step.index, channel, call: call.index, field: i } });
      for (const value of hostPaths(call.tool, call.arguments)) if (this.accept(value)) hits.push(located(step, call, value));
    }
    return detectionOf(hits, trace.agentSteps > 0 && !unread.length, unread);
  }
}

export function hostFileDetectors(): Detector[] {
  return [
    new HostFileUpload(checkSpec("side_channel.host_file_upload", "medium", "File copied in from the harness host"), () => true),
    new HostFileUpload(
      checkSpec("side_channel.host_solution_upload", "high", "Solution file copied in from the harness host"),
      value => SOLUTION_FILE.test(value),
    ),
  ];
}
