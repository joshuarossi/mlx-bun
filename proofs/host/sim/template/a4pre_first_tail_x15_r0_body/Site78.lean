import host.sim.template.a4pre_first_tail_x15_r0_body.H23
import host.sim.template.a4pre_first_tail_x15_r0_body.st78.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 78 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g78__g79` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s764`, the merged state `PRE_first_tail_x15_r0_body.s765`,
the site template `PRE_first_tail_x15_r0_body.st78` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s766`: the merge.
The footprint's facts are in `SiteF78`, the compaction's in `SiteC78`, `SiteK78`, `SiteNa78`, `SiteNb78`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso78 : PRE_first_tail_x15_r0_body.st78.s0 = { PRE_first_tail_x15_r0_body.s764 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs78 : List Frame := PRE_first_tail_x15_r0_body.s764.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_78 : PRE_first_tail_x15_r0_body.S764.tab.length = 3419
kernel_rfl PRE_first_tail_x15_r0_body.tab0_78 : PRE_first_tail_x15_r0_body.st78.S0.tab = PRE_first_tail_x15_r0_body.S764.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws78 : List Nat := [2308, 2309, 2310, 2311, 2312, 2313, 2314, 2315, 2316, 2317, 2318, 2319, 2320, 2321, 2322, 2323, 2324, 2325, 2326, 2327, 2328, 2329, 2330, 2331, 2332, 2333, 2334, 2335, 2336, 2337, 2338]
kernel_rfl PRE_first_tail_x15_r0_body.fresh78 : (PRE_first_tail_x15_r0_body.S764.tab.all fun e => PRE_first_tail_x15_r0_body.ws78.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S764.oracle.all fun q => PRE_first_tail_x15_r0_body.ws78.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab78 : PRE_first_tail_x15_r0_body.S765.tab = PRE_first_tail_x15_r0_body.S764.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws78
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen78 : PRE_first_tail_x15_r0_body.st78.S5.tab.length - PRE_first_tail_x15_r0_body.st78.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged78`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap78 : PRE_first_tail_x15_r0_body.s765.heap = PRE_first_tail_x15_r0_body.st78.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext78 : PRE_first_tail_x15_r0_body.s765.next = PRE_first_tail_x15_r0_body.st78.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl78 : PRE_first_tail_x15_r0_body.s765.ctl = PRE_first_tail_x15_r0_body.st78.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack78 : PRE_first_tail_x15_r0_body.s765.stack = PRE_first_tail_x15_r0_body.st78.s5.stack ++ PRE_first_tail_x15_r0_body.s764.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs78 : PRE_first_tail_x15_r0_body.s765.jobs = PRE_first_tail_x15_r0_body.st78.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi78 : PRE_first_tail_x15_r0_body.s765.ffi = PRE_first_tail_x15_r0_body.st78.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace78 : PRE_first_tail_x15_r0_body.s765.trace = PRE_first_tail_x15_r0_body.st78.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores78 : PRE_first_tail_x15_r0_body.s765.stores = PRE_first_tail_x15_r0_body.st78.s5.stores

end Host.Load.Run.Tpl
