import host.sim.template.a4pre_first_tail_x15_r0_body.H25
import host.sim.template.a4pre_first_tail_x15_r0_body.st83.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 83 of chain `PRE_first_tail_x15_r0_body`: `plan__g83__g84` (`plan`), the call state `PRE_first_tail_x15_r0_body.s804`, the merged state `PRE_first_tail_x15_r0_body.s805`,
the site template `PRE_first_tail_x15_r0_body.st83` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s806`: the merge.
The footprint's facts are in `SiteF83`, the compaction's in `SiteC83`, `SiteK83`, `SiteNa83`, `SiteNb83`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso83 : PRE_first_tail_x15_r0_body.st83.s0 = { PRE_first_tail_x15_r0_body.s804 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs83 : List Frame := PRE_first_tail_x15_r0_body.s804.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_83 : PRE_first_tail_x15_r0_body.S804.tab.length = 3601
kernel_rfl PRE_first_tail_x15_r0_body.tab0_83 : PRE_first_tail_x15_r0_body.st83.S0.tab = PRE_first_tail_x15_r0_body.S804.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws83 : List Nat := [2390, 2391, 2392]
kernel_rfl PRE_first_tail_x15_r0_body.fresh83 : (PRE_first_tail_x15_r0_body.S804.tab.all fun e => PRE_first_tail_x15_r0_body.ws83.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S804.oracle.all fun q => PRE_first_tail_x15_r0_body.ws83.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab83 : PRE_first_tail_x15_r0_body.S805.tab = PRE_first_tail_x15_r0_body.S804.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws83
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen83 : PRE_first_tail_x15_r0_body.st83.S2.tab.length - PRE_first_tail_x15_r0_body.st83.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged83`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap83 : PRE_first_tail_x15_r0_body.s805.heap = PRE_first_tail_x15_r0_body.st83.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext83 : PRE_first_tail_x15_r0_body.s805.next = PRE_first_tail_x15_r0_body.st83.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl83 : PRE_first_tail_x15_r0_body.s805.ctl = PRE_first_tail_x15_r0_body.st83.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack83 : PRE_first_tail_x15_r0_body.s805.stack = PRE_first_tail_x15_r0_body.st83.s2.stack ++ PRE_first_tail_x15_r0_body.s804.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs83 : PRE_first_tail_x15_r0_body.s805.jobs = PRE_first_tail_x15_r0_body.st83.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi83 : PRE_first_tail_x15_r0_body.s805.ffi = PRE_first_tail_x15_r0_body.st83.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace83 : PRE_first_tail_x15_r0_body.s805.trace = PRE_first_tail_x15_r0_body.st83.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores83 : PRE_first_tail_x15_r0_body.s805.stores = PRE_first_tail_x15_r0_body.st83.s2.stores

end Host.Load.Run.Tpl
