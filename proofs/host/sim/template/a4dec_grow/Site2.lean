import host.sim.template.a4dec_grow.H0
import host.sim.template.a4dec_grow.st2.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `DEC_grow`: `async__g2__g3` (`asyncEvalAll`), the call state `DEC_grow.s8`, the merged state `DEC_grow.s9`,
the site template `DEC_grow.st2` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_grow.s10`: the merge.
The footprint's facts are in `SiteF2`, the compaction's in `SiteC2`, `SiteK2`, `SiteNa2`, `SiteNb2`. -/

kernel_rfl DEC_grow.iso2 : DEC_grow.st2.s0 = { DEC_grow.s8 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_grow.rs2 : List Frame := DEC_grow.s8.stack
kernel_rfl DEC_grow.n0_2 : DEC_grow.S8.tab.length = 386
kernel_rfl DEC_grow.tab0_2 : DEC_grow.st2.S0.tab = DEC_grow.S8.tab

/-- The fresh variables of the stage's results. -/
def DEC_grow.ws2 : List Nat := []
kernel_rfl DEC_grow.fresh2 : (DEC_grow.S8.tab.all fun e => DEC_grow.ws2.all fun v => e.noVar v) &&
    (DEC_grow.S8.oracle.all fun q => DEC_grow.ws2.all fun v => q.noVar v) = true
kernel_rfl DEC_grow.mergeTab2 : DEC_grow.S9.tab = DEC_grow.S8.tab ++ Conv.resTab DEC_grow.ws2
kernel_rfl DEC_grow.mergeLen2 : DEC_grow.st2.S2.tab.length - DEC_grow.st2.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_grow.merged2`, `merged_relB`).
kernel_rfl DEC_grow.mheap2 : DEC_grow.s9.heap = DEC_grow.st2.s2.heap
kernel_rfl DEC_grow.mnext2 : DEC_grow.s9.next = DEC_grow.st2.s2.next
kernel_rfl DEC_grow.mctl2 : DEC_grow.s9.ctl = DEC_grow.st2.s2.ctl
kernel_rfl DEC_grow.mstack2 : DEC_grow.s9.stack = DEC_grow.st2.s2.stack ++ DEC_grow.s8.stack
kernel_rfl DEC_grow.mjobs2 : DEC_grow.s9.jobs = DEC_grow.st2.s2.jobs
kernel_rfl DEC_grow.mffi2 : DEC_grow.s9.ffi = DEC_grow.st2.s2.ffi
kernel_rfl DEC_grow.mtrace2 : DEC_grow.s9.trace = DEC_grow.st2.s2.trace
kernel_rfl DEC_grow.mstores2 : DEC_grow.s9.stores = DEC_grow.st2.s2.stores

end Host.Load.Run.Tpl
