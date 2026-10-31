import host.sim.template.a4pre_first_tail_x15_r0_body.H37
import host.sim.template.a4pre_first_tail_x15_r0_body.st125.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 125 of chain `PRE_first_tail_x15_r0_body`: `plan__g125__g126` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1207`, the merged state `PRE_first_tail_x15_r0_body.s1208`,
the site template `PRE_first_tail_x15_r0_body.st125` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1209`: the merge.
The footprint's facts are in `SiteF125`, the compaction's in `SiteC125`, `SiteK125`, `SiteNa125`, `SiteNb125`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso125 : PRE_first_tail_x15_r0_body.st125.s0 = { PRE_first_tail_x15_r0_body.s1207 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs125 : List Frame := PRE_first_tail_x15_r0_body.s1207.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_125 : PRE_first_tail_x15_r0_body.S1207.tab.length = 5398
kernel_rfl PRE_first_tail_x15_r0_body.tab0_125 : PRE_first_tail_x15_r0_body.st125.S0.tab = PRE_first_tail_x15_r0_body.S1207.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws125 : List Nat := [3101, 3102, 3103]
kernel_rfl PRE_first_tail_x15_r0_body.fresh125 : (PRE_first_tail_x15_r0_body.S1207.tab.all fun e => PRE_first_tail_x15_r0_body.ws125.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1207.oracle.all fun q => PRE_first_tail_x15_r0_body.ws125.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab125 : PRE_first_tail_x15_r0_body.S1208.tab = PRE_first_tail_x15_r0_body.S1207.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws125
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen125 : PRE_first_tail_x15_r0_body.st125.S2.tab.length - PRE_first_tail_x15_r0_body.st125.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged125`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap125 : PRE_first_tail_x15_r0_body.s1208.heap = PRE_first_tail_x15_r0_body.st125.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext125 : PRE_first_tail_x15_r0_body.s1208.next = PRE_first_tail_x15_r0_body.st125.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl125 : PRE_first_tail_x15_r0_body.s1208.ctl = PRE_first_tail_x15_r0_body.st125.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack125 : PRE_first_tail_x15_r0_body.s1208.stack = PRE_first_tail_x15_r0_body.st125.s2.stack ++ PRE_first_tail_x15_r0_body.s1207.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs125 : PRE_first_tail_x15_r0_body.s1208.jobs = PRE_first_tail_x15_r0_body.st125.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi125 : PRE_first_tail_x15_r0_body.s1208.ffi = PRE_first_tail_x15_r0_body.st125.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace125 : PRE_first_tail_x15_r0_body.s1208.trace = PRE_first_tail_x15_r0_body.st125.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores125 : PRE_first_tail_x15_r0_body.s1208.stores = PRE_first_tail_x15_r0_body.st125.s2.stores

end Host.Load.Run.Tpl
