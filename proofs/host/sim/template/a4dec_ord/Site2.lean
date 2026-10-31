import host.sim.template.a4dec_ord.H0
import host.sim.template.a4dec_ord.st2.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `DEC_ord`: `async__g2__g3` (`asyncEvalAll`), the call state `DEC_ord.s8`, the merged state `DEC_ord.s9`,
the site template `DEC_ord.st2` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_ord.s10`: the merge.
The footprint's facts are in `SiteF2`, the compaction's in `SiteC2`, `SiteK2`, `SiteNa2`, `SiteNb2`. -/

kernel_rfl DEC_ord.iso2 : DEC_ord.st2.s0 = { DEC_ord.s8 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_ord.rs2 : List Frame := DEC_ord.s8.stack
kernel_rfl DEC_ord.n0_2 : DEC_ord.S8.tab.length = 354
kernel_rfl DEC_ord.tab0_2 : DEC_ord.st2.S0.tab = DEC_ord.S8.tab

/-- The fresh variables of the stage's results. -/
def DEC_ord.ws2 : List Nat := []
kernel_rfl DEC_ord.fresh2 : (DEC_ord.S8.tab.all fun e => DEC_ord.ws2.all fun v => e.noVar v) &&
    (DEC_ord.S8.oracle.all fun q => DEC_ord.ws2.all fun v => q.noVar v) = true
kernel_rfl DEC_ord.mergeTab2 : DEC_ord.S9.tab = DEC_ord.S8.tab ++ Conv.resTab DEC_ord.ws2
kernel_rfl DEC_ord.mergeLen2 : DEC_ord.st2.S2.tab.length - DEC_ord.st2.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_ord.merged2`, `merged_relB`).
kernel_rfl DEC_ord.mheap2 : DEC_ord.s9.heap = DEC_ord.st2.s2.heap
kernel_rfl DEC_ord.mnext2 : DEC_ord.s9.next = DEC_ord.st2.s2.next
kernel_rfl DEC_ord.mctl2 : DEC_ord.s9.ctl = DEC_ord.st2.s2.ctl
kernel_rfl DEC_ord.mstack2 : DEC_ord.s9.stack = DEC_ord.st2.s2.stack ++ DEC_ord.s8.stack
kernel_rfl DEC_ord.mjobs2 : DEC_ord.s9.jobs = DEC_ord.st2.s2.jobs
kernel_rfl DEC_ord.mffi2 : DEC_ord.s9.ffi = DEC_ord.st2.s2.ffi
kernel_rfl DEC_ord.mtrace2 : DEC_ord.s9.trace = DEC_ord.st2.s2.trace
kernel_rfl DEC_ord.mstores2 : DEC_ord.s9.stores = DEC_ord.st2.s2.stores

end Host.Load.Run.Tpl
