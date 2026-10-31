import host.sim.template.a4dec_clearFill.H0
import host.sim.template.a4dec_clearFill.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `DEC_clearFill`: `rb__start__g1` (`itemUint32`), the call state `DEC_clearFill.s0`, the merged state `DEC_clearFill.s1`,
the site template `DEC_clearFill.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_clearFill.s2`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl DEC_clearFill.iso0 : DEC_clearFill.st0.s0 = { DEC_clearFill.s0 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_clearFill.rs0 : List Frame := DEC_clearFill.s0.stack
kernel_rfl DEC_clearFill.n0_0 : DEC_clearFill.S0.tab.length = 123
kernel_rfl DEC_clearFill.tab0_0 : DEC_clearFill.st0.S0.tab = DEC_clearFill.S0.tab

/-- The fresh variables of the stage's results. -/
def DEC_clearFill.ws0 : List Nat := []
kernel_rfl DEC_clearFill.fresh0 : (DEC_clearFill.S0.tab.all fun e => DEC_clearFill.ws0.all fun v => e.noVar v) &&
    (DEC_clearFill.S0.oracle.all fun q => DEC_clearFill.ws0.all fun v => q.noVar v) = true
kernel_rfl DEC_clearFill.mergeTab0 : DEC_clearFill.S1.tab = DEC_clearFill.S0.tab ++ Conv.resTab DEC_clearFill.ws0
kernel_rfl DEC_clearFill.mergeLen0 : DEC_clearFill.st0.S2.tab.length - DEC_clearFill.st0.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_clearFill.merged0`, `merged_relB`).
kernel_rfl DEC_clearFill.mheap0 : DEC_clearFill.s1.heap = DEC_clearFill.st0.s2.heap
kernel_rfl DEC_clearFill.mnext0 : DEC_clearFill.s1.next = DEC_clearFill.st0.s2.next
kernel_rfl DEC_clearFill.mctl0 : DEC_clearFill.s1.ctl = DEC_clearFill.st0.s2.ctl
kernel_rfl DEC_clearFill.mstack0 : DEC_clearFill.s1.stack = DEC_clearFill.st0.s2.stack ++ DEC_clearFill.s0.stack
kernel_rfl DEC_clearFill.mjobs0 : DEC_clearFill.s1.jobs = DEC_clearFill.st0.s2.jobs
kernel_rfl DEC_clearFill.mffi0 : DEC_clearFill.s1.ffi = DEC_clearFill.st0.s2.ffi
kernel_rfl DEC_clearFill.mtrace0 : DEC_clearFill.s1.trace = DEC_clearFill.st0.s2.trace
kernel_rfl DEC_clearFill.mstores0 : DEC_clearFill.s1.stores = DEC_clearFill.st0.s2.stores

end Host.Load.Run.Tpl
