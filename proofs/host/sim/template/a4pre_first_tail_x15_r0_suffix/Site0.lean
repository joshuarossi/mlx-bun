import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `PRE_first_tail_x15_r0_suffix`: `eval__g3d_first__g4_pf_first` (`evalCacheState`), the call state `PRE_first_tail_x15_r0_suffix.s2`, the merged state `PRE_first_tail_x15_r0_suffix.s3`,
the site template `PRE_first_tail_x15_r0_suffix.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_suffix.s4`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl PRE_first_tail_x15_r0_suffix.iso0 : PRE_first_tail_x15_r0_suffix.st0.s0 = { PRE_first_tail_x15_r0_suffix.s2 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_suffix.rs0 : List Frame := PRE_first_tail_x15_r0_suffix.s2.stack
kernel_rfl PRE_first_tail_x15_r0_suffix.n0_0 : PRE_first_tail_x15_r0_suffix.S2.tab.length = 8226
kernel_rfl PRE_first_tail_x15_r0_suffix.tab0_0 : PRE_first_tail_x15_r0_suffix.st0.S0.tab = PRE_first_tail_x15_r0_suffix.S2.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_suffix.ws0 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_suffix.fresh0 : (PRE_first_tail_x15_r0_suffix.S2.tab.all fun e => PRE_first_tail_x15_r0_suffix.ws0.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_suffix.S2.oracle.all fun q => PRE_first_tail_x15_r0_suffix.ws0.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.mergeTab0 : PRE_first_tail_x15_r0_suffix.S3.tab = PRE_first_tail_x15_r0_suffix.S2.tab ++ Conv.resTab PRE_first_tail_x15_r0_suffix.ws0
kernel_rfl PRE_first_tail_x15_r0_suffix.mergeLen0 : PRE_first_tail_x15_r0_suffix.st0.S5.tab.length - PRE_first_tail_x15_r0_suffix.st0.S0.tab.length = 0

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_suffix.merged0`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_suffix.mheap0 : PRE_first_tail_x15_r0_suffix.s3.heap = PRE_first_tail_x15_r0_suffix.st0.s5.heap
kernel_rfl PRE_first_tail_x15_r0_suffix.mnext0 : PRE_first_tail_x15_r0_suffix.s3.next = PRE_first_tail_x15_r0_suffix.st0.s5.next
kernel_rfl PRE_first_tail_x15_r0_suffix.mctl0 : PRE_first_tail_x15_r0_suffix.s3.ctl = PRE_first_tail_x15_r0_suffix.st0.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_suffix.mstack0 : PRE_first_tail_x15_r0_suffix.s3.stack = PRE_first_tail_x15_r0_suffix.st0.s5.stack ++ PRE_first_tail_x15_r0_suffix.s2.stack
kernel_rfl PRE_first_tail_x15_r0_suffix.mjobs0 : PRE_first_tail_x15_r0_suffix.s3.jobs = PRE_first_tail_x15_r0_suffix.st0.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_suffix.mffi0 : PRE_first_tail_x15_r0_suffix.s3.ffi = PRE_first_tail_x15_r0_suffix.st0.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_suffix.mtrace0 : PRE_first_tail_x15_r0_suffix.s3.trace = PRE_first_tail_x15_r0_suffix.st0.s5.trace
kernel_rfl PRE_first_tail_x15_r0_suffix.mstores0 : PRE_first_tail_x15_r0_suffix.s3.stores = PRE_first_tail_x15_r0_suffix.st0.s5.stores

end Host.Load.Run.Tpl
