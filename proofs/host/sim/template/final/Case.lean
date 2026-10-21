import host.sim.template.final.Run
import host.sim.template.final.Base
import host.sim.template.base.Facts
import host.sim.LoopFinal
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `FINAL` as a checked final case (`Host.Ts.Sim.FinalCase`): segment A
(`FINAL.runA`, 1064 steps checked with `ok`) to `FINAL.s1`, the step to the epilogue
spread `FINAL.s2` (`FINAL.stepA`; `ok` rejects the spread's state), its step
(`FINAL.stepB`), and segment B (`FINAL.runB`, 495 steps checked with `FINAL.okB`, which
frames the spread's new array 3123641) to the halt `FINAL.s4`. -/

kernel_rfl FINAL.start : FINAL.s0 = finalStart Base.s0 Base.S0.tab.length
kernel_rfl FINAL.okA0 : ok FINAL.s0 FINAL.S0 = true
kernel_rfl FINAL.okP : ok FINAL.s1 FINAL.S1 = true
kernel_rfl FINAL.haltP : isHalt FINAL.s1.ctl = false
kernel_rfl FINAL.ctlA : FINAL.s2.ctl = .ret (.obj 2673447)

/-- The spread frame's accumulator, environment and the frames below it. -/
noncomputable def FINAL.accA : List Val := match FINAL.s2.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def FINAL.envA : Env := match FINAL.s2.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FINAL.fsA : List Frame := match FINAL.s2.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl FINAL.stackA : FINAL.s2.stack = .l (.spread FINAL.accA [] FINAL.envA) :: FINAL.fsA
kernel_rfl FINAL.roomA_check : Nat.blt (FINAL.s2.next + margin) Sim.bound = true
kernel_rfl FINAL.arrA : (FINAL.s2.heap.get aArrayProto).isSome = true
kernel_rfl FINAL.newA : FINAL.s2.next = 3123641
kernel_rfl FINAL.okB0 : FINAL.okB FINAL.s3 FINAL.S3 = true

/-- The halt's value. -/
noncomputable def FINAL.vF : Val := match FINAL.s4.ctl with
  | .halt (.normal v) => v
  | _ => .undef

kernel_rfl FINAL.haltF : FINAL.s4.ctl = .halt (.normal FINAL.vF)
kernel_rfl FINAL.emit_get : FINAL.s4.heap.get 12502 = some (.obj (objOf FINAL.s4 12502))
kernel_rfl FINAL.emit_kind :
  (objOf FINAL.s4 12502).kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79), .num (.ref Base.S0.tab.length)])
kernel_rfl FINAL.cell : FINAL.s4.cell? 2590 = some (some (.obj 12502))

theorem FINAL.aN_ne : 3123641 ≠ 2673447 ∧ 3123641 ≠ 12502 := by decide

noncomputable def FINAL.finalCase : FinalCase ok FINAL.okB Base.s0 Base.S0.tab 2590 3123641 where
  S0 := FINAL.S0
  tab := FINAL.S0_tab
  nA := 1064
  sP := FINAL.s1
  SP := FINAL.S1
  okA0 := by rw [← FINAL.start]; exact FINAL.okA0
  runA := by rw [← FINAL.start]; exact FINAL.runA
  okP := FINAL.okP
  haltP := FINAL.haltP
  sA := FINAL.s2
  SA := FINAL.S2
  stepA := FINAL.stepA
  acc := FINAL.accA
  env := FINAL.envA
  fs := FINAL.fsA
  ctlA := FINAL.ctlA
  stackA := FINAL.stackA
  roomA := Nat.le_of_ble_eq_true FINAL.roomA_check
  arrA := FINAL.arrA
  newA := FINAL.newA
  sB := FINAL.s3
  SB := FINAL.S3
  stepB := FINAL.stepB
  okB0 := FINAL.okB0
  nB := 495
  sF := FINAL.s4
  SF := FINAL.S4
  runB := FINAL.runB
  halt := ⟨_, FINAL.haltF⟩
  emitG := ⟨_, FINAL.emit_get, FINAL.emit_kind⟩
  cell := FINAL.cell

end Host.Load.Run.Tpl
