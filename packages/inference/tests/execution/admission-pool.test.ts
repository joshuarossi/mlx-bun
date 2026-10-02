import { expect, test } from "bun:test";
import { AdmissionPool } from "../../src/execution/admission";
import { CancellationSource } from "../../src/execution/cancellation";

test("queue bounds, FIFO handoff and cancellation preserve the active reservation", async () => {
  const pool = new AdmissionPool(1, 2);
  const active = await pool.acquire();
  const cancel = new CancellationSource();
  const removed = pool.acquire(cancel).then(() => null, (error) => error);
  const next = pool.acquire();
  await expect(pool.acquire()).rejects.toThrow("queue is full");
  cancel.cancel("requested");
  expect((await removed).message).toContain("cancelled");
  expect(pool.active).toBe(1);
  expect(pool.queued).toBe(1);
  active.dispose(); active.dispose();
  const lease = await next;
  expect(pool.active).toBe(1);
  lease.dispose();
  expect(pool.active).toBe(0);
});

test("closing rejects waiters while the active owner releases at its safe boundary", async () => {
  const pool = new AdmissionPool(1);
  const active = await pool.acquire();
  const waiting = pool.acquire().then(() => null, (error) => error);
  pool.close();
  expect((await waiting).message).toContain("closed");
  expect(pool.active).toBe(1);
  active.dispose();
  expect(pool.active).toBe(0);
  await expect(pool.acquire()).rejects.toThrow("closed");
});
