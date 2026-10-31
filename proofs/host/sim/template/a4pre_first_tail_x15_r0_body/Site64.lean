import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.st64.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 64 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g64__g65` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s573`, the merged state `PRE_first_tail_x15_r0_body.s574`,
the site template `PRE_first_tail_x15_r0_body.st64` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s575`: the merge.
The footprint's facts are in `SiteF64`, the compaction's in `SiteC64`, `SiteK64`, `SiteNa64`, `SiteNb64`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso64 : PRE_first_tail_x15_r0_body.st64.s0 = { PRE_first_tail_x15_r0_body.s573 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs64 : List Frame := PRE_first_tail_x15_r0_body.s573.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_64 : PRE_first_tail_x15_r0_body.S573.tab.length = 2816
kernel_rfl PRE_first_tail_x15_r0_body.tab0_64 : PRE_first_tail_x15_r0_body.st64.S0.tab = PRE_first_tail_x15_r0_body.S573.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws64 : List Nat := [2110, 2111]
kernel_rfl PRE_first_tail_x15_r0_body.fresh64 : (PRE_first_tail_x15_r0_body.S573.tab.all fun e => PRE_first_tail_x15_r0_body.ws64.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S573.oracle.all fun q => PRE_first_tail_x15_r0_body.ws64.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab64 : PRE_first_tail_x15_r0_body.S574.tab = PRE_first_tail_x15_r0_body.S573.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws64
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen64 : PRE_first_tail_x15_r0_body.st64.S2.tab.length - PRE_first_tail_x15_r0_body.st64.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged64`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap64 : PRE_first_tail_x15_r0_body.s574.heap = PRE_first_tail_x15_r0_body.st64.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext64 : PRE_first_tail_x15_r0_body.s574.next = PRE_first_tail_x15_r0_body.st64.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl64 : PRE_first_tail_x15_r0_body.s574.ctl = PRE_first_tail_x15_r0_body.st64.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack64 : PRE_first_tail_x15_r0_body.s574.stack = PRE_first_tail_x15_r0_body.st64.s2.stack ++ PRE_first_tail_x15_r0_body.s573.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs64 : PRE_first_tail_x15_r0_body.s574.jobs = PRE_first_tail_x15_r0_body.st64.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi64 : PRE_first_tail_x15_r0_body.s574.ffi = PRE_first_tail_x15_r0_body.st64.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace64 : PRE_first_tail_x15_r0_body.s574.trace = PRE_first_tail_x15_r0_body.st64.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores64 : PRE_first_tail_x15_r0_body.s574.stores = PRE_first_tail_x15_r0_body.st64.s2.stores

end Host.Load.Run.Tpl
