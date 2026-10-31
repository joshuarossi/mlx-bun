import host.sim.template.a4pre_first_tail_x15_r0_body.H25
import host.sim.template.a4pre_first_tail_x15_r0_body.st84.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 84 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g84__g85` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s821`, the merged state `PRE_first_tail_x15_r0_body.s822`,
the site template `PRE_first_tail_x15_r0_body.st84` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s823`: the merge.
The footprint's facts are in `SiteF84`, the compaction's in `SiteC84`, `SiteK84`, `SiteNa84`, `SiteNb84`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso84 : PRE_first_tail_x15_r0_body.st84.s0 = { PRE_first_tail_x15_r0_body.s821 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs84 : List Frame := PRE_first_tail_x15_r0_body.s821.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_84 : PRE_first_tail_x15_r0_body.S821.tab.length = 3674
kernel_rfl PRE_first_tail_x15_r0_body.tab0_84 : PRE_first_tail_x15_r0_body.st84.S0.tab = PRE_first_tail_x15_r0_body.S821.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws84 : List Nat := [2393, 2394, 2395, 2396, 2397, 2398, 2399, 2400, 2401, 2402, 2403, 2404, 2405, 2406, 2407, 2408, 2409, 2410, 2411, 2412, 2413, 2414, 2415, 2416, 2417, 2418, 2419, 2420, 2421, 2422, 2423]
kernel_rfl PRE_first_tail_x15_r0_body.fresh84 : (PRE_first_tail_x15_r0_body.S821.tab.all fun e => PRE_first_tail_x15_r0_body.ws84.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S821.oracle.all fun q => PRE_first_tail_x15_r0_body.ws84.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab84 : PRE_first_tail_x15_r0_body.S822.tab = PRE_first_tail_x15_r0_body.S821.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws84
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen84 : PRE_first_tail_x15_r0_body.st84.S5.tab.length - PRE_first_tail_x15_r0_body.st84.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged84`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap84 : PRE_first_tail_x15_r0_body.s822.heap = PRE_first_tail_x15_r0_body.st84.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext84 : PRE_first_tail_x15_r0_body.s822.next = PRE_first_tail_x15_r0_body.st84.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl84 : PRE_first_tail_x15_r0_body.s822.ctl = PRE_first_tail_x15_r0_body.st84.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack84 : PRE_first_tail_x15_r0_body.s822.stack = PRE_first_tail_x15_r0_body.st84.s5.stack ++ PRE_first_tail_x15_r0_body.s821.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs84 : PRE_first_tail_x15_r0_body.s822.jobs = PRE_first_tail_x15_r0_body.st84.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi84 : PRE_first_tail_x15_r0_body.s822.ffi = PRE_first_tail_x15_r0_body.st84.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace84 : PRE_first_tail_x15_r0_body.s822.trace = PRE_first_tail_x15_r0_body.st84.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores84 : PRE_first_tail_x15_r0_body.s822.stores = PRE_first_tail_x15_r0_body.st84.s5.stores

end Host.Load.Run.Tpl
