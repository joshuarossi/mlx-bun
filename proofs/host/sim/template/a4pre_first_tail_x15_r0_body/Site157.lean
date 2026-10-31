import host.sim.template.a4pre_first_tail_x15_r0_body.H43
import host.sim.template.a4pre_first_tail_x15_r0_body.st157.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 157 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g157__g158` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1386`, the merged state `PRE_first_tail_x15_r0_body.s1387`,
the site template `PRE_first_tail_x15_r0_body.st157` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1388`: the merge.
The footprint's facts are in `SiteF157`, the compaction's in `SiteC157`, `SiteK157`, `SiteNa157`, `SiteNb157`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso157 : PRE_first_tail_x15_r0_body.st157.s0 = { PRE_first_tail_x15_r0_body.s1386 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs157 : List Frame := PRE_first_tail_x15_r0_body.s1386.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_157 : PRE_first_tail_x15_r0_body.S1386.tab.length = 6791
kernel_rfl PRE_first_tail_x15_r0_body.tab0_157 : PRE_first_tail_x15_r0_body.st157.S0.tab = PRE_first_tail_x15_r0_body.S1386.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws157 : List Nat := [3654, 3655]
kernel_rfl PRE_first_tail_x15_r0_body.fresh157 : (PRE_first_tail_x15_r0_body.S1386.tab.all fun e => PRE_first_tail_x15_r0_body.ws157.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1386.oracle.all fun q => PRE_first_tail_x15_r0_body.ws157.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab157 : PRE_first_tail_x15_r0_body.S1387.tab = PRE_first_tail_x15_r0_body.S1386.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws157
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen157 : PRE_first_tail_x15_r0_body.st157.S2.tab.length - PRE_first_tail_x15_r0_body.st157.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged157`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap157 : PRE_first_tail_x15_r0_body.s1387.heap = PRE_first_tail_x15_r0_body.st157.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext157 : PRE_first_tail_x15_r0_body.s1387.next = PRE_first_tail_x15_r0_body.st157.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl157 : PRE_first_tail_x15_r0_body.s1387.ctl = PRE_first_tail_x15_r0_body.st157.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack157 : PRE_first_tail_x15_r0_body.s1387.stack = PRE_first_tail_x15_r0_body.st157.s2.stack ++ PRE_first_tail_x15_r0_body.s1386.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs157 : PRE_first_tail_x15_r0_body.s1387.jobs = PRE_first_tail_x15_r0_body.st157.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi157 : PRE_first_tail_x15_r0_body.s1387.ffi = PRE_first_tail_x15_r0_body.st157.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace157 : PRE_first_tail_x15_r0_body.s1387.trace = PRE_first_tail_x15_r0_body.st157.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores157 : PRE_first_tail_x15_r0_body.s1387.stores = PRE_first_tail_x15_r0_body.st157.s2.stores

end Host.Load.Run.Tpl
