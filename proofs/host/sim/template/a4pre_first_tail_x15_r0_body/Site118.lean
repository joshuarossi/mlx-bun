import host.sim.template.a4pre_first_tail_x15_r0_body.H32
import host.sim.template.a4pre_first_tail_x15_r0_body.st118.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 118 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g118__g119` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1044`, the merged state `PRE_first_tail_x15_r0_body.s1045`,
the site template `PRE_first_tail_x15_r0_body.st118` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1046`: the merge.
The footprint's facts are in `SiteF118`, the compaction's in `SiteC118`, `SiteK118`, `SiteNa118`, `SiteNb118`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso118 : PRE_first_tail_x15_r0_body.st118.s0 = { PRE_first_tail_x15_r0_body.s1044 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs118 : List Frame := PRE_first_tail_x15_r0_body.s1044.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_118 : PRE_first_tail_x15_r0_body.S1044.tab.length = 5123
kernel_rfl PRE_first_tail_x15_r0_body.tab0_118 : PRE_first_tail_x15_r0_body.st118.S0.tab = PRE_first_tail_x15_r0_body.S1044.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws118 : List Nat := [2991, 2992]
kernel_rfl PRE_first_tail_x15_r0_body.fresh118 : (PRE_first_tail_x15_r0_body.S1044.tab.all fun e => PRE_first_tail_x15_r0_body.ws118.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1044.oracle.all fun q => PRE_first_tail_x15_r0_body.ws118.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab118 : PRE_first_tail_x15_r0_body.S1045.tab = PRE_first_tail_x15_r0_body.S1044.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws118
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen118 : PRE_first_tail_x15_r0_body.st118.S2.tab.length - PRE_first_tail_x15_r0_body.st118.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged118`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap118 : PRE_first_tail_x15_r0_body.s1045.heap = PRE_first_tail_x15_r0_body.st118.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext118 : PRE_first_tail_x15_r0_body.s1045.next = PRE_first_tail_x15_r0_body.st118.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl118 : PRE_first_tail_x15_r0_body.s1045.ctl = PRE_first_tail_x15_r0_body.st118.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack118 : PRE_first_tail_x15_r0_body.s1045.stack = PRE_first_tail_x15_r0_body.st118.s2.stack ++ PRE_first_tail_x15_r0_body.s1044.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs118 : PRE_first_tail_x15_r0_body.s1045.jobs = PRE_first_tail_x15_r0_body.st118.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi118 : PRE_first_tail_x15_r0_body.s1045.ffi = PRE_first_tail_x15_r0_body.st118.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace118 : PRE_first_tail_x15_r0_body.s1045.trace = PRE_first_tail_x15_r0_body.st118.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores118 : PRE_first_tail_x15_r0_body.s1045.stores = PRE_first_tail_x15_r0_body.st118.s2.stores

end Host.Load.Run.Tpl
