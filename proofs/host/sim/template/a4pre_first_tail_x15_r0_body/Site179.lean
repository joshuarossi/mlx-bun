import host.sim.template.a4pre_first_tail_x15_r0_body.H53
import host.sim.template.a4pre_first_tail_x15_r0_body.st179.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 179 of chain `PRE_first_tail_x15_r0_body`: `plan__g179__g180` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1724`, the merged state `PRE_first_tail_x15_r0_body.s1725`,
the site template `PRE_first_tail_x15_r0_body.st179` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1726`: the merge.
The footprint's facts are in `SiteF179`, the compaction's in `SiteC179`, `SiteK179`, `SiteNa179`, `SiteNb179`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso179 : PRE_first_tail_x15_r0_body.st179.s0 = { PRE_first_tail_x15_r0_body.s1724 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs179 : List Frame := PRE_first_tail_x15_r0_body.s1724.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_179 : PRE_first_tail_x15_r0_body.S1724.tab.length = 7705
kernel_rfl PRE_first_tail_x15_r0_body.tab0_179 : PRE_first_tail_x15_r0_body.st179.S0.tab = PRE_first_tail_x15_r0_body.S1724.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws179 : List Nat := [4018, 4019, 4020, 4021, 4022, 4023, 4024, 4025, 4026]
kernel_rfl PRE_first_tail_x15_r0_body.fresh179 : (PRE_first_tail_x15_r0_body.S1724.tab.all fun e => PRE_first_tail_x15_r0_body.ws179.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1724.oracle.all fun q => PRE_first_tail_x15_r0_body.ws179.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab179 : PRE_first_tail_x15_r0_body.S1725.tab = PRE_first_tail_x15_r0_body.S1724.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws179
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen179 : PRE_first_tail_x15_r0_body.st179.S2.tab.length - PRE_first_tail_x15_r0_body.st179.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged179`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap179 : PRE_first_tail_x15_r0_body.s1725.heap = PRE_first_tail_x15_r0_body.st179.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext179 : PRE_first_tail_x15_r0_body.s1725.next = PRE_first_tail_x15_r0_body.st179.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl179 : PRE_first_tail_x15_r0_body.s1725.ctl = PRE_first_tail_x15_r0_body.st179.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack179 : PRE_first_tail_x15_r0_body.s1725.stack = PRE_first_tail_x15_r0_body.st179.s2.stack ++ PRE_first_tail_x15_r0_body.s1724.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs179 : PRE_first_tail_x15_r0_body.s1725.jobs = PRE_first_tail_x15_r0_body.st179.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi179 : PRE_first_tail_x15_r0_body.s1725.ffi = PRE_first_tail_x15_r0_body.st179.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace179 : PRE_first_tail_x15_r0_body.s1725.trace = PRE_first_tail_x15_r0_body.st179.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores179 : PRE_first_tail_x15_r0_body.s1725.stores = PRE_first_tail_x15_r0_body.st179.s2.stores

end Host.Load.Run.Tpl
