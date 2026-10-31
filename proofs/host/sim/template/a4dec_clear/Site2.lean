import host.sim.template.a4dec_clear.H0
import host.sim.template.a4dec_clear.st2.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `DEC_clear`: `async__g2__g3` (`asyncEvalAll`), the call state `DEC_clear.s8`, the merged state `DEC_clear.s9`,
the site template `DEC_clear.st2` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_clear.s10`: the merge.
The footprint's facts are in `SiteF2`, the compaction's in `SiteC2`, `SiteK2`, `SiteNa2`, `SiteNb2`. -/

kernel_rfl DEC_clear.iso2 : DEC_clear.st2.s0 = { DEC_clear.s8 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_clear.rs2 : List Frame := DEC_clear.s8.stack
kernel_rfl DEC_clear.n0_2 : DEC_clear.S8.tab.length = 354
kernel_rfl DEC_clear.tab0_2 : DEC_clear.st2.S0.tab = DEC_clear.S8.tab

/-- The fresh variables of the stage's results. -/
def DEC_clear.ws2 : List Nat := []
kernel_rfl DEC_clear.fresh2 : (DEC_clear.S8.tab.all fun e => DEC_clear.ws2.all fun v => e.noVar v) &&
    (DEC_clear.S8.oracle.all fun q => DEC_clear.ws2.all fun v => q.noVar v) = true
kernel_rfl DEC_clear.mergeTab2 : DEC_clear.S9.tab = DEC_clear.S8.tab ++ Conv.resTab DEC_clear.ws2
kernel_rfl DEC_clear.mergeLen2 : DEC_clear.st2.S2.tab.length - DEC_clear.st2.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_clear.merged2`, `merged_relB`).
kernel_rfl DEC_clear.mheap2 : DEC_clear.s9.heap = DEC_clear.st2.s2.heap
kernel_rfl DEC_clear.mnext2 : DEC_clear.s9.next = DEC_clear.st2.s2.next
kernel_rfl DEC_clear.mctl2 : DEC_clear.s9.ctl = DEC_clear.st2.s2.ctl
kernel_rfl DEC_clear.mstack2 : DEC_clear.s9.stack = DEC_clear.st2.s2.stack ++ DEC_clear.s8.stack
kernel_rfl DEC_clear.mjobs2 : DEC_clear.s9.jobs = DEC_clear.st2.s2.jobs
kernel_rfl DEC_clear.mffi2 : DEC_clear.s9.ffi = DEC_clear.st2.s2.ffi
kernel_rfl DEC_clear.mtrace2 : DEC_clear.s9.trace = DEC_clear.st2.s2.trace
kernel_rfl DEC_clear.mstores2 : DEC_clear.s9.stores = DEC_clear.st2.s2.stores

end Host.Load.Run.Tpl
