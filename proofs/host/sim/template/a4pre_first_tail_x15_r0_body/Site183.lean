import host.sim.template.a4pre_first_tail_x15_r0_body.H50
import host.sim.template.a4pre_first_tail_x15_r0_body.st183.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 183 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g183__g184` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1616`, the merged state `PRE_first_tail_x15_r0_body.s1617`,
the site template `PRE_first_tail_x15_r0_body.st183` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1618`: the merge.
The footprint's facts are in `SiteF183`, the compaction's in `SiteC183`, `SiteK183`, `SiteNa183`, `SiteNb183`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso183 : PRE_first_tail_x15_r0_body.st183.s0 = { PRE_first_tail_x15_r0_body.s1616 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs183 : List Frame := PRE_first_tail_x15_r0_body.s1616.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_183 : PRE_first_tail_x15_r0_body.S1616.tab.length = 7907
kernel_rfl PRE_first_tail_x15_r0_body.tab0_183 : PRE_first_tail_x15_r0_body.st183.S0.tab = PRE_first_tail_x15_r0_body.S1616.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws183 : List Nat := [4087, 4088, 4089, 4090, 4091, 4092, 4093, 4094, 4095, 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117]
kernel_rfl PRE_first_tail_x15_r0_body.fresh183 : (PRE_first_tail_x15_r0_body.S1616.tab.all fun e => PRE_first_tail_x15_r0_body.ws183.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1616.oracle.all fun q => PRE_first_tail_x15_r0_body.ws183.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab183 : PRE_first_tail_x15_r0_body.S1617.tab = PRE_first_tail_x15_r0_body.S1616.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws183
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen183 : PRE_first_tail_x15_r0_body.st183.S3.tab.length - PRE_first_tail_x15_r0_body.st183.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged183`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap183 : PRE_first_tail_x15_r0_body.s1617.heap = PRE_first_tail_x15_r0_body.st183.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext183 : PRE_first_tail_x15_r0_body.s1617.next = PRE_first_tail_x15_r0_body.st183.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl183 : PRE_first_tail_x15_r0_body.s1617.ctl = PRE_first_tail_x15_r0_body.st183.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack183 : PRE_first_tail_x15_r0_body.s1617.stack = PRE_first_tail_x15_r0_body.st183.s3.stack ++ PRE_first_tail_x15_r0_body.s1616.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs183 : PRE_first_tail_x15_r0_body.s1617.jobs = PRE_first_tail_x15_r0_body.st183.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi183 : PRE_first_tail_x15_r0_body.s1617.ffi = PRE_first_tail_x15_r0_body.st183.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace183 : PRE_first_tail_x15_r0_body.s1617.trace = PRE_first_tail_x15_r0_body.st183.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores183 : PRE_first_tail_x15_r0_body.s1617.stores = PRE_first_tail_x15_r0_body.st183.s3.stores

end Host.Load.Run.Tpl
