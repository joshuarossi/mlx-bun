import host.sim.template.a4pre_first_tail_x15_r0_body.st138.Run
import host.sim.StageRel
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Stage `PRE_first_tail_x15_r0_body.st138` (ssmW: `recurWindow`) as a stage template: the isolated call state `PRE_first_tail_x15_r0_body.st138.s0`, the checked
local run (`PRE_first_tail_x15_r0_body.st138.run`, 11334 steps with `PRE_first_tail_x15_r0_body.st138.okL`) to `PRE_first_tail_x15_r0_body.st138.s4` and the return step (`PRE_first_tail_x15_r0_body.st138.last`)
to `PRE_first_tail_x15_r0_body.st138.s5`. Its variables (the stage specs' map): `9` L, `10` n. -/

kernel_rfl PRE_first_tail_x15_r0_body.st138.ok0 : PRE_first_tail_x15_r0_body.st138.okL PRE_first_tail_x15_r0_body.st138.s0 PRE_first_tail_x15_r0_body.st138.S0 = true
kernel_rfl PRE_first_tail_x15_r0_body.st138.ok1 : PRE_first_tail_x15_r0_body.st138.okL PRE_first_tail_x15_r0_body.st138.s4 PRE_first_tail_x15_r0_body.st138.S4 = true
kernel_rfl PRE_first_tail_x15_r0_body.st138.halt1 : isHalt PRE_first_tail_x15_r0_body.st138.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st138.top_check : noBlockTop PRE_first_tail_x15_r0_body.st138.s5.stack = true

theorem PRE_first_tail_x15_r0_body.st138.loc : ∀ s Sv, PRE_first_tail_x15_r0_body.st138.okL s Sv = true → Disp.localB s = true := okLocal_localB

/-- The stage template. -/
noncomputable def PRE_first_tail_x15_r0_body.st138.tpl : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st138.F PRE_first_tail_x15_r0_body.st138.okL where
  s0 := PRE_first_tail_x15_r0_body.st138.s0
  S0 := PRE_first_tail_x15_r0_body.st138.S0
  s1 := PRE_first_tail_x15_r0_body.st138.s4
  S1 := PRE_first_tail_x15_r0_body.st138.S4
  s2 := PRE_first_tail_x15_r0_body.st138.s5
  S2 := PRE_first_tail_x15_r0_body.st138.S5
  n := 11334
  ok0 := PRE_first_tail_x15_r0_body.st138.ok0
  run := PRE_first_tail_x15_r0_body.st138.run
  ok1 := PRE_first_tail_x15_r0_body.st138.ok1
  halt := PRE_first_tail_x15_r0_body.st138.halt1
  last := PRE_first_tail_x15_r0_body.st138.last
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st138.top_check

end Host.Load.Run.Tpl
