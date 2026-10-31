import host.sim.template.a4pre_first_tail_x15_r0_body.st18.TypedLast
import host.sim.template.a4pre_first_tail_x15_r0_body.st18.TypedK0
import host.sim.template.a4pre_first_tail_x15_r0_body.st18.TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st18.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st18.F (PRE_first_tail_x15_r0_body.st18.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st18.s0 PRE_first_tail_x15_r0_body.st18.S0 = some (PRE_first_tail_x15_r0_body.st18.s2, PRE_first_tail_x15_r0_body.st18.S2) :=
  runOk_trans PRE_first_tail_x15_r0_body.st18.F (PRE_first_tail_x15_r0_body.st18.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st18.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st18.ks 1).getD 0) PRE_first_tail_x15_r0_body.st18.s0 PRE_first_tail_x15_r0_body.st18.s1 PRE_first_tail_x15_r0_body.st18.s2 PRE_first_tail_x15_r0_body.st18.S0 PRE_first_tail_x15_r0_body.st18.S1 PRE_first_tail_x15_r0_body.st18.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st18.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st18.bodyK1 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st18.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st18.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st18.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st18.F (PRE_first_tail_x15_r0_body.st18.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st18.s0
  S0 := PRE_first_tail_x15_r0_body.st18.S0
  s1 := PRE_first_tail_x15_r0_body.st18.s2
  S1 := PRE_first_tail_x15_r0_body.st18.S2
  s2 := PRE_first_tail_x15_r0_body.st18.s3
  S2 := PRE_first_tail_x15_r0_body.st18.S3
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st18.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st18.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st18.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st18.bodyHalt
  last := PRE_first_tail_x15_r0_body.st18.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st18.bodyTopCheck
end Host.Load.Run.Tpl
