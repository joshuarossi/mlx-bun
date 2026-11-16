// Ported from atif-scan 0.8.23 (commit 3bbaf3c): tests/test_scripted_relay.py, the cases that
// exercise `side_channel.host_file_upload` and `side_channel.host_solution_upload`. A harness
// replaying prepared actions with no model (synthetic, after SLAI Agent Runtime's TB2.1
// submission): `tb_bridge.*` calls relayed from a host client, host files uploaded from a
// Windows benchmark checkout.
//
// The three ported cases keep only their assertions on these two checks; their other assertions
// (lookup.own_task_files, lookup.benchmark_task_files, code.verifier_path_reference) belong to
// other detector modules and need the benchmark task. Step fields the guard trace has no place
// for (`llm_call_count`, the agent's model name) are left out.
//
// Skipped Python cases (none mentions these two checks): the scripted-relay, tool-name,
// relayed-command, write-contents and verifier-toolchain cases of the same file.
import { expect, test } from "bun:test";
import type { Status } from "../../../src/server/tool-guard/scan/checks";
import { hostFileDetectors } from "../../../src/server/tool-guard/scan/detectors/host-files";
import { parseTrace, rawToolCall, type RawStep } from "../../../src/server/tool-guard/scan/trace";

const TASK = "make-doom-for-mips";
const CHECKOUT = "D:\\bench\\terminal-bench-2-1-main\\tasks";

function bridge(action: string, args: Record<string, unknown>): RawStep {
  const call = rawToolCall(`r-${action}`, `tb_bridge.${action}`, { ...args, action, request_id: "r1", client: "tb_bridge_cli" });
  return { source: "agent", message: `bridge ${action} rc=0`, toolCalls: [call] };
}

function trace(...steps: RawStep[]): RawStep[] {
  return [
    { source: "system", message: "Supervisor registered a job; it did not call an LLM." },
    { source: "user", message: "Task packet written." },
    ...steps,
  ];
}

function results(raw: RawStep[]): Record<string, Status> {
  const parsed = parseTrace(raw);
  return Object.fromEntries(hostFileDetectors().map(d => [d.spec.id, d.evaluate(parsed).status]));
}

test("check identities", () => {
  expect(hostFileDetectors().map(d => [d.spec.id, d.spec.severity, d.spec.title])).toEqual([
    ["side_channel.host_file_upload", "medium", "File copied in from the harness host"],
    ["side_channel.host_solution_upload", "high", "Solution file copied in from the harness host"],
  ]);
});

test("uploaded task solution from a Windows checkout", () => {
  const raw = trace(bridge("upload", { path: "/app/.assets/solve.sh", host_path: `${CHECKOUT}\\${TASK}\\solution\\solve.sh` }));
  const found = results(raw);
  for (const check of ["side_channel.host_file_upload", "side_channel.host_solution_upload"])
    expect([check, found[check]]).toEqual([check, "match"]);
});

test("uploaded toolchain is a host file but no solution", () => {
  const raw = trace(
    bridge("upload", { path: "/app/py.tar.gz", host_path: "D:\\cache\\portable_py311.tar.gz" }),
    bridge("upload", { path: "/app/x", local_path: "/home/me/resolve_deps.sh" }),
  );
  const found = results(raw);
  expect(found["side_channel.host_file_upload"]).toBe("match");
  expect(found["side_channel.host_solution_upload"]).toBe("no_match");
});

test("Windows paths elsewhere are not host uploads", () => {
  const raw = trace(bridge("read", { path: "D:\\work\\solution_notes\\solve.md" }));
  expect(results(raw)["side_channel.host_file_upload"]).toBe("no_match"); // a read, not a copy in
});

// Not a Python case: the evidence names the argument holding the host path.
test("evidence points at the host path field", () => {
  const hostPath = `${CHECKOUT}\\${TASK}\\solution\\solve.sh`;
  const parsed = parseTrace(trace(bridge("upload", { path: "/app/.assets/solve.sh", host_path: hostPath })));
  const [upload] = hostFileDetectors();
  const at = upload?.evaluate(parsed).evidence[0];
  expect(at?.step).toBe(2);
  expect(at?.call).toBe(0);
  expect(parsed.steps[2]?.calls[0]?.fields[at?.field ?? -1]?.[1].text).toBe(hostPath);
});
