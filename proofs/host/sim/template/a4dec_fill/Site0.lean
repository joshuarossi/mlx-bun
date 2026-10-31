import host.sim.template.a4dec_fill.H0
import host.sim.template.a4dec_fill.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `DEC_fill`: `rb__start__g1` (`itemUint32`), the call state `DEC_fill.s0`, the merged state `DEC_fill.s1`,
the site template `DEC_fill.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_fill.s2`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl DEC_fill.iso0 : DEC_fill.st0.s0 = { DEC_fill.s0 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_fill.rs0 : List Frame := DEC_fill.s0.stack
kernel_rfl DEC_fill.n0_0 : DEC_fill.S0.tab.length = 123
kernel_rfl DEC_fill.tab0_0 : DEC_fill.st0.S0.tab = DEC_fill.S0.tab

/-- The fresh variables of the stage's results. -/
def DEC_fill.ws0 : List Nat := []
kernel_rfl DEC_fill.fresh0 : (DEC_fill.S0.tab.all fun e => DEC_fill.ws0.all fun v => e.noVar v) &&
    (DEC_fill.S0.oracle.all fun q => DEC_fill.ws0.all fun v => q.noVar v) = true
kernel_rfl DEC_fill.mergeTab0 : DEC_fill.S1.tab = DEC_fill.S0.tab ++ Conv.resTab DEC_fill.ws0
kernel_rfl DEC_fill.mergeLen0 : DEC_fill.st0.S2.tab.length - DEC_fill.st0.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_fill.merged0`, `merged_relB`).
kernel_rfl DEC_fill.mheap0 : DEC_fill.s1.heap = DEC_fill.st0.s2.heap
kernel_rfl DEC_fill.mnext0 : DEC_fill.s1.next = DEC_fill.st0.s2.next
kernel_rfl DEC_fill.mctl0 : DEC_fill.s1.ctl = DEC_fill.st0.s2.ctl
kernel_rfl DEC_fill.mstack0 : DEC_fill.s1.stack = DEC_fill.st0.s2.stack ++ DEC_fill.s0.stack
kernel_rfl DEC_fill.mjobs0 : DEC_fill.s1.jobs = DEC_fill.st0.s2.jobs
kernel_rfl DEC_fill.mffi0 : DEC_fill.s1.ffi = DEC_fill.st0.s2.ffi
kernel_rfl DEC_fill.mtrace0 : DEC_fill.s1.trace = DEC_fill.st0.s2.trace
kernel_rfl DEC_fill.mstores0 : DEC_fill.s1.stores = DEC_fill.st0.s2.stores

end Host.Load.Run.Tpl
