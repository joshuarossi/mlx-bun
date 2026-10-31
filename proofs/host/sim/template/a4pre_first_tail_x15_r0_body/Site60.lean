import host.sim.template.a4pre_first_tail_x15_r0_body.H18
import host.sim.template.a4pre_first_tail_x15_r0_body.st60.H0
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 60 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g60__g61` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s591`, the merged state `PRE_first_tail_x15_r0_body.s592`,
the site template `PRE_first_tail_x15_r0_body.st60` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s593`: the merge.
The footprint's facts are in `SiteF60`, the compaction's in `SiteC60`, `SiteK60`, `SiteNa60`, `SiteNb60`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso60 : PRE_first_tail_x15_r0_body.st60.s0 = { PRE_first_tail_x15_r0_body.s591 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs60 : List Frame := PRE_first_tail_x15_r0_body.s591.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_60 : PRE_first_tail_x15_r0_body.S591.tab.length = 2648
kernel_rfl PRE_first_tail_x15_r0_body.tab0_60 : PRE_first_tail_x15_r0_body.st60.S0.tab = PRE_first_tail_x15_r0_body.S591.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws60 : List Nat := [2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2035, 2036, 2037]
kernel_rfl PRE_first_tail_x15_r0_body.fresh60 : (PRE_first_tail_x15_r0_body.S591.tab.all fun e => PRE_first_tail_x15_r0_body.ws60.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S591.oracle.all fun q => PRE_first_tail_x15_r0_body.ws60.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab60 : PRE_first_tail_x15_r0_body.S592.tab = PRE_first_tail_x15_r0_body.S591.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws60
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen60 : PRE_first_tail_x15_r0_body.st60.S5.tab.length - PRE_first_tail_x15_r0_body.st60.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged60`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap60 : PRE_first_tail_x15_r0_body.s592.heap = PRE_first_tail_x15_r0_body.st60.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext60 : PRE_first_tail_x15_r0_body.s592.next = PRE_first_tail_x15_r0_body.st60.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl60 : PRE_first_tail_x15_r0_body.s592.ctl = PRE_first_tail_x15_r0_body.st60.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack60 : PRE_first_tail_x15_r0_body.s592.stack = PRE_first_tail_x15_r0_body.st60.s5.stack ++ PRE_first_tail_x15_r0_body.s591.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs60 : PRE_first_tail_x15_r0_body.s592.jobs = PRE_first_tail_x15_r0_body.st60.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi60 : PRE_first_tail_x15_r0_body.s592.ffi = PRE_first_tail_x15_r0_body.st60.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace60 : PRE_first_tail_x15_r0_body.s592.trace = PRE_first_tail_x15_r0_body.st60.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores60 : PRE_first_tail_x15_r0_body.s592.stores = PRE_first_tail_x15_r0_body.st60.s5.stores

end Host.Load.Run.Tpl
