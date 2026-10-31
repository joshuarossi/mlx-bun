import host.sim.template.a4dec_ord.H0
import host.sim.template.a4dec_ord.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `DEC_ord`: `rb__start__g1` (`itemUint32`), the call state `DEC_ord.s0`, the merged state `DEC_ord.s1`,
the site template `DEC_ord.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_ord.s2`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl DEC_ord.iso0 : DEC_ord.st0.s0 = { DEC_ord.s0 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_ord.rs0 : List Frame := DEC_ord.s0.stack
kernel_rfl DEC_ord.n0_0 : DEC_ord.S0.tab.length = 123
kernel_rfl DEC_ord.tab0_0 : DEC_ord.st0.S0.tab = DEC_ord.S0.tab

/-- The fresh variables of the stage's results. -/
def DEC_ord.ws0 : List Nat := []
kernel_rfl DEC_ord.fresh0 : (DEC_ord.S0.tab.all fun e => DEC_ord.ws0.all fun v => e.noVar v) &&
    (DEC_ord.S0.oracle.all fun q => DEC_ord.ws0.all fun v => q.noVar v) = true
kernel_rfl DEC_ord.mergeTab0 : DEC_ord.S1.tab = DEC_ord.S0.tab ++ Conv.resTab DEC_ord.ws0
kernel_rfl DEC_ord.mergeLen0 : DEC_ord.st0.S2.tab.length - DEC_ord.st0.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_ord.merged0`, `merged_relB`).
kernel_rfl DEC_ord.mheap0 : DEC_ord.s1.heap = DEC_ord.st0.s2.heap
kernel_rfl DEC_ord.mnext0 : DEC_ord.s1.next = DEC_ord.st0.s2.next
kernel_rfl DEC_ord.mctl0 : DEC_ord.s1.ctl = DEC_ord.st0.s2.ctl
kernel_rfl DEC_ord.mstack0 : DEC_ord.s1.stack = DEC_ord.st0.s2.stack ++ DEC_ord.s0.stack
kernel_rfl DEC_ord.mjobs0 : DEC_ord.s1.jobs = DEC_ord.st0.s2.jobs
kernel_rfl DEC_ord.mffi0 : DEC_ord.s1.ffi = DEC_ord.st0.s2.ffi
kernel_rfl DEC_ord.mtrace0 : DEC_ord.s1.trace = DEC_ord.st0.s2.trace
kernel_rfl DEC_ord.mstores0 : DEC_ord.s1.stores = DEC_ord.st0.s2.stores

end Host.Load.Run.Tpl
