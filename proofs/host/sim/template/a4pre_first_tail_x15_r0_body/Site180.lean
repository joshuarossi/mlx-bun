import host.sim.template.a4pre_first_tail_x15_r0_body.H49
import host.sim.template.a4pre_first_tail_x15_r0_body.st180.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 180 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g180__g181` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1589`, the merged state `PRE_first_tail_x15_r0_body.s1590`,
the site template `PRE_first_tail_x15_r0_body.st180` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1591`: the merge.
The footprint's facts are in `SiteF180`, the compaction's in `SiteC180`, `SiteK180`, `SiteNa180`, `SiteNb180`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso180 : PRE_first_tail_x15_r0_body.st180.s0 = { PRE_first_tail_x15_r0_body.s1589 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs180 : List Frame := PRE_first_tail_x15_r0_body.s1589.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_180 : PRE_first_tail_x15_r0_body.S1589.tab.length = 7778
kernel_rfl PRE_first_tail_x15_r0_body.tab0_180 : PRE_first_tail_x15_r0_body.st180.S0.tab = PRE_first_tail_x15_r0_body.S1589.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws180 : List Nat := [4027, 4028, 4029, 4030, 4031, 4032, 4033, 4034, 4035, 4036, 4037, 4038, 4039, 4040, 4041, 4042, 4043, 4044, 4045, 4046, 4047, 4048, 4049, 4050, 4051, 4052, 4053, 4054, 4055, 4056, 4057]
kernel_rfl PRE_first_tail_x15_r0_body.fresh180 : (PRE_first_tail_x15_r0_body.S1589.tab.all fun e => PRE_first_tail_x15_r0_body.ws180.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1589.oracle.all fun q => PRE_first_tail_x15_r0_body.ws180.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab180 : PRE_first_tail_x15_r0_body.S1590.tab = PRE_first_tail_x15_r0_body.S1589.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws180
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen180 : PRE_first_tail_x15_r0_body.st180.S3.tab.length - PRE_first_tail_x15_r0_body.st180.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged180`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap180 : PRE_first_tail_x15_r0_body.s1590.heap = PRE_first_tail_x15_r0_body.st180.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext180 : PRE_first_tail_x15_r0_body.s1590.next = PRE_first_tail_x15_r0_body.st180.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl180 : PRE_first_tail_x15_r0_body.s1590.ctl = PRE_first_tail_x15_r0_body.st180.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack180 : PRE_first_tail_x15_r0_body.s1590.stack = PRE_first_tail_x15_r0_body.st180.s3.stack ++ PRE_first_tail_x15_r0_body.s1589.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs180 : PRE_first_tail_x15_r0_body.s1590.jobs = PRE_first_tail_x15_r0_body.st180.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi180 : PRE_first_tail_x15_r0_body.s1590.ffi = PRE_first_tail_x15_r0_body.st180.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace180 : PRE_first_tail_x15_r0_body.s1590.trace = PRE_first_tail_x15_r0_body.st180.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores180 : PRE_first_tail_x15_r0_body.s1590.stores = PRE_first_tail_x15_r0_body.st180.s3.stores

end Host.Load.Run.Tpl
