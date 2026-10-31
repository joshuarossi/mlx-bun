import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.st57.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 57 of chain `PRE_first_tail_x15_r0_body`: `kvW__g57__g58` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s562`, the merged state `PRE_first_tail_x15_r0_body.s563`,
the site template `PRE_first_tail_x15_r0_body.st57` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s564`: the merge.
The footprint's facts are in `SiteF57`, the compaction's in `SiteC57`, `SiteK57`, `SiteNa57`, `SiteNb57`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso57 : PRE_first_tail_x15_r0_body.st57.s0 = { PRE_first_tail_x15_r0_body.s562 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs57 : List Frame := PRE_first_tail_x15_r0_body.s562.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_57 : PRE_first_tail_x15_r0_body.S562.tab.length = 2526
kernel_rfl PRE_first_tail_x15_r0_body.tab0_57 : PRE_first_tail_x15_r0_body.st57.S0.tab = PRE_first_tail_x15_r0_body.S562.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws57 : List Nat := [1976, 1977, 1978, 1979, 1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992]
kernel_rfl PRE_first_tail_x15_r0_body.fresh57 : (PRE_first_tail_x15_r0_body.S562.tab.all fun e => PRE_first_tail_x15_r0_body.ws57.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S562.oracle.all fun q => PRE_first_tail_x15_r0_body.ws57.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab57 : PRE_first_tail_x15_r0_body.S563.tab = PRE_first_tail_x15_r0_body.S562.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws57
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen57 : PRE_first_tail_x15_r0_body.st57.S3.tab.length - PRE_first_tail_x15_r0_body.st57.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged57`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap57 : PRE_first_tail_x15_r0_body.s563.heap = PRE_first_tail_x15_r0_body.st57.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext57 : PRE_first_tail_x15_r0_body.s563.next = PRE_first_tail_x15_r0_body.st57.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl57 : PRE_first_tail_x15_r0_body.s563.ctl = PRE_first_tail_x15_r0_body.st57.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack57 : PRE_first_tail_x15_r0_body.s563.stack = PRE_first_tail_x15_r0_body.st57.s3.stack ++ PRE_first_tail_x15_r0_body.s562.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs57 : PRE_first_tail_x15_r0_body.s563.jobs = PRE_first_tail_x15_r0_body.st57.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi57 : PRE_first_tail_x15_r0_body.s563.ffi = PRE_first_tail_x15_r0_body.st57.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace57 : PRE_first_tail_x15_r0_body.s563.trace = PRE_first_tail_x15_r0_body.st57.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores57 : PRE_first_tail_x15_r0_body.s563.stores = PRE_first_tail_x15_r0_body.st57.s3.stores

end Host.Load.Run.Tpl
