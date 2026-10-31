import host.sim.template.a4pre_first_tail_x15_r0_body.st3.Run
import host.sim.StageRel
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Stage `PRE_first_tail_x15_r0_body.st3` (ssmW: `recurWindow`) as a stage template: the isolated call state `PRE_first_tail_x15_r0_body.st3.s0`, the checked
local run (`PRE_first_tail_x15_r0_body.st3.run`, 11334 steps with `PRE_first_tail_x15_r0_body.st3.okL`) to `PRE_first_tail_x15_r0_body.st3.s4` and the return step (`PRE_first_tail_x15_r0_body.st3.last`)
to `PRE_first_tail_x15_r0_body.st3.s5`. Its variables (the stage specs' map): `9` L, `10` n. -/

kernel_rfl PRE_first_tail_x15_r0_body.st3.ok0 : PRE_first_tail_x15_r0_body.st3.okL PRE_first_tail_x15_r0_body.st3.s0 PRE_first_tail_x15_r0_body.st3.S0 = true
kernel_rfl PRE_first_tail_x15_r0_body.st3.ok1 : PRE_first_tail_x15_r0_body.st3.okL PRE_first_tail_x15_r0_body.st3.s4 PRE_first_tail_x15_r0_body.st3.S4 = true
kernel_rfl PRE_first_tail_x15_r0_body.st3.halt1 : isHalt PRE_first_tail_x15_r0_body.st3.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st3.top_check : noBlockTop PRE_first_tail_x15_r0_body.st3.s5.stack = true

theorem PRE_first_tail_x15_r0_body.st3.loc : ∀ s Sv, PRE_first_tail_x15_r0_body.st3.okL s Sv = true → Disp.localB s = true := okLocal_localB

/-- The stage template. -/
noncomputable def PRE_first_tail_x15_r0_body.st3.tpl : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st3.F PRE_first_tail_x15_r0_body.st3.okL where
  s0 := PRE_first_tail_x15_r0_body.st3.s0
  S0 := PRE_first_tail_x15_r0_body.st3.S0
  s1 := PRE_first_tail_x15_r0_body.st3.s4
  S1 := PRE_first_tail_x15_r0_body.st3.S4
  s2 := PRE_first_tail_x15_r0_body.st3.s5
  S2 := PRE_first_tail_x15_r0_body.st3.S5
  n := 11334
  ok0 := PRE_first_tail_x15_r0_body.st3.ok0
  run := PRE_first_tail_x15_r0_body.st3.run
  ok1 := PRE_first_tail_x15_r0_body.st3.ok1
  halt := PRE_first_tail_x15_r0_body.st3.halt1
  last := PRE_first_tail_x15_r0_body.st3.last
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st3.top_check

end Host.Load.Run.Tpl
