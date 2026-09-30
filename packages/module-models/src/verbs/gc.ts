import type { CliInvocation, ModelCatalog } from "@mlx-bun/app-core";
import { executeGc, planGc } from "@mlx-bun/hub/registry";
import { flag, gb, printer } from "./shared";

/** `gc`: what superseded snapshots and dead blobs would give back; deletes only with `--yes`. */
export async function runGc(invocation: CliInvocation, catalog: Pick<ModelCatalog, "rescan">): Promise<number> {
  const print = printer(invocation), { terminal } = invocation, { style } = terminal;
  const force = flag(invocation, "force");
  const plans = planGc(undefined, { force }).filter(plan => plan.pruneSnapshots.length || plan.skippedSnapshots.length || plan.deadBlobs.length);
  terminal.heading("gc — superseded snapshots + dead blobs");
  print();
  if (plans.length === 0) { print("  nothing to reclaim — every snapshot is referenced by refs/*"); return 0; }
  terminal.table([
    { header: "repo", paint: cell => style.bold(cell) },
    { header: "keep", align: "right" },
    { header: "prune", align: "right" },
    { header: "skip", align: "right" },
    { header: "reclaims", align: "right" },
  ], plans.map(plan => [plan.repoId, String(plan.keepSnapshots.length), String(plan.pruneSnapshots.length), String(plan.skippedSnapshots.length), gb(plan.reclaimBytes)]));
  print();
  for (const plan of plans) {
    for (const skipped of plan.skippedSnapshots) {
      const revision = (skipped.path.split("/snapshots/")[1] ?? skipped.path).slice(0, 12);
      print(style.accent(`  WARNING ${plan.repoId}@${revision}: superseded snapshot has files the canonical revision lacks — skipped.`));
      print(style.dim(`    only copy of: ${skipped.extraFiles.join(", ")}`));
      print(style.dim("    deleting it loses those files — rerun with --force if that's intended."));
    }
  }
  const totalReclaim = plans.reduce((sum, plan) => sum + plan.reclaimBytes, 0);
  const totalSnapshots = plans.reduce((sum, plan) => sum + plan.pruneSnapshots.length, 0);
  const totalBlobs = plans.reduce((sum, plan) => sum + plan.deadBlobs.length, 0);
  print(`  total: ${totalSnapshots} snapshot(s), ${totalBlobs} blob(s), ${style.bold(gb(totalReclaim))}`);
  if (flag(invocation, "dry-run") || !flag(invocation, "yes")) {
    print(style.dim("  nothing deleted — rerun with --yes to delete (destructive)."));
    return 0;
  }
  const result = executeGc(plans);
  print(`  deleted ${result.snapshots} snapshot(s) + ${result.blobs} blob(s) — reclaimed ${style.bold(gb(result.reclaimedBytes))}`);
  await catalog.rescan(); // reap deleted snapshots from the index
  return 0;
}
