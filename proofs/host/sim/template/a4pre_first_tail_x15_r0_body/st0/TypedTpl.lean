import host.sim.template.a4pre_first_tail_x15_r0_body.st0.TypedLast
import host.sim.template.a4pre_first_tail_x15_r0_body.st0.TypedK0
import host.sim.template.a4pre_first_tail_x15_r0_body.st0.TypedK1
import host.sim.template.a4pre_first_tail_x15_r0_body.st0.TypedK2
import host.sim.template.a4pre_first_tail_x15_r0_body.st0.TypedK3
import host.sim.template.a4pre_first_tail_x15_r0_body.st0.TypedK4
import host.sim.template.a4pre_first_tail_x15_r0_body.st0.TypedK5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st0.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st0.F (PRE_first_tail_x15_r0_body.st0.bodyOkL bytes rows) 17040 PRE_first_tail_x15_r0_body.st0.s0 PRE_first_tail_x15_r0_body.st0.S0 = some (PRE_first_tail_x15_r0_body.st0.s6, PRE_first_tail_x15_r0_body.st0.S6) :=
  runOk_trans PRE_first_tail_x15_r0_body.st0.F (PRE_first_tail_x15_r0_body.st0.bodyOkL bytes rows) ((((((nth? PRE_first_tail_x15_r0_body.st0.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st0.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st0.ks 2).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st0.ks 3).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st0.ks 4).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st0.ks 5).getD 0) PRE_first_tail_x15_r0_body.st0.s0 PRE_first_tail_x15_r0_body.st0.s5 PRE_first_tail_x15_r0_body.st0.s6 PRE_first_tail_x15_r0_body.st0.S0 PRE_first_tail_x15_r0_body.st0.S5 PRE_first_tail_x15_r0_body.st0.S6 (runOk_trans PRE_first_tail_x15_r0_body.st0.F (PRE_first_tail_x15_r0_body.st0.bodyOkL bytes rows) (((((nth? PRE_first_tail_x15_r0_body.st0.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st0.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st0.ks 2).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st0.ks 3).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st0.ks 4).getD 0) PRE_first_tail_x15_r0_body.st0.s0 PRE_first_tail_x15_r0_body.st0.s4 PRE_first_tail_x15_r0_body.st0.s5 PRE_first_tail_x15_r0_body.st0.S0 PRE_first_tail_x15_r0_body.st0.S4 PRE_first_tail_x15_r0_body.st0.S5 (runOk_trans PRE_first_tail_x15_r0_body.st0.F (PRE_first_tail_x15_r0_body.st0.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st0.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st0.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st0.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st0.ks 3).getD 0) PRE_first_tail_x15_r0_body.st0.s0 PRE_first_tail_x15_r0_body.st0.s3 PRE_first_tail_x15_r0_body.st0.s4 PRE_first_tail_x15_r0_body.st0.S0 PRE_first_tail_x15_r0_body.st0.S3 PRE_first_tail_x15_r0_body.st0.S4 (runOk_trans PRE_first_tail_x15_r0_body.st0.F (PRE_first_tail_x15_r0_body.st0.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st0.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st0.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st0.ks 2).getD 0) PRE_first_tail_x15_r0_body.st0.s0 PRE_first_tail_x15_r0_body.st0.s2 PRE_first_tail_x15_r0_body.st0.s3 PRE_first_tail_x15_r0_body.st0.S0 PRE_first_tail_x15_r0_body.st0.S2 PRE_first_tail_x15_r0_body.st0.S3 (runOk_trans PRE_first_tail_x15_r0_body.st0.F (PRE_first_tail_x15_r0_body.st0.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st0.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st0.ks 1).getD 0) PRE_first_tail_x15_r0_body.st0.s0 PRE_first_tail_x15_r0_body.st0.s1 PRE_first_tail_x15_r0_body.st0.s2 PRE_first_tail_x15_r0_body.st0.S0 PRE_first_tail_x15_r0_body.st0.S1 PRE_first_tail_x15_r0_body.st0.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st0.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st0.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st0.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st0.bodyK3 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st0.bodyK4 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st0.bodyK5 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st0.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st0.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st0.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st0.F (PRE_first_tail_x15_r0_body.st0.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st0.s0
  S0 := PRE_first_tail_x15_r0_body.st0.S0
  s1 := PRE_first_tail_x15_r0_body.st0.s6
  S1 := PRE_first_tail_x15_r0_body.st0.S6
  s2 := PRE_first_tail_x15_r0_body.st0.s7
  S2 := PRE_first_tail_x15_r0_body.st0.S7
  n := 17040
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st0.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st0.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st0.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st0.bodyHalt
  last := PRE_first_tail_x15_r0_body.st0.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st0.bodyTopCheck
end Host.Load.Run.Tpl
