import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.st63.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 63 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g63__g64` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s566`, the merged state `PRE_first_tail_x15_r0_body.s567`,
the site template `PRE_first_tail_x15_r0_body.st63` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s568`: the merge.
The footprint's facts are in `SiteF63`, the compaction's in `SiteC63`, `SiteK63`, `SiteNa63`, `SiteNb63`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso63 : PRE_first_tail_x15_r0_body.st63.s0 = { PRE_first_tail_x15_r0_body.s566 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs63 : List Frame := PRE_first_tail_x15_r0_body.s566.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_63 : PRE_first_tail_x15_r0_body.S566.tab.length = 2777
kernel_rfl PRE_first_tail_x15_r0_body.tab0_63 : PRE_first_tail_x15_r0_body.st63.S0.tab = PRE_first_tail_x15_r0_body.S566.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws63 : List Nat := [2061, 2062, 2063, 2064, 2065, 2066, 2067, 2068, 2069, 2070, 2071, 2072, 2073, 2074, 2075, 2076, 2077, 2078, 2079, 2080, 2081, 2082, 2083, 2084, 2085, 2086, 2087, 2088, 2089, 2090, 2091]
kernel_rfl PRE_first_tail_x15_r0_body.fresh63 : (PRE_first_tail_x15_r0_body.S566.tab.all fun e => PRE_first_tail_x15_r0_body.ws63.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S566.oracle.all fun q => PRE_first_tail_x15_r0_body.ws63.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab63 : PRE_first_tail_x15_r0_body.S567.tab = PRE_first_tail_x15_r0_body.S566.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws63
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen63 : PRE_first_tail_x15_r0_body.st63.S3.tab.length - PRE_first_tail_x15_r0_body.st63.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged63`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap63 : PRE_first_tail_x15_r0_body.s567.heap = PRE_first_tail_x15_r0_body.st63.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext63 : PRE_first_tail_x15_r0_body.s567.next = PRE_first_tail_x15_r0_body.st63.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl63 : PRE_first_tail_x15_r0_body.s567.ctl = PRE_first_tail_x15_r0_body.st63.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack63 : PRE_first_tail_x15_r0_body.s567.stack = PRE_first_tail_x15_r0_body.st63.s3.stack ++ PRE_first_tail_x15_r0_body.s566.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs63 : PRE_first_tail_x15_r0_body.s567.jobs = PRE_first_tail_x15_r0_body.st63.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi63 : PRE_first_tail_x15_r0_body.s567.ffi = PRE_first_tail_x15_r0_body.st63.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace63 : PRE_first_tail_x15_r0_body.s567.trace = PRE_first_tail_x15_r0_body.st63.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores63 : PRE_first_tail_x15_r0_body.s567.stores = PRE_first_tail_x15_r0_body.st63.s3.stores

end Host.Load.Run.Tpl
