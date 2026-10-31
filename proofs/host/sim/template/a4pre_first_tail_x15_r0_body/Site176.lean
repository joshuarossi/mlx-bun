import host.sim.template.a4pre_first_tail_x15_r0_body.H53
import host.sim.template.a4pre_first_tail_x15_r0_body.st176.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 176 of chain `PRE_first_tail_x15_r0_body`: `plan__g176__g177` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1696`, the merged state `PRE_first_tail_x15_r0_body.s1697`,
the site template `PRE_first_tail_x15_r0_body.st176` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1698`: the merge.
The footprint's facts are in `SiteF176`, the compaction's in `SiteC176`, `SiteK176`, `SiteNa176`, `SiteNb176`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso176 : PRE_first_tail_x15_r0_body.st176.s0 = { PRE_first_tail_x15_r0_body.s1696 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs176 : List Frame := PRE_first_tail_x15_r0_body.s1696.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_176 : PRE_first_tail_x15_r0_body.S1696.tab.length = 7579
kernel_rfl PRE_first_tail_x15_r0_body.tab0_176 : PRE_first_tail_x15_r0_body.st176.S0.tab = PRE_first_tail_x15_r0_body.S1696.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws176 : List Nat := [3981, 3982, 3983, 3984, 3985, 3986, 3987, 3988, 3989]
kernel_rfl PRE_first_tail_x15_r0_body.fresh176 : (PRE_first_tail_x15_r0_body.S1696.tab.all fun e => PRE_first_tail_x15_r0_body.ws176.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1696.oracle.all fun q => PRE_first_tail_x15_r0_body.ws176.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab176 : PRE_first_tail_x15_r0_body.S1697.tab = PRE_first_tail_x15_r0_body.S1696.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws176
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen176 : PRE_first_tail_x15_r0_body.st176.S2.tab.length - PRE_first_tail_x15_r0_body.st176.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged176`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap176 : PRE_first_tail_x15_r0_body.s1697.heap = PRE_first_tail_x15_r0_body.st176.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext176 : PRE_first_tail_x15_r0_body.s1697.next = PRE_first_tail_x15_r0_body.st176.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl176 : PRE_first_tail_x15_r0_body.s1697.ctl = PRE_first_tail_x15_r0_body.st176.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack176 : PRE_first_tail_x15_r0_body.s1697.stack = PRE_first_tail_x15_r0_body.st176.s2.stack ++ PRE_first_tail_x15_r0_body.s1696.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs176 : PRE_first_tail_x15_r0_body.s1697.jobs = PRE_first_tail_x15_r0_body.st176.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi176 : PRE_first_tail_x15_r0_body.s1697.ffi = PRE_first_tail_x15_r0_body.st176.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace176 : PRE_first_tail_x15_r0_body.s1697.trace = PRE_first_tail_x15_r0_body.st176.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores176 : PRE_first_tail_x15_r0_body.s1697.stores = PRE_first_tail_x15_r0_body.st176.s2.stores

end Host.Load.Run.Tpl
