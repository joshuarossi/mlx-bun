import host.sim.template.a4dec_grow.H0
import host.sim.template.a4dec_grow.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `DEC_grow`: `rb__start__g1` (`itemUint32`), the call state `DEC_grow.s0`, the merged state `DEC_grow.s1`,
the site template `DEC_grow.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_grow.s2`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl DEC_grow.iso0 : DEC_grow.st0.s0 = { DEC_grow.s0 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_grow.rs0 : List Frame := DEC_grow.s0.stack
kernel_rfl DEC_grow.n0_0 : DEC_grow.S0.tab.length = 123
kernel_rfl DEC_grow.tab0_0 : DEC_grow.st0.S0.tab = DEC_grow.S0.tab

/-- The fresh variables of the stage's results. -/
def DEC_grow.ws0 : List Nat := []
kernel_rfl DEC_grow.fresh0 : (DEC_grow.S0.tab.all fun e => DEC_grow.ws0.all fun v => e.noVar v) &&
    (DEC_grow.S0.oracle.all fun q => DEC_grow.ws0.all fun v => q.noVar v) = true
kernel_rfl DEC_grow.mergeTab0 : DEC_grow.S1.tab = DEC_grow.S0.tab ++ Conv.resTab DEC_grow.ws0
kernel_rfl DEC_grow.mergeLen0 : DEC_grow.st0.S2.tab.length - DEC_grow.st0.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_grow.merged0`, `merged_relB`).
kernel_rfl DEC_grow.mheap0 : DEC_grow.s1.heap = DEC_grow.st0.s2.heap
kernel_rfl DEC_grow.mnext0 : DEC_grow.s1.next = DEC_grow.st0.s2.next
kernel_rfl DEC_grow.mctl0 : DEC_grow.s1.ctl = DEC_grow.st0.s2.ctl
kernel_rfl DEC_grow.mstack0 : DEC_grow.s1.stack = DEC_grow.st0.s2.stack ++ DEC_grow.s0.stack
kernel_rfl DEC_grow.mjobs0 : DEC_grow.s1.jobs = DEC_grow.st0.s2.jobs
kernel_rfl DEC_grow.mffi0 : DEC_grow.s1.ffi = DEC_grow.st0.s2.ffi
kernel_rfl DEC_grow.mtrace0 : DEC_grow.s1.trace = DEC_grow.st0.s2.trace
kernel_rfl DEC_grow.mstores0 : DEC_grow.s1.stores = DEC_grow.st0.s2.stores

end Host.Load.Run.Tpl
