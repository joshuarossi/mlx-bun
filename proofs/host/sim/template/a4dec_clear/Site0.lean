import host.sim.template.a4dec_clear.H0
import host.sim.template.a4dec_clear.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `DEC_clear`: `rb__start__g1` (`itemUint32`), the call state `DEC_clear.s0`, the merged state `DEC_clear.s1`,
the site template `DEC_clear.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `DEC_clear.s2`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl DEC_clear.iso0 : DEC_clear.st0.s0 = { DEC_clear.s0 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def DEC_clear.rs0 : List Frame := DEC_clear.s0.stack
kernel_rfl DEC_clear.n0_0 : DEC_clear.S0.tab.length = 123
kernel_rfl DEC_clear.tab0_0 : DEC_clear.st0.S0.tab = DEC_clear.S0.tab

/-- The fresh variables of the stage's results. -/
def DEC_clear.ws0 : List Nat := []
kernel_rfl DEC_clear.fresh0 : (DEC_clear.S0.tab.all fun e => DEC_clear.ws0.all fun v => e.noVar v) &&
    (DEC_clear.S0.oracle.all fun q => DEC_clear.ws0.all fun v => q.noVar v) = true
kernel_rfl DEC_clear.mergeTab0 : DEC_clear.S1.tab = DEC_clear.S0.tab ++ Conv.resTab DEC_clear.ws0
kernel_rfl DEC_clear.mergeLen0 : DEC_clear.st0.S2.tab.length - DEC_clear.st0.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`DEC_clear.merged0`, `merged_relB`).
kernel_rfl DEC_clear.mheap0 : DEC_clear.s1.heap = DEC_clear.st0.s2.heap
kernel_rfl DEC_clear.mnext0 : DEC_clear.s1.next = DEC_clear.st0.s2.next
kernel_rfl DEC_clear.mctl0 : DEC_clear.s1.ctl = DEC_clear.st0.s2.ctl
kernel_rfl DEC_clear.mstack0 : DEC_clear.s1.stack = DEC_clear.st0.s2.stack ++ DEC_clear.s0.stack
kernel_rfl DEC_clear.mjobs0 : DEC_clear.s1.jobs = DEC_clear.st0.s2.jobs
kernel_rfl DEC_clear.mffi0 : DEC_clear.s1.ffi = DEC_clear.st0.s2.ffi
kernel_rfl DEC_clear.mtrace0 : DEC_clear.s1.trace = DEC_clear.st0.s2.trace
kernel_rfl DEC_clear.mstores0 : DEC_clear.s1.stores = DEC_clear.st0.s2.stores

end Host.Load.Run.Tpl
