import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st0.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g0__g1` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s15`, the merged state `PRE_first_tail_x15_r0_body.s16`,
the site template `PRE_first_tail_x15_r0_body.st0` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s17`: the merge.
The footprint's facts are in `SiteF0`, the compaction's in `SiteC0`, `SiteK0`, `SiteNa0`, `SiteNb0`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso0 : PRE_first_tail_x15_r0_body.st0.s0 = { PRE_first_tail_x15_r0_body.s15 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs0 : List Frame := PRE_first_tail_x15_r0_body.s15.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_0 : PRE_first_tail_x15_r0_body.S15.tab.length = 83
kernel_rfl PRE_first_tail_x15_r0_body.tab0_0 : PRE_first_tail_x15_r0_body.st0.S0.tab = PRE_first_tail_x15_r0_body.S15.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws0 : List Nat := [1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030]
kernel_rfl PRE_first_tail_x15_r0_body.fresh0 : (PRE_first_tail_x15_r0_body.S15.tab.all fun e => PRE_first_tail_x15_r0_body.ws0.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S15.oracle.all fun q => PRE_first_tail_x15_r0_body.ws0.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab0 : PRE_first_tail_x15_r0_body.S16.tab = PRE_first_tail_x15_r0_body.S15.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws0
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen0 : PRE_first_tail_x15_r0_body.st0.S7.tab.length - PRE_first_tail_x15_r0_body.st0.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged0`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap0 : PRE_first_tail_x15_r0_body.s16.heap = PRE_first_tail_x15_r0_body.st0.s7.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext0 : PRE_first_tail_x15_r0_body.s16.next = PRE_first_tail_x15_r0_body.st0.s7.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl0 : PRE_first_tail_x15_r0_body.s16.ctl = PRE_first_tail_x15_r0_body.st0.s7.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack0 : PRE_first_tail_x15_r0_body.s16.stack = PRE_first_tail_x15_r0_body.st0.s7.stack ++ PRE_first_tail_x15_r0_body.s15.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs0 : PRE_first_tail_x15_r0_body.s16.jobs = PRE_first_tail_x15_r0_body.st0.s7.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi0 : PRE_first_tail_x15_r0_body.s16.ffi = PRE_first_tail_x15_r0_body.st0.s7.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace0 : PRE_first_tail_x15_r0_body.s16.trace = PRE_first_tail_x15_r0_body.st0.s7.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores0 : PRE_first_tail_x15_r0_body.s16.stores = PRE_first_tail_x15_r0_body.st0.s7.stores

end Host.Load.Run.Tpl
