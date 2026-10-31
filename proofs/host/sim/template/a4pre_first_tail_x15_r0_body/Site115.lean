import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.a4pre_first_tail_x15_r0_body.st115.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 115 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g115__g116` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1020`, the merged state `PRE_first_tail_x15_r0_body.s1021`,
the site template `PRE_first_tail_x15_r0_body.st115` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1022`: the merge.
The footprint's facts are in `SiteF115`, the compaction's in `SiteC115`, `SiteK115`, `SiteNa115`, `SiteNb115`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso115 : PRE_first_tail_x15_r0_body.st115.s0 = { PRE_first_tail_x15_r0_body.s1020 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs115 : List Frame := PRE_first_tail_x15_r0_body.s1020.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_115 : PRE_first_tail_x15_r0_body.S1020.tab.length = 4997
kernel_rfl PRE_first_tail_x15_r0_body.tab0_115 : PRE_first_tail_x15_r0_body.st115.S0.tab = PRE_first_tail_x15_r0_body.S1020.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws115 : List Nat := [2960, 2961]
kernel_rfl PRE_first_tail_x15_r0_body.fresh115 : (PRE_first_tail_x15_r0_body.S1020.tab.all fun e => PRE_first_tail_x15_r0_body.ws115.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1020.oracle.all fun q => PRE_first_tail_x15_r0_body.ws115.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab115 : PRE_first_tail_x15_r0_body.S1021.tab = PRE_first_tail_x15_r0_body.S1020.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws115
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen115 : PRE_first_tail_x15_r0_body.st115.S2.tab.length - PRE_first_tail_x15_r0_body.st115.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged115`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap115 : PRE_first_tail_x15_r0_body.s1021.heap = PRE_first_tail_x15_r0_body.st115.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext115 : PRE_first_tail_x15_r0_body.s1021.next = PRE_first_tail_x15_r0_body.st115.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl115 : PRE_first_tail_x15_r0_body.s1021.ctl = PRE_first_tail_x15_r0_body.st115.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack115 : PRE_first_tail_x15_r0_body.s1021.stack = PRE_first_tail_x15_r0_body.st115.s2.stack ++ PRE_first_tail_x15_r0_body.s1020.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs115 : PRE_first_tail_x15_r0_body.s1021.jobs = PRE_first_tail_x15_r0_body.st115.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi115 : PRE_first_tail_x15_r0_body.s1021.ffi = PRE_first_tail_x15_r0_body.st115.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace115 : PRE_first_tail_x15_r0_body.s1021.trace = PRE_first_tail_x15_r0_body.st115.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores115 : PRE_first_tail_x15_r0_body.s1021.stores = PRE_first_tail_x15_r0_body.st115.s2.stores

end Host.Load.Run.Tpl
