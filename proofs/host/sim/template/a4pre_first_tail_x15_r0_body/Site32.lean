import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.st32.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 32 of chain `PRE_first_tail_x15_r0_body`: `plan__g32__g33` (`plan`), the call state `PRE_first_tail_x15_r0_body.s316`, the merged state `PRE_first_tail_x15_r0_body.s317`,
the site template `PRE_first_tail_x15_r0_body.st32` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s318`: the merge.
The footprint's facts are in `SiteF32`, the compaction's in `SiteC32`, `SiteK32`, `SiteNa32`, `SiteNb32`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso32 : PRE_first_tail_x15_r0_body.st32.s0 = { PRE_first_tail_x15_r0_body.s316 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs32 : List Frame := PRE_first_tail_x15_r0_body.s316.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_32 : PRE_first_tail_x15_r0_body.S316.tab.length = 1423
kernel_rfl PRE_first_tail_x15_r0_body.tab0_32 : PRE_first_tail_x15_r0_body.st32.S0.tab = PRE_first_tail_x15_r0_body.S316.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws32 : List Nat := [1551, 1552, 1553]
kernel_rfl PRE_first_tail_x15_r0_body.fresh32 : (PRE_first_tail_x15_r0_body.S316.tab.all fun e => PRE_first_tail_x15_r0_body.ws32.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S316.oracle.all fun q => PRE_first_tail_x15_r0_body.ws32.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab32 : PRE_first_tail_x15_r0_body.S317.tab = PRE_first_tail_x15_r0_body.S316.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws32
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen32 : PRE_first_tail_x15_r0_body.st32.S2.tab.length - PRE_first_tail_x15_r0_body.st32.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged32`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap32 : PRE_first_tail_x15_r0_body.s317.heap = PRE_first_tail_x15_r0_body.st32.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext32 : PRE_first_tail_x15_r0_body.s317.next = PRE_first_tail_x15_r0_body.st32.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl32 : PRE_first_tail_x15_r0_body.s317.ctl = PRE_first_tail_x15_r0_body.st32.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack32 : PRE_first_tail_x15_r0_body.s317.stack = PRE_first_tail_x15_r0_body.st32.s2.stack ++ PRE_first_tail_x15_r0_body.s316.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs32 : PRE_first_tail_x15_r0_body.s317.jobs = PRE_first_tail_x15_r0_body.st32.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi32 : PRE_first_tail_x15_r0_body.s317.ffi = PRE_first_tail_x15_r0_body.st32.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace32 : PRE_first_tail_x15_r0_body.s317.trace = PRE_first_tail_x15_r0_body.st32.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores32 : PRE_first_tail_x15_r0_body.s317.stores = PRE_first_tail_x15_r0_body.st32.s2.stores

end Host.Load.Run.Tpl
