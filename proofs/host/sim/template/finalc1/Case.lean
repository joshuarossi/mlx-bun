import host.sim.template.finalc1.Run
import host.sim.template.finalc1.Base
import host.sim.template.base.Facts
import host.sim.LoopFinal
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `FINALC1` as a checked final case (`Host.Ts.Sim.FinalCase`): segment A
(`FINALC1.runA`, 1080 steps checked with `ok`) to `FINALC1.s1`, the step to the epilogue
spread `FINALC1.s2` (`FINALC1.stepA`; `ok` rejects the spread's state), its step
(`FINALC1.stepB`), and segment B (`FINALC1.runB`, 495 steps checked with `FINALC1.okB`, which
frames the spread's new array 3123642) to the halt `FINALC1.s4`. -/

kernel_rfl FINALC1.start : FINALC1.s0 = finalStart Base.s0 Base.S0.tab.length
kernel_rfl FINALC1.okA0 : ok FINALC1.s0 FINALC1.S0 = true
kernel_rfl FINALC1.okP : ok FINALC1.s1 FINALC1.S1 = true
kernel_rfl FINALC1.haltP : isHalt FINALC1.s1.ctl = false
kernel_rfl FINALC1.ctlA : FINALC1.s2.ctl = .ret (.obj 2673447)

/-- The spread frame's accumulator, environment and the frames below it. -/
noncomputable def FINALC1.accA : List Val := match FINALC1.s2.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def FINALC1.envA : Env := match FINALC1.s2.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FINALC1.fsA : List Frame := match FINALC1.s2.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl FINALC1.stackA : FINALC1.s2.stack = .l (.spread FINALC1.accA [] FINALC1.envA) :: FINALC1.fsA
kernel_rfl FINALC1.roomA_check : Nat.blt (FINALC1.s2.next + margin) Sim.bound = true
kernel_rfl FINALC1.arrA : (FINALC1.s2.heap.get aArrayProto).isSome = true
kernel_rfl FINALC1.newA : FINALC1.s2.next = 3123642
kernel_rfl FINALC1.okB0 : FINALC1.okB FINALC1.s3 FINALC1.S3 = true

/-- The halt's value. -/
noncomputable def FINALC1.vF : Val := match FINALC1.s4.ctl with
  | .halt (.normal v) => v
  | _ => .undef

kernel_rfl FINALC1.haltF : FINALC1.s4.ctl = .halt (.normal FINALC1.vF)
kernel_rfl FINALC1.emit_get : FINALC1.s4.heap.get 12502 = some (.obj (objOf FINALC1.s4 12502))
kernel_rfl FINALC1.emit_kind :
  (objOf FINALC1.s4 12502).kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79), .num (.ref Base.S0.tab.length)])
kernel_rfl FINALC1.cell : FINALC1.s4.cell? 2590 = some (some (.obj 12502))

theorem FINALC1.aN_ne : 3123642 ≠ 2673447 ∧ 3123642 ≠ 12502 := by decide

noncomputable def FINALC1.finalCase : FinalCase ok FINALC1.okB Base.s0 Base.S0.tab 2590 3123642 where
  S0 := FINALC1.S0
  tab := FINALC1.S0_tab
  nA := 1080
  sP := FINALC1.s1
  SP := FINALC1.S1
  okA0 := by rw [← FINALC1.start]; exact FINALC1.okA0
  runA := by rw [← FINALC1.start]; exact FINALC1.runA
  okP := FINALC1.okP
  haltP := FINALC1.haltP
  sA := FINALC1.s2
  SA := FINALC1.S2
  stepA := FINALC1.stepA
  acc := FINALC1.accA
  env := FINALC1.envA
  fs := FINALC1.fsA
  ctlA := FINALC1.ctlA
  stackA := FINALC1.stackA
  roomA := Nat.le_of_ble_eq_true FINALC1.roomA_check
  arrA := FINALC1.arrA
  newA := FINALC1.newA
  sB := FINALC1.s3
  SB := FINALC1.S3
  stepB := FINALC1.stepB
  okB0 := FINALC1.okB0
  nB := 495
  sF := FINALC1.s4
  SF := FINALC1.S4
  runB := FINALC1.runB
  halt := ⟨_, FINALC1.haltF⟩
  emitG := ⟨_, FINALC1.emit_get, FINALC1.emit_kind⟩
  cell := FINALC1.cell

end Host.Load.Run.Tpl
