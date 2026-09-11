import { expect, test } from "bun:test";
import { ORACLE_PYTHON } from "../support/paths";

const enabled = Bun.env.MLX_BUN_TEST_ASSISTANT_ORACLE === "1";
test.skipIf(!enabled)("shared assistant B1 matches optiq spec_generate end to end", async () => {
  const target = Bun.env.MLX_BUN_TEST_MTP_TARGET!, draft = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
  const depth = 2, maxTokens = 48;
  // Finish Python before loading native target weights in this process.
  const oracle = Bun.spawnSync([ORACLE_PYTHON,"scripts/oracle/oracle-spec.py",target,draft,String(depth),String(maxTokens)],
    { cwd: `${import.meta.dir}/../..`, env: process.env });
  expect(oracle.exitCode,oracle.stderr.toString()).toBe(0);
  const output = oracle.stdout.toString();
  const tokens = (label: string) => {
    const line = output.split("\n").find(line => line.startsWith(label));
    expect(line,output).toBeDefined();
    return line!.slice(label.length).trim().split(",").map(Number);
  };
  const promptIds = tokens("PROMPT_IDS:"), expected = tokens("OUT_IDS:");
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { AssistantProvider } = await import("../../src/spec/assistant-source");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindSpeculativeGroupRequests } = await import("../../src/backends/mlx/speculative-group");
  using resources = new DisposableStack();
  const weights = await Weights.open(target); resources.defer(() => weights.dispose());
  const model = createModel(weights,await loadModelConfig(target));
  const provider = await AssistantProvider.load(draft); resources.defer(() => provider.dispose());
  const group = new MlxBatchExecutionGroup(model,{ maxBatch:4 });
  try {
    const actual: number[] = [];
    const stats = await group.submit({ method:bindSpeculativeGroupRequests(model,provider,depth)({temperature:0,maxTokens}),
      promptIds,maxTokens,eosTokenIds:model.config.eosTokenIds,onToken(token) { actual.push(token); } });
    expect(actual).toEqual(expected);
    expect(stats.spec!.accepted).toBeGreaterThan(0);
    expect(stats.spec!.targetCalls).toBeLessThan(actual.length);
  } finally { await group.close(); }
},120000);
