import type { ExecutionGroup, SchedulingClock } from "../contracts/scheduling";
import { disposeResources } from "./resources";

/** Continuous scheduling policy. Each advance is a backend-defined safe unit;
 * this driver neither handles native state nor forces pending work to evaluate. */
export async function driveExecutionGroup(
  group: ExecutionGroup, clock: SchedulingClock, yieldAfterPreparation = false,
): Promise<void> {
  let execution: (() => void) | undefined;
  let residency: (() => void) | undefined;
  let lastYield = 0;
  let terminalError: unknown = new Error("scheduler closed");
  const release = () => {
    const releases = [execution, residency];
    execution = residency = undefined;
    disposeResources(releases.filter((fn): fn is () => void => !!fn).map((dispose) => ({ dispose })));
  };
  try {
    while (!group.closed) {
      group.pruneCancelled();
      const held = group.admissionHeld;
      if (!group.active && !group.preparing && (held || !group.queued)) {
        release();
        await group.waitForWork();
        continue;
      }
      residency ??= group.reserveResidency();
      if (!execution && group.acquireExecution) execution = await group.acquireExecution();
      if (group.closed) break;

      if (!group.preparing && !held && group.queued && group.active < group.maxActive)
        group.admitNext();
      while (group.preparing && group.canPrepareMore && !held && group.queued &&
          group.active + (group.preparingRows ?? 1) < group.maxActive && group.canBurst() &&
          (group.preparingTokens ?? 0) + (group.nextPreparationTokens ?? 0) <= (group.maxPreparationTokens ?? Infinity)) {
        if (!group.admitNext()) break;
      }
      const mixed = group.preparing && group.active ? group.mixedPreparation : undefined;
      if (mixed && group.advanceMixed) {
        // Reserve the method's running-token demand first; prompt work fills
        // the rest. A budget smaller than one token per row still progresses.
        const budget = Math.max(group.maxIterationTokens ?? Infinity,
          mixed.runningTokens + mixed.minimumPreparationTokens);
        await group.advanceMixed(budget);
        lastYield = clock.now();
        await clock.yield();
        continue;
      }
      if (group.preparing) {
        const activeBefore = group.active;
        await group.advancePreparation();
        // A bounded preparation may publish output before its state work ends.
        // Flush it before the next work unit; queued short admissions still
        // form a group across yields. Re-enter policy to observe new work,
        // cancellation, admission holds and shutdown.
        if (group.preparationPublishedOutput ||
            (yieldAfterPreparation && !activeBefore && !group.preparing && group.active === 1 && !group.queued)) {
          lastYield = clock.now();
          await clock.yield();
          continue;
        }
      }

      // Finish short admissions before decode; long preparation interleaves
      // with active work because the group still reports preparing=true.
      if (!group.preparing && !held && group.queued && group.active < group.maxActive && group.canBurst())
        continue;
      if (group.active) {
        try { await group.advance(); }
        catch (error) { group.failActive(error); }
      }
      // Preserve the serial responsiveness budget for the single active run.
      if (group.active === 1 && !group.queued && !group.preparing &&
          !group.admissionHeld && clock.now() - lastYield < 25) continue;
      lastYield = clock.now();
      await clock.yield();
    }
  } catch (error) {
    terminalError = error;
  } finally {
    disposeResources([{ dispose: () => group.failAll(terminalError) }, { dispose: release }]);
  }
}
