import host.sim.template.a4pre_first_tail_x15_r0_body.H15
import host.sim.template.a4pre_first_tail_x15_r0_body.st51.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 51 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g51__g52` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s505`, the merged state `PRE_first_tail_x15_r0_body.s506`,
the site template `PRE_first_tail_x15_r0_body.st51` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s507`: the merge.
The footprint's facts are in `SiteF51`, the compaction's in `SiteC51`, `SiteK51`, `SiteNa51`, `SiteNb51`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso51 : PRE_first_tail_x15_r0_body.st51.s0 = { PRE_first_tail_x15_r0_body.s505 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs51 : List Frame := PRE_first_tail_x15_r0_body.s505.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_51 : PRE_first_tail_x15_r0_body.S505.tab.length = 2264
kernel_rfl PRE_first_tail_x15_r0_body.tab0_51 : PRE_first_tail_x15_r0_body.st51.S0.tab = PRE_first_tail_x15_r0_body.S505.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws51 : List Nat := [1856, 1857, 1858, 1859, 1860, 1861, 1862, 1863, 1864, 1865, 1866, 1867, 1868, 1869, 1870, 1871, 1872, 1873, 1874, 1875, 1876, 1877, 1878, 1879, 1880, 1881, 1882, 1883, 1884, 1885, 1886]
kernel_rfl PRE_first_tail_x15_r0_body.fresh51 : (PRE_first_tail_x15_r0_body.S505.tab.all fun e => PRE_first_tail_x15_r0_body.ws51.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S505.oracle.all fun q => PRE_first_tail_x15_r0_body.ws51.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab51 : PRE_first_tail_x15_r0_body.S506.tab = PRE_first_tail_x15_r0_body.S505.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws51
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen51 : PRE_first_tail_x15_r0_body.st51.S5.tab.length - PRE_first_tail_x15_r0_body.st51.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged51`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap51 : PRE_first_tail_x15_r0_body.s506.heap = PRE_first_tail_x15_r0_body.st51.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext51 : PRE_first_tail_x15_r0_body.s506.next = PRE_first_tail_x15_r0_body.st51.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl51 : PRE_first_tail_x15_r0_body.s506.ctl = PRE_first_tail_x15_r0_body.st51.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack51 : PRE_first_tail_x15_r0_body.s506.stack = PRE_first_tail_x15_r0_body.st51.s5.stack ++ PRE_first_tail_x15_r0_body.s505.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs51 : PRE_first_tail_x15_r0_body.s506.jobs = PRE_first_tail_x15_r0_body.st51.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi51 : PRE_first_tail_x15_r0_body.s506.ffi = PRE_first_tail_x15_r0_body.st51.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace51 : PRE_first_tail_x15_r0_body.s506.trace = PRE_first_tail_x15_r0_body.st51.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores51 : PRE_first_tail_x15_r0_body.s506.stores = PRE_first_tail_x15_r0_body.st51.s5.stores

end Host.Load.Run.Tpl
