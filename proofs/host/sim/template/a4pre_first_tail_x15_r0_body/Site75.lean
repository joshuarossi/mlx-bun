import host.sim.template.a4pre_first_tail_x15_r0_body.H21
import host.sim.template.a4pre_first_tail_x15_r0_body.st75.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 75 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g75__g76` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s671`, the merged state `PRE_first_tail_x15_r0_body.s672`,
the site template `PRE_first_tail_x15_r0_body.st75` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s673`: the merge.
The footprint's facts are in `SiteF75`, the compaction's in `SiteC75`, `SiteK75`, `SiteNa75`, `SiteNb75`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso75 : PRE_first_tail_x15_r0_body.st75.s0 = { PRE_first_tail_x15_r0_body.s671 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs75 : List Frame := PRE_first_tail_x15_r0_body.s671.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_75 : PRE_first_tail_x15_r0_body.S671.tab.length = 3290
kernel_rfl PRE_first_tail_x15_r0_body.tab0_75 : PRE_first_tail_x15_r0_body.st75.S0.tab = PRE_first_tail_x15_r0_body.S671.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws75 : List Nat := [2254, 2255, 2256, 2257, 2258, 2259, 2260, 2261, 2262, 2263, 2264, 2265, 2266, 2267, 2268, 2269, 2270, 2271, 2272, 2273, 2274, 2275, 2276, 2277, 2278, 2279, 2280, 2281, 2282, 2283, 2284]
kernel_rfl PRE_first_tail_x15_r0_body.fresh75 : (PRE_first_tail_x15_r0_body.S671.tab.all fun e => PRE_first_tail_x15_r0_body.ws75.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S671.oracle.all fun q => PRE_first_tail_x15_r0_body.ws75.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab75 : PRE_first_tail_x15_r0_body.S672.tab = PRE_first_tail_x15_r0_body.S671.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws75
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen75 : PRE_first_tail_x15_r0_body.st75.S3.tab.length - PRE_first_tail_x15_r0_body.st75.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged75`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap75 : PRE_first_tail_x15_r0_body.s672.heap = PRE_first_tail_x15_r0_body.st75.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext75 : PRE_first_tail_x15_r0_body.s672.next = PRE_first_tail_x15_r0_body.st75.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl75 : PRE_first_tail_x15_r0_body.s672.ctl = PRE_first_tail_x15_r0_body.st75.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack75 : PRE_first_tail_x15_r0_body.s672.stack = PRE_first_tail_x15_r0_body.st75.s3.stack ++ PRE_first_tail_x15_r0_body.s671.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs75 : PRE_first_tail_x15_r0_body.s672.jobs = PRE_first_tail_x15_r0_body.st75.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi75 : PRE_first_tail_x15_r0_body.s672.ffi = PRE_first_tail_x15_r0_body.st75.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace75 : PRE_first_tail_x15_r0_body.s672.trace = PRE_first_tail_x15_r0_body.st75.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores75 : PRE_first_tail_x15_r0_body.s672.stores = PRE_first_tail_x15_r0_body.st75.s3.stores

end Host.Load.Run.Tpl
