import host.sim.template.a4pre_first_tail_x15_r0_body.H44
import host.sim.template.a4pre_first_tail_x15_r0_body.st148.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 148 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g148__g149` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1433`, the merged state `PRE_first_tail_x15_r0_body.s1434`,
the site template `PRE_first_tail_x15_r0_body.st148` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1435`: the merge.
The footprint's facts are in `SiteF148`, the compaction's in `SiteC148`, `SiteK148`, `SiteNa148`, `SiteNb148`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso148 : PRE_first_tail_x15_r0_body.st148.s0 = { PRE_first_tail_x15_r0_body.s1433 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs148 : List Frame := PRE_first_tail_x15_r0_body.s1433.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_148 : PRE_first_tail_x15_r0_body.S1433.tab.length = 6407
kernel_rfl PRE_first_tail_x15_r0_body.tab0_148 : PRE_first_tail_x15_r0_body.st148.S0.tab = PRE_first_tail_x15_r0_body.S1433.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws148 : List Nat := [3509, 3510]
kernel_rfl PRE_first_tail_x15_r0_body.fresh148 : (PRE_first_tail_x15_r0_body.S1433.tab.all fun e => PRE_first_tail_x15_r0_body.ws148.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1433.oracle.all fun q => PRE_first_tail_x15_r0_body.ws148.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab148 : PRE_first_tail_x15_r0_body.S1434.tab = PRE_first_tail_x15_r0_body.S1433.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws148
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen148 : PRE_first_tail_x15_r0_body.st148.S2.tab.length - PRE_first_tail_x15_r0_body.st148.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged148`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap148 : PRE_first_tail_x15_r0_body.s1434.heap = PRE_first_tail_x15_r0_body.st148.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext148 : PRE_first_tail_x15_r0_body.s1434.next = PRE_first_tail_x15_r0_body.st148.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl148 : PRE_first_tail_x15_r0_body.s1434.ctl = PRE_first_tail_x15_r0_body.st148.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack148 : PRE_first_tail_x15_r0_body.s1434.stack = PRE_first_tail_x15_r0_body.st148.s2.stack ++ PRE_first_tail_x15_r0_body.s1433.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs148 : PRE_first_tail_x15_r0_body.s1434.jobs = PRE_first_tail_x15_r0_body.st148.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi148 : PRE_first_tail_x15_r0_body.s1434.ffi = PRE_first_tail_x15_r0_body.st148.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace148 : PRE_first_tail_x15_r0_body.s1434.trace = PRE_first_tail_x15_r0_body.st148.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores148 : PRE_first_tail_x15_r0_body.s1434.stores = PRE_first_tail_x15_r0_body.st148.s2.stores

end Host.Load.Run.Tpl
