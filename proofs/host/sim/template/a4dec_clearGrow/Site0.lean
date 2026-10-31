import host.sim.template.a4dec_clearGrow.H0
import host.sim.template.a4dec_clearGrow.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `DEC_clearGrow`: `rb__start__g1` (`itemUint32`), the call state `DEC_clearGrow.s0`, the merged state `DEC_clearGrow.s1`,
the site template `DEC_clearGrow.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_clearGrow.s2`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl DEC_clearGrow.iso0 : DEC_clearGrow.st0.s0 = { DEC_clearGrow.s0 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_clearGrow.rs0 : List Frame := DEC_clearGrow.s0.stack
kernel_rfl DEC_clearGrow.n0_0 : DEC_clearGrow.S0.tab.length = 123
kernel_rfl DEC_clearGrow.tab0_0 : DEC_clearGrow.st0.S0.tab = DEC_clearGrow.S0.tab

/-- The fresh variables of the stage's results. -/
def DEC_clearGrow.ws0 : List Nat := []
kernel_rfl DEC_clearGrow.fresh0 : (DEC_clearGrow.S0.tab.all fun e => DEC_clearGrow.ws0.all fun v => e.noVar v) &&
    (DEC_clearGrow.S0.oracle.all fun q => DEC_clearGrow.ws0.all fun v => q.noVar v) = true
kernel_rfl DEC_clearGrow.mergeTab0 : DEC_clearGrow.S1.tab = DEC_clearGrow.S0.tab ++ Conv.resTab DEC_clearGrow.ws0
kernel_rfl DEC_clearGrow.mergeLen0 : DEC_clearGrow.st0.S2.tab.length - DEC_clearGrow.st0.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_clearGrow.merged0`, `merged_relB`).
kernel_rfl DEC_clearGrow.mheap0 : DEC_clearGrow.s1.heap = DEC_clearGrow.st0.s2.heap
kernel_rfl DEC_clearGrow.mnext0 : DEC_clearGrow.s1.next = DEC_clearGrow.st0.s2.next
kernel_rfl DEC_clearGrow.mctl0 : DEC_clearGrow.s1.ctl = DEC_clearGrow.st0.s2.ctl
kernel_rfl DEC_clearGrow.mstack0 : DEC_clearGrow.s1.stack = DEC_clearGrow.st0.s2.stack ++ DEC_clearGrow.s0.stack
kernel_rfl DEC_clearGrow.mjobs0 : DEC_clearGrow.s1.jobs = DEC_clearGrow.st0.s2.jobs
kernel_rfl DEC_clearGrow.mffi0 : DEC_clearGrow.s1.ffi = DEC_clearGrow.st0.s2.ffi
kernel_rfl DEC_clearGrow.mtrace0 : DEC_clearGrow.s1.trace = DEC_clearGrow.st0.s2.trace
kernel_rfl DEC_clearGrow.mstores0 : DEC_clearGrow.s1.stores = DEC_clearGrow.st0.s2.stores

end Host.Load.Run.Tpl
