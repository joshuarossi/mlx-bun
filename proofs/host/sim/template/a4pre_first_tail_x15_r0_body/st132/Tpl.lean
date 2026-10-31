import host.sim.template.a4pre_first_tail_x15_r0_body.st132.Run
import host.sim.StageRel
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Stage `PRE_first_tail_x15_r0_body.st132` (ssmW: `recurWindow`) as a stage template: the isolated call state `PRE_first_tail_x15_r0_body.st132.s0`, the checked
local run (`PRE_first_tail_x15_r0_body.st132.run`, 11334 steps with `PRE_first_tail_x15_r0_body.st132.okL`) to `PRE_first_tail_x15_r0_body.st132.s2` and the return step (`PRE_first_tail_x15_r0_body.st132.last`)
to `PRE_first_tail_x15_r0_body.st132.s3`. Its variables (the stage specs' map): `9` L, `10` n. -/

kernel_rfl PRE_first_tail_x15_r0_body.st132.ok0 : PRE_first_tail_x15_r0_body.st132.okL PRE_first_tail_x15_r0_body.st132.s0 PRE_first_tail_x15_r0_body.st132.S0 = true
kernel_rfl PRE_first_tail_x15_r0_body.st132.ok1 : PRE_first_tail_x15_r0_body.st132.okL PRE_first_tail_x15_r0_body.st132.s2 PRE_first_tail_x15_r0_body.st132.S2 = true
kernel_rfl PRE_first_tail_x15_r0_body.st132.halt1 : isHalt PRE_first_tail_x15_r0_body.st132.s2.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st132.top_check : noBlockTop PRE_first_tail_x15_r0_body.st132.s3.stack = true

theorem PRE_first_tail_x15_r0_body.st132.loc : ∀ s Sv, PRE_first_tail_x15_r0_body.st132.okL s Sv = true → Disp.localB s = true := okLocal_localB

/-- The stage template. -/
noncomputable def PRE_first_tail_x15_r0_body.st132.tpl : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st132.F PRE_first_tail_x15_r0_body.st132.okL where
  s0 := PRE_first_tail_x15_r0_body.st132.s0
  S0 := PRE_first_tail_x15_r0_body.st132.S0
  s1 := PRE_first_tail_x15_r0_body.st132.s2
  S1 := PRE_first_tail_x15_r0_body.st132.S2
  s2 := PRE_first_tail_x15_r0_body.st132.s3
  S2 := PRE_first_tail_x15_r0_body.st132.S3
  n := 11334
  ok0 := PRE_first_tail_x15_r0_body.st132.ok0
  run := PRE_first_tail_x15_r0_body.st132.run
  ok1 := PRE_first_tail_x15_r0_body.st132.ok1
  halt := PRE_first_tail_x15_r0_body.st132.halt1
  last := PRE_first_tail_x15_r0_body.st132.last
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st132.top_check

end Host.Load.Run.Tpl
