import host.sim.template.a4pre_d1_stage_split.st0.Run
import host.sim.StageRel
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Stage `D1StageSplit.st0` (nps: `nextPrefillStep`) as a stage template: the isolated call state `D1StageSplit.st0.s0`, the checked
local run (`D1StageSplit.st0.run`, 179 steps with `D1StageSplit.st0.okL`) to `D1StageSplit.st0.s1` and the return step (`D1StageSplit.st0.last`)
to `D1StageSplit.st0.s2`. Its variables (the stage specs' map): `9` L. -/

kernel_rfl D1StageSplit.st0.ok0 : D1StageSplit.st0.okL D1StageSplit.st0.s0 D1StageSplit.st0.S0 = true
kernel_rfl D1StageSplit.st0.ok1 : D1StageSplit.st0.okL D1StageSplit.st0.s1 D1StageSplit.st0.S1 = true
kernel_rfl D1StageSplit.st0.halt1 : isHalt D1StageSplit.st0.s1.ctl = false
kernel_rfl D1StageSplit.st0.top_check : noBlockTop D1StageSplit.st0.s2.stack = true

theorem D1StageSplit.st0.loc : ∀ s Sv, D1StageSplit.st0.okL s Sv = true → Disp.localB s = true := okLocal_localB

/-- The stage template. -/
noncomputable def D1StageSplit.st0.tpl : Host.Ts.Sim.Stage.StageTpl D1StageSplit.st0.F D1StageSplit.st0.okL where
  s0 := D1StageSplit.st0.s0
  S0 := D1StageSplit.st0.S0
  s1 := D1StageSplit.st0.s1
  S1 := D1StageSplit.st0.S1
  s2 := D1StageSplit.st0.s2
  S2 := D1StageSplit.st0.S2
  n := 179
  ok0 := D1StageSplit.st0.ok0
  run := D1StageSplit.st0.run
  ok1 := D1StageSplit.st0.ok1
  halt := D1StageSplit.st0.halt1
  last := D1StageSplit.st0.last
  top := noBlockTop_sound D1StageSplit.st0.top_check

end Host.Load.Run.Tpl
