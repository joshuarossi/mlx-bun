import host.sim.template.a4pre_first_tail_x15_r0_body.st12.TypedLast
import host.sim.template.a4pre_first_tail_x15_r0_body.st12.TypedK0
import host.sim.template.a4pre_first_tail_x15_r0_body.st12.TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st12.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st12.F (PRE_first_tail_x15_r0_body.st12.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st12.s0 PRE_first_tail_x15_r0_body.st12.S0 = some (PRE_first_tail_x15_r0_body.st12.s2, PRE_first_tail_x15_r0_body.st12.S2) :=
  runOk_trans PRE_first_tail_x15_r0_body.st12.F (PRE_first_tail_x15_r0_body.st12.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st12.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st12.ks 1).getD 0) PRE_first_tail_x15_r0_body.st12.s0 PRE_first_tail_x15_r0_body.st12.s1 PRE_first_tail_x15_r0_body.st12.s2 PRE_first_tail_x15_r0_body.st12.S0 PRE_first_tail_x15_r0_body.st12.S1 PRE_first_tail_x15_r0_body.st12.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st12.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st12.bodyK1 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st12.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st12.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st12.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st12.F (PRE_first_tail_x15_r0_body.st12.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st12.s0
  S0 := PRE_first_tail_x15_r0_body.st12.S0
  s1 := PRE_first_tail_x15_r0_body.st12.s2
  S1 := PRE_first_tail_x15_r0_body.st12.S2
  s2 := PRE_first_tail_x15_r0_body.st12.s3
  S2 := PRE_first_tail_x15_r0_body.st12.S3
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st12.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st12.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st12.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st12.bodyHalt
  last := PRE_first_tail_x15_r0_body.st12.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st12.bodyTopCheck
end Host.Load.Run.Tpl
