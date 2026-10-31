import host.sim.template.a4dec_clearGrow.H0
import host.sim.template.a4dec_clearGrow.st2.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `DEC_clearGrow`: `async__g2__g3` (`asyncEvalAll`), the call state `DEC_clearGrow.s8`, the merged state `DEC_clearGrow.s9`,
the site template `DEC_clearGrow.st2` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_clearGrow.s10`: the merge.
The footprint's facts are in `SiteF2`, the compaction's in `SiteC2`, `SiteK2`, `SiteNa2`, `SiteNb2`. -/

kernel_rfl DEC_clearGrow.iso2 : DEC_clearGrow.st2.s0 = { DEC_clearGrow.s8 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_clearGrow.rs2 : List Frame := DEC_clearGrow.s8.stack
kernel_rfl DEC_clearGrow.n0_2 : DEC_clearGrow.S8.tab.length = 386
kernel_rfl DEC_clearGrow.tab0_2 : DEC_clearGrow.st2.S0.tab = DEC_clearGrow.S8.tab

/-- The fresh variables of the stage's results. -/
def DEC_clearGrow.ws2 : List Nat := []
kernel_rfl DEC_clearGrow.fresh2 : (DEC_clearGrow.S8.tab.all fun e => DEC_clearGrow.ws2.all fun v => e.noVar v) &&
    (DEC_clearGrow.S8.oracle.all fun q => DEC_clearGrow.ws2.all fun v => q.noVar v) = true
kernel_rfl DEC_clearGrow.mergeTab2 : DEC_clearGrow.S9.tab = DEC_clearGrow.S8.tab ++ Conv.resTab DEC_clearGrow.ws2
kernel_rfl DEC_clearGrow.mergeLen2 : DEC_clearGrow.st2.S2.tab.length - DEC_clearGrow.st2.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_clearGrow.merged2`, `merged_relB`).
kernel_rfl DEC_clearGrow.mheap2 : DEC_clearGrow.s9.heap = DEC_clearGrow.st2.s2.heap
kernel_rfl DEC_clearGrow.mnext2 : DEC_clearGrow.s9.next = DEC_clearGrow.st2.s2.next
kernel_rfl DEC_clearGrow.mctl2 : DEC_clearGrow.s9.ctl = DEC_clearGrow.st2.s2.ctl
kernel_rfl DEC_clearGrow.mstack2 : DEC_clearGrow.s9.stack = DEC_clearGrow.st2.s2.stack ++ DEC_clearGrow.s8.stack
kernel_rfl DEC_clearGrow.mjobs2 : DEC_clearGrow.s9.jobs = DEC_clearGrow.st2.s2.jobs
kernel_rfl DEC_clearGrow.mffi2 : DEC_clearGrow.s9.ffi = DEC_clearGrow.st2.s2.ffi
kernel_rfl DEC_clearGrow.mtrace2 : DEC_clearGrow.s9.trace = DEC_clearGrow.st2.s2.trace
kernel_rfl DEC_clearGrow.mstores2 : DEC_clearGrow.s9.stores = DEC_clearGrow.st2.s2.stores

end Host.Load.Run.Tpl
