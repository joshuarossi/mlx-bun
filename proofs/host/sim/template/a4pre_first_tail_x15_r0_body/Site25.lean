import host.sim.template.a4pre_first_tail_x15_r0_body.H8
import host.sim.template.a4pre_first_tail_x15_r0_body.st25.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 25 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g25__g26` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s254`, the merged state `PRE_first_tail_x15_r0_body.s255`,
the site template `PRE_first_tail_x15_r0_body.st25` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s256`: the merge.
The footprint's facts are in `SiteF25`, the compaction's in `SiteC25`, `SiteK25`, `SiteNa25`, `SiteNb25`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso25 : PRE_first_tail_x15_r0_body.st25.s0 = { PRE_first_tail_x15_r0_body.s254 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs25 : List Frame := PRE_first_tail_x15_r0_body.s254.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_25 : PRE_first_tail_x15_r0_body.S254.tab.length = 1148
kernel_rfl PRE_first_tail_x15_r0_body.tab0_25 : PRE_first_tail_x15_r0_body.st25.S0.tab = PRE_first_tail_x15_r0_body.S254.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws25 : List Nat := [1441, 1442]
kernel_rfl PRE_first_tail_x15_r0_body.fresh25 : (PRE_first_tail_x15_r0_body.S254.tab.all fun e => PRE_first_tail_x15_r0_body.ws25.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S254.oracle.all fun q => PRE_first_tail_x15_r0_body.ws25.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab25 : PRE_first_tail_x15_r0_body.S255.tab = PRE_first_tail_x15_r0_body.S254.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws25
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen25 : PRE_first_tail_x15_r0_body.st25.S2.tab.length - PRE_first_tail_x15_r0_body.st25.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged25`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap25 : PRE_first_tail_x15_r0_body.s255.heap = PRE_first_tail_x15_r0_body.st25.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext25 : PRE_first_tail_x15_r0_body.s255.next = PRE_first_tail_x15_r0_body.st25.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl25 : PRE_first_tail_x15_r0_body.s255.ctl = PRE_first_tail_x15_r0_body.st25.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack25 : PRE_first_tail_x15_r0_body.s255.stack = PRE_first_tail_x15_r0_body.st25.s2.stack ++ PRE_first_tail_x15_r0_body.s254.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs25 : PRE_first_tail_x15_r0_body.s255.jobs = PRE_first_tail_x15_r0_body.st25.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi25 : PRE_first_tail_x15_r0_body.s255.ffi = PRE_first_tail_x15_r0_body.st25.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace25 : PRE_first_tail_x15_r0_body.s255.trace = PRE_first_tail_x15_r0_body.st25.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores25 : PRE_first_tail_x15_r0_body.s255.stores = PRE_first_tail_x15_r0_body.st25.s2.stores

end Host.Load.Run.Tpl
