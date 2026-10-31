import host.sim.template.a4pre_first_tail_x15_r0_body.H49
import host.sim.template.a4pre_first_tail_x15_r0_body.st181.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 181 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g181__g182` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1596`, the merged state `PRE_first_tail_x15_r0_body.s1597`,
the site template `PRE_first_tail_x15_r0_body.st181` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1598`: the merge.
The footprint's facts are in `SiteF181`, the compaction's in `SiteC181`, `SiteK181`, `SiteNa181`, `SiteNb181`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso181 : PRE_first_tail_x15_r0_body.st181.s0 = { PRE_first_tail_x15_r0_body.s1596 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs181 : List Frame := PRE_first_tail_x15_r0_body.s1596.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_181 : PRE_first_tail_x15_r0_body.S1596.tab.length = 7817
kernel_rfl PRE_first_tail_x15_r0_body.tab0_181 : PRE_first_tail_x15_r0_body.st181.S0.tab = PRE_first_tail_x15_r0_body.S1596.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws181 : List Nat := [4076, 4077]
kernel_rfl PRE_first_tail_x15_r0_body.fresh181 : (PRE_first_tail_x15_r0_body.S1596.tab.all fun e => PRE_first_tail_x15_r0_body.ws181.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1596.oracle.all fun q => PRE_first_tail_x15_r0_body.ws181.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab181 : PRE_first_tail_x15_r0_body.S1597.tab = PRE_first_tail_x15_r0_body.S1596.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws181
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen181 : PRE_first_tail_x15_r0_body.st181.S2.tab.length - PRE_first_tail_x15_r0_body.st181.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged181`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap181 : PRE_first_tail_x15_r0_body.s1597.heap = PRE_first_tail_x15_r0_body.st181.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext181 : PRE_first_tail_x15_r0_body.s1597.next = PRE_first_tail_x15_r0_body.st181.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl181 : PRE_first_tail_x15_r0_body.s1597.ctl = PRE_first_tail_x15_r0_body.st181.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack181 : PRE_first_tail_x15_r0_body.s1597.stack = PRE_first_tail_x15_r0_body.st181.s2.stack ++ PRE_first_tail_x15_r0_body.s1596.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs181 : PRE_first_tail_x15_r0_body.s1597.jobs = PRE_first_tail_x15_r0_body.st181.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi181 : PRE_first_tail_x15_r0_body.s1597.ffi = PRE_first_tail_x15_r0_body.st181.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace181 : PRE_first_tail_x15_r0_body.s1597.trace = PRE_first_tail_x15_r0_body.st181.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores181 : PRE_first_tail_x15_r0_body.s1597.stores = PRE_first_tail_x15_r0_body.st181.s2.stores

end Host.Load.Run.Tpl
