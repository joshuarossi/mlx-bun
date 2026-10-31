import host.sim.template.a4pre_setup_early_r0.st0.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 0 of chain `PRE_setup_early_r0`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_setup_early_r0.wrNodupB0 : nodupT PRE_setup_early_r0.st0.wr PTrie.nil = true
theorem PRE_setup_early_r0.wrNodup0 : PRE_setup_early_r0.st0.wr.Nodup := (nodupT_sound PRE_setup_early_r0.wrNodupB0).2
kernel_rfl PRE_setup_early_r0.wrBoundB0 : PRE_setup_early_r0.st0.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_setup_early_r0.wrBound0 : ∀ b ∈ PRE_setup_early_r0.st0.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_setup_early_r0.wrBoundB0 b hb)
noncomputable def PRE_setup_early_r0.trFr0 := PRE_setup_early_r0.st0.s2.trace.take 0
kernel_rfl PRE_setup_early_r0.traceEq0 : PRE_setup_early_r0.st0.s2.trace = PRE_setup_early_r0.trFr0 ++ PRE_setup_early_r0.st0.s0.trace
theorem PRE_setup_early_r0.trace0 : ∃ fr, PRE_setup_early_r0.st0.s2.trace = fr ++ PRE_setup_early_r0.st0.s0.trace := ⟨_, PRE_setup_early_r0.traceEq0⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_setup_early_r0.wide0 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_setup_early_r0.wfixB0 : (PRE_setup_early_r0.wide0.all fun p => wfixB Map.id (presentB PRE_setup_early_r0.st0.s0) p.2) = true
theorem PRE_setup_early_r0.wfix0 : ∀ p ∈ PRE_setup_early_r0.wide0, WFix Map.id (Present PRE_setup_early_r0.st0.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_setup_early_r0.wfixB0 p hp)

end Host.Load.Run.Tpl
