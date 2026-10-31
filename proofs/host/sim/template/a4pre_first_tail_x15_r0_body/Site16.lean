import host.sim.template.a4pre_first_tail_x15_r0_body.H5
import host.sim.template.a4pre_first_tail_x15_r0_body.st16.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 16 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g16__g17` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s168`, the merged state `PRE_first_tail_x15_r0_body.s169`,
the site template `PRE_first_tail_x15_r0_body.st16` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s170`: the merge.
The footprint's facts are in `SiteF16`, the compaction's in `SiteC16`, `SiteK16`, `SiteNa16`, `SiteNb16`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso16 : PRE_first_tail_x15_r0_body.st16.s0 = { PRE_first_tail_x15_r0_body.s168 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs16 : List Frame := PRE_first_tail_x15_r0_body.s168.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_16 : PRE_first_tail_x15_r0_body.S168.tab.length = 764
kernel_rfl PRE_first_tail_x15_r0_body.tab0_16 : PRE_first_tail_x15_r0_body.st16.S0.tab = PRE_first_tail_x15_r0_body.S168.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws16 : List Nat := [1302, 1303]
kernel_rfl PRE_first_tail_x15_r0_body.fresh16 : (PRE_first_tail_x15_r0_body.S168.tab.all fun e => PRE_first_tail_x15_r0_body.ws16.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S168.oracle.all fun q => PRE_first_tail_x15_r0_body.ws16.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab16 : PRE_first_tail_x15_r0_body.S169.tab = PRE_first_tail_x15_r0_body.S168.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws16
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen16 : PRE_first_tail_x15_r0_body.st16.S2.tab.length - PRE_first_tail_x15_r0_body.st16.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged16`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap16 : PRE_first_tail_x15_r0_body.s169.heap = PRE_first_tail_x15_r0_body.st16.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext16 : PRE_first_tail_x15_r0_body.s169.next = PRE_first_tail_x15_r0_body.st16.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl16 : PRE_first_tail_x15_r0_body.s169.ctl = PRE_first_tail_x15_r0_body.st16.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack16 : PRE_first_tail_x15_r0_body.s169.stack = PRE_first_tail_x15_r0_body.st16.s2.stack ++ PRE_first_tail_x15_r0_body.s168.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs16 : PRE_first_tail_x15_r0_body.s169.jobs = PRE_first_tail_x15_r0_body.st16.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi16 : PRE_first_tail_x15_r0_body.s169.ffi = PRE_first_tail_x15_r0_body.st16.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace16 : PRE_first_tail_x15_r0_body.s169.trace = PRE_first_tail_x15_r0_body.st16.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores16 : PRE_first_tail_x15_r0_body.s169.stores = PRE_first_tail_x15_r0_body.st16.s2.stores

end Host.Load.Run.Tpl
