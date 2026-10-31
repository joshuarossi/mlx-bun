import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.st90.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 90 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g90__g91` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s879`, the merged state `PRE_first_tail_x15_r0_body.s880`,
the site template `PRE_first_tail_x15_r0_body.st90` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s881`: the merge.
The footprint's facts are in `SiteF90`, the compaction's in `SiteC90`, `SiteK90`, `SiteNa90`, `SiteNb90`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso90 : PRE_first_tail_x15_r0_body.st90.s0 = { PRE_first_tail_x15_r0_body.s879 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs90 : List Frame := PRE_first_tail_x15_r0_body.s879.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_90 : PRE_first_tail_x15_r0_body.S879.tab.length = 3932
kernel_rfl PRE_first_tail_x15_r0_body.tab0_90 : PRE_first_tail_x15_r0_body.st90.S0.tab = PRE_first_tail_x15_r0_body.S879.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws90 : List Nat := [2507, 2508, 2509, 2510, 2511, 2512, 2513, 2514, 2515, 2516, 2517, 2518, 2519, 2520, 2521, 2522, 2523, 2524, 2525, 2526, 2527, 2528, 2529, 2530, 2531, 2532, 2533, 2534, 2535, 2536, 2537]
kernel_rfl PRE_first_tail_x15_r0_body.fresh90 : (PRE_first_tail_x15_r0_body.S879.tab.all fun e => PRE_first_tail_x15_r0_body.ws90.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S879.oracle.all fun q => PRE_first_tail_x15_r0_body.ws90.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab90 : PRE_first_tail_x15_r0_body.S880.tab = PRE_first_tail_x15_r0_body.S879.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws90
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen90 : PRE_first_tail_x15_r0_body.st90.S5.tab.length - PRE_first_tail_x15_r0_body.st90.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged90`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap90 : PRE_first_tail_x15_r0_body.s880.heap = PRE_first_tail_x15_r0_body.st90.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext90 : PRE_first_tail_x15_r0_body.s880.next = PRE_first_tail_x15_r0_body.st90.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl90 : PRE_first_tail_x15_r0_body.s880.ctl = PRE_first_tail_x15_r0_body.st90.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack90 : PRE_first_tail_x15_r0_body.s880.stack = PRE_first_tail_x15_r0_body.st90.s5.stack ++ PRE_first_tail_x15_r0_body.s879.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs90 : PRE_first_tail_x15_r0_body.s880.jobs = PRE_first_tail_x15_r0_body.st90.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi90 : PRE_first_tail_x15_r0_body.s880.ffi = PRE_first_tail_x15_r0_body.st90.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace90 : PRE_first_tail_x15_r0_body.s880.trace = PRE_first_tail_x15_r0_body.st90.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores90 : PRE_first_tail_x15_r0_body.s880.stores = PRE_first_tail_x15_r0_body.st90.s5.stores

end Host.Load.Run.Tpl
