import host.sim.template.a4pre_first_tail_x15_r0_body.H16
import host.sim.template.a4pre_first_tail_x15_r0_body.st54.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 54 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g54__g55` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s534`, the merged state `PRE_first_tail_x15_r0_body.s535`,
the site template `PRE_first_tail_x15_r0_body.st54` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s536`: the merge.
The footprint's facts are in `SiteF54`, the compaction's in `SiteC54`, `SiteK54`, `SiteNa54`, `SiteNb54`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso54 : PRE_first_tail_x15_r0_body.st54.s0 = { PRE_first_tail_x15_r0_body.s534 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs54 : List Frame := PRE_first_tail_x15_r0_body.s534.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_54 : PRE_first_tail_x15_r0_body.S534.tab.length = 2393
kernel_rfl PRE_first_tail_x15_r0_body.tab0_54 : PRE_first_tail_x15_r0_body.st54.S0.tab = PRE_first_tail_x15_r0_body.S534.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws54 : List Nat := [1916, 1917, 1918, 1919, 1920, 1921, 1922, 1923, 1924, 1925, 1926, 1927, 1928, 1929, 1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 1939, 1940, 1941, 1942, 1943, 1944, 1945, 1946]
kernel_rfl PRE_first_tail_x15_r0_body.fresh54 : (PRE_first_tail_x15_r0_body.S534.tab.all fun e => PRE_first_tail_x15_r0_body.ws54.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S534.oracle.all fun q => PRE_first_tail_x15_r0_body.ws54.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab54 : PRE_first_tail_x15_r0_body.S535.tab = PRE_first_tail_x15_r0_body.S534.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws54
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen54 : PRE_first_tail_x15_r0_body.st54.S5.tab.length - PRE_first_tail_x15_r0_body.st54.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged54`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap54 : PRE_first_tail_x15_r0_body.s535.heap = PRE_first_tail_x15_r0_body.st54.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext54 : PRE_first_tail_x15_r0_body.s535.next = PRE_first_tail_x15_r0_body.st54.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl54 : PRE_first_tail_x15_r0_body.s535.ctl = PRE_first_tail_x15_r0_body.st54.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack54 : PRE_first_tail_x15_r0_body.s535.stack = PRE_first_tail_x15_r0_body.st54.s5.stack ++ PRE_first_tail_x15_r0_body.s534.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs54 : PRE_first_tail_x15_r0_body.s535.jobs = PRE_first_tail_x15_r0_body.st54.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi54 : PRE_first_tail_x15_r0_body.s535.ffi = PRE_first_tail_x15_r0_body.st54.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace54 : PRE_first_tail_x15_r0_body.s535.trace = PRE_first_tail_x15_r0_body.st54.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores54 : PRE_first_tail_x15_r0_body.s535.stores = PRE_first_tail_x15_r0_body.st54.s5.stores

end Host.Load.Run.Tpl
