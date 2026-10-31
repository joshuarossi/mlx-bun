import host.sim.template.a4pre_setup_h4_chunk.st0.Run
import host.sim.StageRel
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Stage `PRE_setup_h4_chunk.st0` (chunk: `chunkSize`) as a stage template: the isolated call state `PRE_setup_h4_chunk.st0.s0`, the checked
local run (`PRE_setup_h4_chunk.st0.run`, 28526 steps with `PRE_setup_h4_chunk.st0.okL`) to `PRE_setup_h4_chunk.st0.s3` and the return step (`PRE_setup_h4_chunk.st0.last`)
to `PRE_setup_h4_chunk.st0.s4`. Its variables (the stage specs' map): `9` L. -/

kernel_rfl PRE_setup_h4_chunk.st0.ok0 : PRE_setup_h4_chunk.st0.okL PRE_setup_h4_chunk.st0.s0 PRE_setup_h4_chunk.st0.S0 = true
kernel_rfl PRE_setup_h4_chunk.st0.ok1 : PRE_setup_h4_chunk.st0.okL PRE_setup_h4_chunk.st0.s3 PRE_setup_h4_chunk.st0.S3 = true
kernel_rfl PRE_setup_h4_chunk.st0.halt1 : isHalt PRE_setup_h4_chunk.st0.s3.ctl = false
kernel_rfl PRE_setup_h4_chunk.st0.top_check : noBlockTop PRE_setup_h4_chunk.st0.s4.stack = true

theorem PRE_setup_h4_chunk.st0.loc : ∀ s Sv, PRE_setup_h4_chunk.st0.okL s Sv = true → Disp.localB s = true := okLocal_localB

/-- The stage template. -/
noncomputable def PRE_setup_h4_chunk.st0.tpl : Host.Ts.Sim.Stage.StageTpl PRE_setup_h4_chunk.st0.F PRE_setup_h4_chunk.st0.okL where
  s0 := PRE_setup_h4_chunk.st0.s0
  S0 := PRE_setup_h4_chunk.st0.S0
  s1 := PRE_setup_h4_chunk.st0.s3
  S1 := PRE_setup_h4_chunk.st0.S3
  s2 := PRE_setup_h4_chunk.st0.s4
  S2 := PRE_setup_h4_chunk.st0.S4
  n := 28526
  ok0 := PRE_setup_h4_chunk.st0.ok0
  run := PRE_setup_h4_chunk.st0.run
  ok1 := PRE_setup_h4_chunk.st0.ok1
  halt := PRE_setup_h4_chunk.st0.halt1
  last := PRE_setup_h4_chunk.st0.last
  top := noBlockTop_sound PRE_setup_h4_chunk.st0.top_check

end Host.Load.Run.Tpl
