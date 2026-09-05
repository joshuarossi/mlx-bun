import type { ExecutionGroup, SchedulingClock } from "../contracts/scheduling";
import { disposeResources } from "./resources";

/** Continuous scheduling policy. Each advance is a backend-defined safe unit;
 * this driver neither handles native state nor forces pending work to evaluate. */
export async function driveExecutionGroup(group: ExecutionGroup, clock: SchedulingClock): Promise<void> {
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
      if (group.preparing) await group.advancePreparation();

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
