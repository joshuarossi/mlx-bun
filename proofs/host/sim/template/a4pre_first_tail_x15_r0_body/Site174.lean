import host.sim.template.a4pre_first_tail_x15_r0_body.H48
import host.sim.template.a4pre_first_tail_x15_r0_body.st174.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 174 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g174__g175` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1538`, the merged state `PRE_first_tail_x15_r0_body.s1539`,
the site template `PRE_first_tail_x15_r0_body.st174` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1540`: the merge.
The footprint's facts are in `SiteF174`, the compaction's in `SiteC174`, `SiteK174`, `SiteNa174`, `SiteNb174`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso174 : PRE_first_tail_x15_r0_body.st174.s0 = { PRE_first_tail_x15_r0_body.s1538 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs174 : List Frame := PRE_first_tail_x15_r0_body.s1538.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_174 : PRE_first_tail_x15_r0_body.S1538.tab.length = 7523
kernel_rfl PRE_first_tail_x15_r0_body.tab0_174 : PRE_first_tail_x15_r0_body.st174.S0.tab = PRE_first_tail_x15_r0_body.S1538.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws174 : List Nat := [3930, 3931, 3932, 3933, 3934, 3935, 3936, 3937, 3938, 3939, 3940, 3941, 3942, 3943, 3944, 3945, 3946, 3947, 3948, 3949, 3950, 3951, 3952, 3953, 3954, 3955, 3956, 3957, 3958, 3959, 3960]
kernel_rfl PRE_first_tail_x15_r0_body.fresh174 : (PRE_first_tail_x15_r0_body.S1538.tab.all fun e => PRE_first_tail_x15_r0_body.ws174.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1538.oracle.all fun q => PRE_first_tail_x15_r0_body.ws174.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab174 : PRE_first_tail_x15_r0_body.S1539.tab = PRE_first_tail_x15_r0_body.S1538.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws174
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen174 : PRE_first_tail_x15_r0_body.st174.S3.tab.length - PRE_first_tail_x15_r0_body.st174.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged174`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap174 : PRE_first_tail_x15_r0_body.s1539.heap = PRE_first_tail_x15_r0_body.st174.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext174 : PRE_first_tail_x15_r0_body.s1539.next = PRE_first_tail_x15_r0_body.st174.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl174 : PRE_first_tail_x15_r0_body.s1539.ctl = PRE_first_tail_x15_r0_body.st174.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack174 : PRE_first_tail_x15_r0_body.s1539.stack = PRE_first_tail_x15_r0_body.st174.s3.stack ++ PRE_first_tail_x15_r0_body.s1538.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs174 : PRE_first_tail_x15_r0_body.s1539.jobs = PRE_first_tail_x15_r0_body.st174.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi174 : PRE_first_tail_x15_r0_body.s1539.ffi = PRE_first_tail_x15_r0_body.st174.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace174 : PRE_first_tail_x15_r0_body.s1539.trace = PRE_first_tail_x15_r0_body.st174.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores174 : PRE_first_tail_x15_r0_body.s1539.stores = PRE_first_tail_x15_r0_body.st174.s3.stores

end Host.Load.Run.Tpl
