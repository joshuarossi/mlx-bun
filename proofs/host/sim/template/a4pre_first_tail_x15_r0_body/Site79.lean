import host.sim.template.a4pre_first_tail_x15_r0_body.H22
import host.sim.template.a4pre_first_tail_x15_r0_body.st79.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 79 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g79__g80` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s705`, the merged state `PRE_first_tail_x15_r0_body.s706`,
the site template `PRE_first_tail_x15_r0_body.st79` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s707`: the merge.
The footprint's facts are in `SiteF79`, the compaction's in `SiteC79`, `SiteK79`, `SiteNa79`, `SiteNb79`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso79 : PRE_first_tail_x15_r0_body.st79.s0 = { PRE_first_tail_x15_r0_body.s705 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs79 : List Frame := PRE_first_tail_x15_r0_body.s705.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_79 : PRE_first_tail_x15_r0_body.S705.tab.length = 3458
kernel_rfl PRE_first_tail_x15_r0_body.tab0_79 : PRE_first_tail_x15_r0_body.st79.S0.tab = PRE_first_tail_x15_r0_body.S705.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws79 : List Nat := [2357, 2358]
kernel_rfl PRE_first_tail_x15_r0_body.fresh79 : (PRE_first_tail_x15_r0_body.S705.tab.all fun e => PRE_first_tail_x15_r0_body.ws79.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S705.oracle.all fun q => PRE_first_tail_x15_r0_body.ws79.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab79 : PRE_first_tail_x15_r0_body.S706.tab = PRE_first_tail_x15_r0_body.S705.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws79
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen79 : PRE_first_tail_x15_r0_body.st79.S2.tab.length - PRE_first_tail_x15_r0_body.st79.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged79`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap79 : PRE_first_tail_x15_r0_body.s706.heap = PRE_first_tail_x15_r0_body.st79.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext79 : PRE_first_tail_x15_r0_body.s706.next = PRE_first_tail_x15_r0_body.st79.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl79 : PRE_first_tail_x15_r0_body.s706.ctl = PRE_first_tail_x15_r0_body.st79.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack79 : PRE_first_tail_x15_r0_body.s706.stack = PRE_first_tail_x15_r0_body.st79.s2.stack ++ PRE_first_tail_x15_r0_body.s705.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs79 : PRE_first_tail_x15_r0_body.s706.jobs = PRE_first_tail_x15_r0_body.st79.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi79 : PRE_first_tail_x15_r0_body.s706.ffi = PRE_first_tail_x15_r0_body.st79.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace79 : PRE_first_tail_x15_r0_body.s706.trace = PRE_first_tail_x15_r0_body.st79.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores79 : PRE_first_tail_x15_r0_body.s706.stores = PRE_first_tail_x15_r0_body.st79.s2.stores

end Host.Load.Run.Tpl
