import host.sim.template.a4pre_first_tail_x15_r0_body.st17.Run
import host.sim.StageRel
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Stage `PRE_first_tail_x15_r0_body.st17` (plan: `plan`) as a stage template: the isolated call state `PRE_first_tail_x15_r0_body.st17.s0`, the checked
local run (`PRE_first_tail_x15_r0_body.st17.run`, 98 steps with `PRE_first_tail_x15_r0_body.st17.okL`) to `PRE_first_tail_x15_r0_body.st17.s1` and the return step (`PRE_first_tail_x15_r0_body.st17.last`)
to `PRE_first_tail_x15_r0_body.st17.s2`. Its variables (the stage specs' map): `9` L, `10` n. -/

kernel_rfl PRE_first_tail_x15_r0_body.st17.ok0 : PRE_first_tail_x15_r0_body.st17.okL PRE_first_tail_x15_r0_body.st17.s0 PRE_first_tail_x15_r0_body.st17.S0 = true
kernel_rfl PRE_first_tail_x15_r0_body.st17.ok1 : PRE_first_tail_x15_r0_body.st17.okL PRE_first_tail_x15_r0_body.st17.s1 PRE_first_tail_x15_r0_body.st17.S1 = true
kernel_rfl PRE_first_tail_x15_r0_body.st17.halt1 : isHalt PRE_first_tail_x15_r0_body.st17.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st17.top_check : noBlockTop PRE_first_tail_x15_r0_body.st17.s2.stack = true

theorem PRE_first_tail_x15_r0_body.st17.loc : ∀ s Sv, PRE_first_tail_x15_r0_body.st17.okL s Sv = true → Disp.localB s = true := okLocal_localB

/-- The stage template. -/
noncomputable def PRE_first_tail_x15_r0_body.st17.tpl : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st17.F PRE_first_tail_x15_r0_body.st17.okL where
  s0 := PRE_first_tail_x15_r0_body.st17.s0
  S0 := PRE_first_tail_x15_r0_body.st17.S0
  s1 := PRE_first_tail_x15_r0_body.st17.s1
  S1 := PRE_first_tail_x15_r0_body.st17.S1
  s2 := PRE_first_tail_x15_r0_body.st17.s2
  S2 := PRE_first_tail_x15_r0_body.st17.S2
  n := 98
  ok0 := PRE_first_tail_x15_r0_body.st17.ok0
  run := PRE_first_tail_x15_r0_body.st17.run
  ok1 := PRE_first_tail_x15_r0_body.st17.ok1
  halt := PRE_first_tail_x15_r0_body.st17.halt1
  last := PRE_first_tail_x15_r0_body.st17.last
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st17.top_check

end Host.Load.Run.Tpl
