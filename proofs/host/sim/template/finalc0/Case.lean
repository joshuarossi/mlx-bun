import host.sim.template.finalc0.Run
import host.sim.template.finalc0.Base
import host.sim.template.base.Facts
import host.sim.LoopFinal
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `FINALC0` as a checked final case (`Host.Ts.Sim.FinalCase`): segment A
(`FINALC0.runA`, 1080 steps checked with `ok`) to `FINALC0.s1`, the step to the epilogue
spread `FINALC0.s2` (`FINALC0.stepA`; `ok` rejects the spread's state), its step
(`FINALC0.stepB`), and segment B (`FINALC0.runB`, 495 steps checked with `FINALC0.okB`, which
frames the spread's new array 3123642) to the halt `FINALC0.s4`. -/

kernel_rfl FINALC0.start : FINALC0.s0 = finalStart Base.s0 Base.S0.tab.length
kernel_rfl FINALC0.okA0 : ok FINALC0.s0 FINALC0.S0 = true
kernel_rfl FINALC0.okP : ok FINALC0.s1 FINALC0.S1 = true
kernel_rfl FINALC0.haltP : isHalt FINALC0.s1.ctl = false
kernel_rfl FINALC0.ctlA : FINALC0.s2.ctl = .ret (.obj 2673447)

/-- The spread frame's accumulator, environment and the frames below it. -/
noncomputable def FINALC0.accA : List Val := match FINALC0.s2.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def FINALC0.envA : Env := match FINALC0.s2.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FINALC0.fsA : List Frame := match FINALC0.s2.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl FINALC0.stackA : FINALC0.s2.stack = .l (.spread FINALC0.accA [] FINALC0.envA) :: FINALC0.fsA
kernel_rfl FINALC0.roomA_check : Nat.blt (FINALC0.s2.next + margin) Sim.bound = true
kernel_rfl FINALC0.arrA : (FINALC0.s2.heap.get aArrayProto).isSome = true
kernel_rfl FINALC0.newA : FINALC0.s2.next = 3123642
kernel_rfl FINALC0.okB0 : FINALC0.okB FINALC0.s3 FINALC0.S3 = true

/-- The halt's value. -/
noncomputable def FINALC0.vF : Val := match FINALC0.s4.ctl with
  | .halt (.normal v) => v
  | _ => .undef

kernel_rfl FINALC0.haltF : FINALC0.s4.ctl = .halt (.normal FINALC0.vF)
kernel_rfl FINALC0.emit_get : FINALC0.s4.heap.get 12502 = some (.obj (objOf FINALC0.s4 12502))
kernel_rfl FINALC0.emit_kind :
  (objOf FINALC0.s4 12502).kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79), .num (.ref Base.S0.tab.length)])
kernel_rfl FINALC0.cell : FINALC0.s4.cell? 2590 = some (some (.obj 12502))

theorem FINALC0.aN_ne : 3123642 ≠ 2673447 ∧ 3123642 ≠ 12502 := by decide

noncomputable def FINALC0.finalCase : FinalCase ok FINALC0.okB Base.s0 Base.S0.tab 2590 3123642 where
  S0 := FINALC0.S0
  tab := FINALC0.S0_tab
  nA := 1080
  sP := FINALC0.s1
  SP := FINALC0.S1
  okA0 := by rw [← FINALC0.start]; exact FINALC0.okA0
  runA := by rw [← FINALC0.start]; exact FINALC0.runA
  okP := FINALC0.okP
  haltP := FINALC0.haltP
  sA := FINALC0.s2
  SA := FINALC0.S2
  stepA := FINALC0.stepA
  acc := FINALC0.accA
  env := FINALC0.envA
  fs := FINALC0.fsA
  ctlA := FINALC0.ctlA
  stackA := FINALC0.stackA
  roomA := Nat.le_of_ble_eq_true FINALC0.roomA_check
  arrA := FINALC0.arrA
  newA := FINALC0.newA
  sB := FINALC0.s3
  SB := FINALC0.S3
  stepB := FINALC0.stepB
  okB0 := FINALC0.okB0
  nB := 495
  sF := FINALC0.s4
  SF := FINALC0.S4
  runB := FINALC0.runB
  halt := ⟨_, FINALC0.haltF⟩
  emitG := ⟨_, FINALC0.emit_get, FINALC0.emit_kind⟩
  cell := FINALC0.cell

end Host.Load.Run.Tpl
