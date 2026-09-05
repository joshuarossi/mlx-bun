import { expect, test } from "bun:test";
import { ExecutionCoordinator } from "../../src/engine/execution-coordinator";
import { CancellationSource } from "../../src/engine/cancellation";

test("a queued GPU job drains all workers and blocks newer inference without serializing existing readers", async () => {
  const coordinator = new ExecutionCoordinator();
  const a = await coordinator.acquire("shared"), b = await coordinator.acquire("shared");
  const order: string[] = [];
  const job = coordinator.acquire("exclusive").then((lease) => { order.push("job"); return lease; });
  const later = coordinator.acquire("shared").then((lease) => { order.push("later"); return lease; });
  a.dispose(); await Promise.resolve(); expect(order).toEqual([]);
  b.dispose(); const exclusive = await job; expect(order).toEqual(["job"]);
  exclusive.dispose(); exclusive.dispose();
  (await later).dispose(); expect(order).toEqual(["job", "later"]);
  coordinator.close();
});

test("cancelling a waiting writer resumes shared admission; overflow and close reject queued owners", async () => {
  const coordinator = new ExecutionCoordinator(2);
  const first = await coordinator.acquire("shared");
  const cancel = new CancellationSource();
  const job = coordinator.acquire("exclusive", cancel).catch((error) => error);
  const reader = coordinator.acquire("shared");
  await expect(coordinator.acquire("shared")).rejects.toThrow("full");
  cancel.cancel("requested"); expect((await job).message).toContain("cancelled");
  const joined = await reader;
  const pending = coordinator.acquire("exclusive");
  coordinator.close(); await expect(pending).rejects.toThrow("closed");
  first.dispose(); joined.dispose();
});
