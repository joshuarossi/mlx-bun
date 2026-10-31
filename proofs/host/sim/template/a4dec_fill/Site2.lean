import host.sim.template.a4dec_fill.H0
import host.sim.template.a4dec_fill.st2.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `DEC_fill`: `async__g2__g3` (`asyncEvalAll`), the call state `DEC_fill.s8`, the merged state `DEC_fill.s9`,
the site template `DEC_fill.st2` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_fill.s10`: the merge.
The footprint's facts are in `SiteF2`, the compaction's in `SiteC2`, `SiteK2`, `SiteNa2`, `SiteNb2`. -/

kernel_rfl DEC_fill.iso2 : DEC_fill.st2.s0 = { DEC_fill.s8 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_fill.rs2 : List Frame := DEC_fill.s8.stack
kernel_rfl DEC_fill.n0_2 : DEC_fill.S8.tab.length = 290
kernel_rfl DEC_fill.tab0_2 : DEC_fill.st2.S0.tab = DEC_fill.S8.tab

/-- The fresh variables of the stage's results. -/
def DEC_fill.ws2 : List Nat := []
kernel_rfl DEC_fill.fresh2 : (DEC_fill.S8.tab.all fun e => DEC_fill.ws2.all fun v => e.noVar v) &&
    (DEC_fill.S8.oracle.all fun q => DEC_fill.ws2.all fun v => q.noVar v) = true
kernel_rfl DEC_fill.mergeTab2 : DEC_fill.S9.tab = DEC_fill.S8.tab ++ Conv.resTab DEC_fill.ws2
kernel_rfl DEC_fill.mergeLen2 : DEC_fill.st2.S2.tab.length - DEC_fill.st2.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_fill.merged2`, `merged_relB`).
kernel_rfl DEC_fill.mheap2 : DEC_fill.s9.heap = DEC_fill.st2.s2.heap
kernel_rfl DEC_fill.mnext2 : DEC_fill.s9.next = DEC_fill.st2.s2.next
kernel_rfl DEC_fill.mctl2 : DEC_fill.s9.ctl = DEC_fill.st2.s2.ctl
kernel_rfl DEC_fill.mstack2 : DEC_fill.s9.stack = DEC_fill.st2.s2.stack ++ DEC_fill.s8.stack
kernel_rfl DEC_fill.mjobs2 : DEC_fill.s9.jobs = DEC_fill.st2.s2.jobs
kernel_rfl DEC_fill.mffi2 : DEC_fill.s9.ffi = DEC_fill.st2.s2.ffi
kernel_rfl DEC_fill.mtrace2 : DEC_fill.s9.trace = DEC_fill.st2.s2.trace
kernel_rfl DEC_fill.mstores2 : DEC_fill.s9.stores = DEC_fill.st2.s2.stores

end Host.Load.Run.Tpl
