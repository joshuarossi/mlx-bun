import host.sim.template.a4pre_first_tail_x15_r0_body.st48.TypedLast
import host.sim.template.a4pre_first_tail_x15_r0_body.st48.TypedK0
import host.sim.template.a4pre_first_tail_x15_r0_body.st48.TypedK1
import host.sim.template.a4pre_first_tail_x15_r0_body.st48.TypedK2
import host.sim.template.a4pre_first_tail_x15_r0_body.st48.TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st48.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.S0 = some (PRE_first_tail_x15_r0_body.st48.s4, PRE_first_tail_x15_r0_body.st48.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st48.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st48.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st48.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st48.ks 3).getD 0) PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.s3 PRE_first_tail_x15_r0_body.st48.s4 PRE_first_tail_x15_r0_body.st48.S0 PRE_first_tail_x15_r0_body.st48.S3 PRE_first_tail_x15_r0_body.st48.S4 (runOk_trans PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st48.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st48.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st48.ks 2).getD 0) PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.s2 PRE_first_tail_x15_r0_body.st48.s3 PRE_first_tail_x15_r0_body.st48.S0 PRE_first_tail_x15_r0_body.st48.S2 PRE_first_tail_x15_r0_body.st48.S3 (runOk_trans PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st48.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st48.ks 1).getD 0) PRE_first_tail_x15_r0_body.st48.s0 PRE_first_tail_x15_r0_body.st48.s1 PRE_first_tail_x15_r0_body.st48.s2 PRE_first_tail_x15_r0_body.st48.S0 PRE_first_tail_x15_r0_body.st48.S1 PRE_first_tail_x15_r0_body.st48.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st48.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st48.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st48.s0
  S0 := PRE_first_tail_x15_r0_body.st48.S0
  s1 := PRE_first_tail_x15_r0_body.st48.s4
  S1 := PRE_first_tail_x15_r0_body.st48.S4
  s2 := PRE_first_tail_x15_r0_body.st48.s5
  S2 := PRE_first_tail_x15_r0_body.st48.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st48.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st48.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st48.bodyHalt
  last := PRE_first_tail_x15_r0_body.st48.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st48.bodyTopCheck
end Host.Load.Run.Tpl
