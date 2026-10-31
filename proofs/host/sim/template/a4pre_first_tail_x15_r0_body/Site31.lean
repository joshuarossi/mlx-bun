import host.sim.template.a4pre_first_tail_x15_r0_body.H8
import host.sim.template.a4pre_first_tail_x15_r0_body.st31.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 31 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g31__g32` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s285`, the merged state `PRE_first_tail_x15_r0_body.s286`,
the site template `PRE_first_tail_x15_r0_body.st31` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s287`: the merge.
The footprint's facts are in `SiteF31`, the compaction's in `SiteC31`, `SiteK31`, `SiteNa31`, `SiteNb31`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso31 : PRE_first_tail_x15_r0_body.st31.s0 = { PRE_first_tail_x15_r0_body.s285 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs31 : List Frame := PRE_first_tail_x15_r0_body.s285.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_31 : PRE_first_tail_x15_r0_body.S285.tab.length = 1406
kernel_rfl PRE_first_tail_x15_r0_body.tab0_31 : PRE_first_tail_x15_r0_body.st31.S0.tab = PRE_first_tail_x15_r0_body.S285.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws31 : List Nat := [1549, 1550]
kernel_rfl PRE_first_tail_x15_r0_body.fresh31 : (PRE_first_tail_x15_r0_body.S285.tab.all fun e => PRE_first_tail_x15_r0_body.ws31.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S285.oracle.all fun q => PRE_first_tail_x15_r0_body.ws31.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab31 : PRE_first_tail_x15_r0_body.S286.tab = PRE_first_tail_x15_r0_body.S285.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws31
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen31 : PRE_first_tail_x15_r0_body.st31.S2.tab.length - PRE_first_tail_x15_r0_body.st31.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged31`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap31 : PRE_first_tail_x15_r0_body.s286.heap = PRE_first_tail_x15_r0_body.st31.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext31 : PRE_first_tail_x15_r0_body.s286.next = PRE_first_tail_x15_r0_body.st31.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl31 : PRE_first_tail_x15_r0_body.s286.ctl = PRE_first_tail_x15_r0_body.st31.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack31 : PRE_first_tail_x15_r0_body.s286.stack = PRE_first_tail_x15_r0_body.st31.s2.stack ++ PRE_first_tail_x15_r0_body.s285.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs31 : PRE_first_tail_x15_r0_body.s286.jobs = PRE_first_tail_x15_r0_body.st31.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi31 : PRE_first_tail_x15_r0_body.s286.ffi = PRE_first_tail_x15_r0_body.st31.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace31 : PRE_first_tail_x15_r0_body.s286.trace = PRE_first_tail_x15_r0_body.st31.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores31 : PRE_first_tail_x15_r0_body.s286.stores = PRE_first_tail_x15_r0_body.st31.s2.stores

end Host.Load.Run.Tpl
