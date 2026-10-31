import host.sim.template.a4pre_first_tail_x15_r0_body.H43
import host.sim.template.a4pre_first_tail_x15_r0_body.st142.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 142 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g142__g143` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1375`, the merged state `PRE_first_tail_x15_r0_body.s1376`,
the site template `PRE_first_tail_x15_r0_body.st142` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1377`: the merge.
The footprint's facts are in `SiteF142`, the compaction's in `SiteC142`, `SiteK142`, `SiteNa142`, `SiteNb142`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso142 : PRE_first_tail_x15_r0_body.st142.s0 = { PRE_first_tail_x15_r0_body.s1375 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs142 : List Frame := PRE_first_tail_x15_r0_body.s1375.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_142 : PRE_first_tail_x15_r0_body.S1375.tab.length = 6149
kernel_rfl PRE_first_tail_x15_r0_body.tab0_142 : PRE_first_tail_x15_r0_body.st142.S0.tab = PRE_first_tail_x15_r0_body.S1375.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws142 : List Nat := [3389, 3390]
kernel_rfl PRE_first_tail_x15_r0_body.fresh142 : (PRE_first_tail_x15_r0_body.S1375.tab.all fun e => PRE_first_tail_x15_r0_body.ws142.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1375.oracle.all fun q => PRE_first_tail_x15_r0_body.ws142.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab142 : PRE_first_tail_x15_r0_body.S1376.tab = PRE_first_tail_x15_r0_body.S1375.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws142
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen142 : PRE_first_tail_x15_r0_body.st142.S2.tab.length - PRE_first_tail_x15_r0_body.st142.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged142`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap142 : PRE_first_tail_x15_r0_body.s1376.heap = PRE_first_tail_x15_r0_body.st142.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext142 : PRE_first_tail_x15_r0_body.s1376.next = PRE_first_tail_x15_r0_body.st142.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl142 : PRE_first_tail_x15_r0_body.s1376.ctl = PRE_first_tail_x15_r0_body.st142.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack142 : PRE_first_tail_x15_r0_body.s1376.stack = PRE_first_tail_x15_r0_body.st142.s2.stack ++ PRE_first_tail_x15_r0_body.s1375.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs142 : PRE_first_tail_x15_r0_body.s1376.jobs = PRE_first_tail_x15_r0_body.st142.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi142 : PRE_first_tail_x15_r0_body.s1376.ffi = PRE_first_tail_x15_r0_body.st142.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace142 : PRE_first_tail_x15_r0_body.s1376.trace = PRE_first_tail_x15_r0_body.st142.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores142 : PRE_first_tail_x15_r0_body.s1376.stores = PRE_first_tail_x15_r0_body.st142.s2.stores

end Host.Load.Run.Tpl
