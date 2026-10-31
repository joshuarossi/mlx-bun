import host.sim.template.a4pre_first_tail_x15_r0_body.st107.TypedLast
import host.sim.template.a4pre_first_tail_x15_r0_body.st107.TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st107.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st107.F (PRE_first_tail_x15_r0_body.st107.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st107.s0 PRE_first_tail_x15_r0_body.st107.S0 = some (PRE_first_tail_x15_r0_body.st107.s1, PRE_first_tail_x15_r0_body.st107.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st107.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st107.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st107.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st107.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st107.F (PRE_first_tail_x15_r0_body.st107.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st107.s0
  S0 := PRE_first_tail_x15_r0_body.st107.S0
  s1 := PRE_first_tail_x15_r0_body.st107.s1
  S1 := PRE_first_tail_x15_r0_body.st107.S1
  s2 := PRE_first_tail_x15_r0_body.st107.s2
  S2 := PRE_first_tail_x15_r0_body.st107.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st107.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st107.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st107.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st107.bodyHalt
  last := PRE_first_tail_x15_r0_body.st107.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st107.bodyTopCheck
end Host.Load.Run.Tpl
