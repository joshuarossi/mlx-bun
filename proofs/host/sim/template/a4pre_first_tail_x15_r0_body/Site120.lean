import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.a4pre_first_tail_x15_r0_body.st120.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 120 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g120__g121` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1166`, the merged state `PRE_first_tail_x15_r0_body.s1167`,
the site template `PRE_first_tail_x15_r0_body.st120` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1168`: the merge.
The footprint's facts are in `SiteF120`, the compaction's in `SiteC120`, `SiteK120`, `SiteNa120`, `SiteNb120`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso120 : PRE_first_tail_x15_r0_body.st120.s0 = { PRE_first_tail_x15_r0_body.s1166 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs120 : List Frame := PRE_first_tail_x15_r0_body.s1166.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_120 : PRE_first_tail_x15_r0_body.S1166.tab.length = 5213
kernel_rfl PRE_first_tail_x15_r0_body.tab0_120 : PRE_first_tail_x15_r0_body.st120.S0.tab = PRE_first_tail_x15_r0_body.S1166.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws120 : List Nat := [2996, 2997, 2998, 2999, 3000, 3001, 3002, 3003, 3004, 3005, 3006, 3007, 3008, 3009, 3010, 3011, 3012, 3013, 3014, 3015, 3016, 3017, 3018, 3019, 3020, 3021, 3022, 3023, 3024, 3025, 3026]
kernel_rfl PRE_first_tail_x15_r0_body.fresh120 : (PRE_first_tail_x15_r0_body.S1166.tab.all fun e => PRE_first_tail_x15_r0_body.ws120.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1166.oracle.all fun q => PRE_first_tail_x15_r0_body.ws120.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab120 : PRE_first_tail_x15_r0_body.S1167.tab = PRE_first_tail_x15_r0_body.S1166.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws120
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen120 : PRE_first_tail_x15_r0_body.st120.S5.tab.length - PRE_first_tail_x15_r0_body.st120.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged120`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap120 : PRE_first_tail_x15_r0_body.s1167.heap = PRE_first_tail_x15_r0_body.st120.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext120 : PRE_first_tail_x15_r0_body.s1167.next = PRE_first_tail_x15_r0_body.st120.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl120 : PRE_first_tail_x15_r0_body.s1167.ctl = PRE_first_tail_x15_r0_body.st120.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack120 : PRE_first_tail_x15_r0_body.s1167.stack = PRE_first_tail_x15_r0_body.st120.s5.stack ++ PRE_first_tail_x15_r0_body.s1166.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs120 : PRE_first_tail_x15_r0_body.s1167.jobs = PRE_first_tail_x15_r0_body.st120.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi120 : PRE_first_tail_x15_r0_body.s1167.ffi = PRE_first_tail_x15_r0_body.st120.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace120 : PRE_first_tail_x15_r0_body.s1167.trace = PRE_first_tail_x15_r0_body.st120.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores120 : PRE_first_tail_x15_r0_body.s1167.stores = PRE_first_tail_x15_r0_body.st120.s5.stores

end Host.Load.Run.Tpl
