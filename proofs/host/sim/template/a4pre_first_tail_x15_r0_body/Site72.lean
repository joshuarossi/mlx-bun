import host.sim.template.a4pre_first_tail_x15_r0_body.H20
import host.sim.template.a4pre_first_tail_x15_r0_body.st72.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 72 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g72__g73` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s644`, the merged state `PRE_first_tail_x15_r0_body.s645`,
the site template `PRE_first_tail_x15_r0_body.st72` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s646`: the merge.
The footprint's facts are in `SiteF72`, the compaction's in `SiteC72`, `SiteK72`, `SiteNa72`, `SiteNb72`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso72 : PRE_first_tail_x15_r0_body.st72.s0 = { PRE_first_tail_x15_r0_body.s644 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs72 : List Frame := PRE_first_tail_x15_r0_body.s644.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_72 : PRE_first_tail_x15_r0_body.S644.tab.length = 3161
kernel_rfl PRE_first_tail_x15_r0_body.tab0_72 : PRE_first_tail_x15_r0_body.st72.S0.tab = PRE_first_tail_x15_r0_body.S644.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws72 : List Nat := [2200, 2201, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 2213, 2214, 2215, 2216, 2217, 2218, 2219, 2220, 2221, 2222, 2223, 2224, 2225, 2226, 2227, 2228, 2229, 2230]
kernel_rfl PRE_first_tail_x15_r0_body.fresh72 : (PRE_first_tail_x15_r0_body.S644.tab.all fun e => PRE_first_tail_x15_r0_body.ws72.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S644.oracle.all fun q => PRE_first_tail_x15_r0_body.ws72.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab72 : PRE_first_tail_x15_r0_body.S645.tab = PRE_first_tail_x15_r0_body.S644.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws72
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen72 : PRE_first_tail_x15_r0_body.st72.S3.tab.length - PRE_first_tail_x15_r0_body.st72.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged72`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap72 : PRE_first_tail_x15_r0_body.s645.heap = PRE_first_tail_x15_r0_body.st72.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext72 : PRE_first_tail_x15_r0_body.s645.next = PRE_first_tail_x15_r0_body.st72.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl72 : PRE_first_tail_x15_r0_body.s645.ctl = PRE_first_tail_x15_r0_body.st72.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack72 : PRE_first_tail_x15_r0_body.s645.stack = PRE_first_tail_x15_r0_body.st72.s3.stack ++ PRE_first_tail_x15_r0_body.s644.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs72 : PRE_first_tail_x15_r0_body.s645.jobs = PRE_first_tail_x15_r0_body.st72.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi72 : PRE_first_tail_x15_r0_body.s645.ffi = PRE_first_tail_x15_r0_body.st72.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace72 : PRE_first_tail_x15_r0_body.s645.trace = PRE_first_tail_x15_r0_body.st72.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores72 : PRE_first_tail_x15_r0_body.s645.stores = PRE_first_tail_x15_r0_body.st72.s3.stores

end Host.Load.Run.Tpl
