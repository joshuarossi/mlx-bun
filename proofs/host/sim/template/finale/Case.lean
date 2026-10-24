import host.sim.template.finale.Run
import host.sim.template.base.Facts
import host.sim.LoopExit
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `FINALE` as a checked EOS final case (`Host.Ts.Sim.ExitCase` from the final start): segment A
(`FINALE.runA`, 888 steps checked with `ok`) to `FINALE.s1`, the step to the epilogue
spread `FINALE.s2` (`FINALE.stepA`; `ok` rejects the spread's state), its step
(`FINALE.stepB`), and segment B (`FINALE.runB`, 495 steps checked with `FINALE.okB`, which
frames the spread's new array 3123626) to the halt `FINALE.s4`. The halt's `emitted` array appends
the cut's token only: the look-ahead token is EOS. -/

kernel_rfl FINALE.S0_tab : FINALE.S0.tab = Base.S0.tab ++ [.var 17]
kernel_rfl FINALE.start : FINALE.s0 = finalStart Base.s0 Base.S0.tab.length
kernel_rfl FINALE.okA0 : ok FINALE.s0 FINALE.S0 = true
kernel_rfl FINALE.okP : ok FINALE.s1 FINALE.S1 = true
kernel_rfl FINALE.haltP : isHalt FINALE.s1.ctl = false
kernel_rfl FINALE.ctlA : FINALE.s2.ctl = .ret (.obj 2673447)

/-- The spread frame's accumulator, environment and the frames below it. -/
noncomputable def FINALE.accA : List Val := match FINALE.s2.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def FINALE.envA : Env := match FINALE.s2.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FINALE.fsA : List Frame := match FINALE.s2.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl FINALE.stackA : FINALE.s2.stack = .l (.spread FINALE.accA [] FINALE.envA) :: FINALE.fsA
kernel_rfl FINALE.roomA_check : Nat.blt (FINALE.s2.next + margin) Sim.bound = true
kernel_rfl FINALE.arrA : (FINALE.s2.heap.get aArrayProto).isSome = true
kernel_rfl FINALE.newA : FINALE.s2.next = 3123626
kernel_rfl FINALE.okB0 : FINALE.okB FINALE.s3 FINALE.S3 = true

/-- The halt's value. -/
noncomputable def FINALE.vF : Val := match FINALE.s4.ctl with
  | .halt (.normal v) => v
  | _ => .undef

kernel_rfl FINALE.haltF : FINALE.s4.ctl = .halt (.normal FINALE.vF)
kernel_rfl FINALE.emit_get : FINALE.s4.heap.get 12502 = some (.obj (objOf FINALE.s4 12502))
kernel_rfl FINALE.emit_kind :
  (objOf FINALE.s4 12502).kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79)])
kernel_rfl FINALE.cell : FINALE.s4.cell? 2590 = some (some (.obj 12502))

theorem FINALE.aN_ne : 3123626 ≠ 2673447 ∧ 3123626 ≠ 12502 := by decide

noncomputable def FINALE.exitCase :
    ExitCase ok FINALE.okB Base.s0 (finalStart Base.s0 Base.S0.tab.length) (Base.S0.tab ++ [.var 17]) 2590 3123626
      [.num (.ref 79)] where
  S0 := FINALE.S0
  tab := FINALE.S0_tab
  nA := 888
  sP := FINALE.s1
  SP := FINALE.S1
  okA0 := by rw [← FINALE.start]; exact FINALE.okA0
  runA := by rw [← FINALE.start]; exact FINALE.runA
  okP := FINALE.okP
  haltP := FINALE.haltP
  sA := FINALE.s2
  SA := FINALE.S2
  stepA := FINALE.stepA
  acc := FINALE.accA
  env := FINALE.envA
  fs := FINALE.fsA
  ctlA := FINALE.ctlA
  stackA := FINALE.stackA
  roomA := Nat.le_of_ble_eq_true FINALE.roomA_check
  arrA := FINALE.arrA
  newA := FINALE.newA
  sB := FINALE.s3
  SB := FINALE.S3
  stepB := FINALE.stepB
  okB0 := FINALE.okB0
  nB := 495
  sF := FINALE.s4
  SF := FINALE.S4
  runB := FINALE.runB
  halt := ⟨_, FINALE.haltF⟩
  emitG := ⟨_, FINALE.emit_get, FINALE.emit_kind⟩
  cell := FINALE.cell

end Host.Load.Run.Tpl
