import host.sim.template.a4pre_first_tail_x15_r0_body.H18
import host.sim.template.a4pre_first_tail_x15_r0_body.st66.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 66 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g66__g67` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s593`, the merged state `PRE_first_tail_x15_r0_body.s594`,
the site template `PRE_first_tail_x15_r0_body.st66` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s595`: the merge.
The footprint's facts are in `SiteF66`, the compaction's in `SiteC66`, `SiteK66`, `SiteNa66`, `SiteNb66`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso66 : PRE_first_tail_x15_r0_body.st66.s0 = { PRE_first_tail_x15_r0_body.s593 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs66 : List Frame := PRE_first_tail_x15_r0_body.s593.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_66 : PRE_first_tail_x15_r0_body.S593.tab.length = 2906
kernel_rfl PRE_first_tail_x15_r0_body.tab0_66 : PRE_first_tail_x15_r0_body.st66.S0.tab = PRE_first_tail_x15_r0_body.S593.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws66 : List Nat := [2115, 2116, 2117, 2118, 2119, 2120, 2121, 2122, 2123, 2124, 2125, 2126, 2127, 2128, 2129, 2130, 2131, 2132, 2133, 2134, 2135, 2136, 2137, 2138, 2139, 2140, 2141, 2142, 2143, 2144, 2145]
kernel_rfl PRE_first_tail_x15_r0_body.fresh66 : (PRE_first_tail_x15_r0_body.S593.tab.all fun e => PRE_first_tail_x15_r0_body.ws66.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S593.oracle.all fun q => PRE_first_tail_x15_r0_body.ws66.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab66 : PRE_first_tail_x15_r0_body.S594.tab = PRE_first_tail_x15_r0_body.S593.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws66
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen66 : PRE_first_tail_x15_r0_body.st66.S3.tab.length - PRE_first_tail_x15_r0_body.st66.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged66`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap66 : PRE_first_tail_x15_r0_body.s594.heap = PRE_first_tail_x15_r0_body.st66.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext66 : PRE_first_tail_x15_r0_body.s594.next = PRE_first_tail_x15_r0_body.st66.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl66 : PRE_first_tail_x15_r0_body.s594.ctl = PRE_first_tail_x15_r0_body.st66.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack66 : PRE_first_tail_x15_r0_body.s594.stack = PRE_first_tail_x15_r0_body.st66.s3.stack ++ PRE_first_tail_x15_r0_body.s593.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs66 : PRE_first_tail_x15_r0_body.s594.jobs = PRE_first_tail_x15_r0_body.st66.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi66 : PRE_first_tail_x15_r0_body.s594.ffi = PRE_first_tail_x15_r0_body.st66.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace66 : PRE_first_tail_x15_r0_body.s594.trace = PRE_first_tail_x15_r0_body.st66.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores66 : PRE_first_tail_x15_r0_body.s594.stores = PRE_first_tail_x15_r0_body.st66.s3.stores

end Host.Load.Run.Tpl
