import host.sim.template.a4dec_clearFill.H0
import host.sim.template.a4dec_clearFill.st2.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `DEC_clearFill`: `async__g2__g3` (`asyncEvalAll`), the call state `DEC_clearFill.s8`, the merged state `DEC_clearFill.s9`,
the site template `DEC_clearFill.st2` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_clearFill.s10`: the merge.
The footprint's facts are in `SiteF2`, the compaction's in `SiteC2`, `SiteK2`, `SiteNa2`, `SiteNb2`. -/

kernel_rfl DEC_clearFill.iso2 : DEC_clearFill.st2.s0 = { DEC_clearFill.s8 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_clearFill.rs2 : List Frame := DEC_clearFill.s8.stack
kernel_rfl DEC_clearFill.n0_2 : DEC_clearFill.S8.tab.length = 290
kernel_rfl DEC_clearFill.tab0_2 : DEC_clearFill.st2.S0.tab = DEC_clearFill.S8.tab

/-- The fresh variables of the stage's results. -/
def DEC_clearFill.ws2 : List Nat := []
kernel_rfl DEC_clearFill.fresh2 : (DEC_clearFill.S8.tab.all fun e => DEC_clearFill.ws2.all fun v => e.noVar v) &&
    (DEC_clearFill.S8.oracle.all fun q => DEC_clearFill.ws2.all fun v => q.noVar v) = true
kernel_rfl DEC_clearFill.mergeTab2 : DEC_clearFill.S9.tab = DEC_clearFill.S8.tab ++ Conv.resTab DEC_clearFill.ws2
kernel_rfl DEC_clearFill.mergeLen2 : DEC_clearFill.st2.S2.tab.length - DEC_clearFill.st2.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_clearFill.merged2`, `merged_relB`).
kernel_rfl DEC_clearFill.mheap2 : DEC_clearFill.s9.heap = DEC_clearFill.st2.s2.heap
kernel_rfl DEC_clearFill.mnext2 : DEC_clearFill.s9.next = DEC_clearFill.st2.s2.next
kernel_rfl DEC_clearFill.mctl2 : DEC_clearFill.s9.ctl = DEC_clearFill.st2.s2.ctl
kernel_rfl DEC_clearFill.mstack2 : DEC_clearFill.s9.stack = DEC_clearFill.st2.s2.stack ++ DEC_clearFill.s8.stack
kernel_rfl DEC_clearFill.mjobs2 : DEC_clearFill.s9.jobs = DEC_clearFill.st2.s2.jobs
kernel_rfl DEC_clearFill.mffi2 : DEC_clearFill.s9.ffi = DEC_clearFill.st2.s2.ffi
kernel_rfl DEC_clearFill.mtrace2 : DEC_clearFill.s9.trace = DEC_clearFill.st2.s2.trace
kernel_rfl DEC_clearFill.mstores2 : DEC_clearFill.s9.stores = DEC_clearFill.st2.s2.stores

end Host.Load.Run.Tpl
