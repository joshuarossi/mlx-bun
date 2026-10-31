import host.sim.template.a4dec_fill.st0.Run
import host.sim.StageRel
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Stage `DEC_fill.st0` (rb: `itemUint32`) as a stage template: the isolated call state `DEC_fill.st0.s0`, the checked
local run (`DEC_fill.st0.run`, 123 steps with `DEC_fill.st0.okL`) to `DEC_fill.st0.s1` and the return step (`DEC_fill.st0.last`)
to `DEC_fill.st0.s2`. Its variables (the stage specs' map): `0` T, `9` o, `10` k, `11` k, `12` k, `13` kp, `14` t1, `16` cap. -/

kernel_rfl DEC_fill.st0.ok0 : DEC_fill.st0.okL DEC_fill.st0.s0 DEC_fill.st0.S0 = true
kernel_rfl DEC_fill.st0.ok1 : DEC_fill.st0.okL DEC_fill.st0.s1 DEC_fill.st0.S1 = true
kernel_rfl DEC_fill.st0.halt1 : isHalt DEC_fill.st0.s1.ctl = false
kernel_rfl DEC_fill.st0.top_check : noBlockTop DEC_fill.st0.s2.stack = true

theorem DEC_fill.st0.loc : ∀ s Sv, DEC_fill.st0.okL s Sv = true → Disp.localB s = true := okLocal_localB

/-- The stage template. -/
noncomputable def DEC_fill.st0.tpl : Host.Ts.Sim.Stage.StageTpl DEC_fill.st0.F DEC_fill.st0.okL where
  s0 := DEC_fill.st0.s0
  S0 := DEC_fill.st0.S0
  s1 := DEC_fill.st0.s1
  S1 := DEC_fill.st0.S1
  s2 := DEC_fill.st0.s2
  S2 := DEC_fill.st0.S2
  n := 123
  ok0 := DEC_fill.st0.ok0
  run := DEC_fill.st0.run
  ok1 := DEC_fill.st0.ok1
  halt := DEC_fill.st0.halt1
  last := DEC_fill.st0.last
  top := noBlockTop_sound DEC_fill.st0.top_check

end Host.Load.Run.Tpl
