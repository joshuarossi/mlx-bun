import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.st31.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 31 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g31__g32` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s312`, the merged state `PRE_first_tail_x15_r0_body.s313`,
the site template `PRE_first_tail_x15_r0_body.st31` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s314`: the merge.
The footprint's facts are in `SiteF31`, the compaction's in `SiteC31`, `SiteK31`, `SiteNa31`, `SiteNb31`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso31 : PRE_first_tail_x15_r0_body.st31.s0 = { PRE_first_tail_x15_r0_body.s312 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs31 : List Frame := PRE_first_tail_x15_r0_body.s312.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_31 : PRE_first_tail_x15_r0_body.S312.tab.length = 1406
kernel_rfl PRE_first_tail_x15_r0_body.tab0_31 : PRE_first_tail_x15_r0_body.st31.S0.tab = PRE_first_tail_x15_r0_body.S312.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws31 : List Nat := [1549, 1550]
kernel_rfl PRE_first_tail_x15_r0_body.fresh31 : (PRE_first_tail_x15_r0_body.S312.tab.all fun e => PRE_first_tail_x15_r0_body.ws31.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S312.oracle.all fun q => PRE_first_tail_x15_r0_body.ws31.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab31 : PRE_first_tail_x15_r0_body.S313.tab = PRE_first_tail_x15_r0_body.S312.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws31
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen31 : PRE_first_tail_x15_r0_body.st31.S2.tab.length - PRE_first_tail_x15_r0_body.st31.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged31`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap31 : PRE_first_tail_x15_r0_body.s313.heap = PRE_first_tail_x15_r0_body.st31.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext31 : PRE_first_tail_x15_r0_body.s313.next = PRE_first_tail_x15_r0_body.st31.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl31 : PRE_first_tail_x15_r0_body.s313.ctl = PRE_first_tail_x15_r0_body.st31.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack31 : PRE_first_tail_x15_r0_body.s313.stack = PRE_first_tail_x15_r0_body.st31.s2.stack ++ PRE_first_tail_x15_r0_body.s312.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs31 : PRE_first_tail_x15_r0_body.s313.jobs = PRE_first_tail_x15_r0_body.st31.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi31 : PRE_first_tail_x15_r0_body.s313.ffi = PRE_first_tail_x15_r0_body.st31.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace31 : PRE_first_tail_x15_r0_body.s313.trace = PRE_first_tail_x15_r0_body.st31.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores31 : PRE_first_tail_x15_r0_body.s313.stores = PRE_first_tail_x15_r0_body.st31.s2.stores

end Host.Load.Run.Tpl
