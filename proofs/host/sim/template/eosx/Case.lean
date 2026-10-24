import host.sim.template.eosx.Run
import host.sim.template.base.Facts
import host.sim.LoopExit
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `EOSX` as a checked exit case (`Host.Ts.Sim.ExitCase`) from the template start
`Base.s0`: segment A (`EOSX.runA`, 341 steps checked with `ok`) to `EOSX.s1`, the step to the
epilogue spread `EOSX.s2` (`EOSX.stepA`; `ok` rejects the spread's state), its step
(`EOSX.stepB`), and segment B (`EOSX.runB`, 482 steps checked with `EOSX.okB`, which
frames the spread's new array 3123589) to the halt `EOSX.s4`. The halt's `emitted` array is the
template's: the EOS token is not yielded. -/

kernel_rfl EOSX.S0_tab : EOSX.S0.tab = Base.S0.tab
kernel_rfl EOSX.start : EOSX.s0 = Base.s0
kernel_rfl EOSX.okA0 : ok EOSX.s0 EOSX.S0 = true
kernel_rfl EOSX.okP : ok EOSX.s1 EOSX.S1 = true
kernel_rfl EOSX.haltP : isHalt EOSX.s1.ctl = false
kernel_rfl EOSX.ctlA : EOSX.s2.ctl = .ret (.obj 2673447)

/-- The spread frame's accumulator, environment and the frames below it. -/
noncomputable def EOSX.accA : List Val := match EOSX.s2.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def EOSX.envA : Env := match EOSX.s2.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def EOSX.fsA : List Frame := match EOSX.s2.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl EOSX.stackA : EOSX.s2.stack = .l (.spread EOSX.accA [] EOSX.envA) :: EOSX.fsA
kernel_rfl EOSX.roomA_check : Nat.blt (EOSX.s2.next + margin) Sim.bound = true
kernel_rfl EOSX.arrA : (EOSX.s2.heap.get aArrayProto).isSome = true
kernel_rfl EOSX.newA : EOSX.s2.next = 3123589
kernel_rfl EOSX.okB0 : EOSX.okB EOSX.s3 EOSX.S3 = true

/-- The halt's value. -/
noncomputable def EOSX.vF : Val := match EOSX.s4.ctl with
  | .halt (.normal v) => v
  | _ => .undef

kernel_rfl EOSX.haltF : EOSX.s4.ctl = .halt (.normal EOSX.vF)
kernel_rfl EOSX.emit_get : EOSX.s4.heap.get 12502 = some (.obj (objOf EOSX.s4 12502))
kernel_rfl EOSX.emit_kind : (objOf EOSX.s4 12502).kind = .array (arrOf Base.s0 12502 ++ [])
kernel_rfl EOSX.cell : EOSX.s4.cell? 2590 = some (some (.obj 12502))

theorem EOSX.aN_ne : 3123589 ≠ 2673447 ∧ 3123589 ≠ 12502 := by decide

noncomputable def EOSX.exitCase : ExitCase ok EOSX.okB Base.s0 Base.s0 Base.S0.tab 2590 3123589 [] where
  S0 := EOSX.S0
  tab := EOSX.S0_tab
  nA := 341
  sP := EOSX.s1
  SP := EOSX.S1
  okA0 := by rw [← EOSX.start]; exact EOSX.okA0
  runA := by rw [← EOSX.start]; exact EOSX.runA
  okP := EOSX.okP
  haltP := EOSX.haltP
  sA := EOSX.s2
  SA := EOSX.S2
  stepA := EOSX.stepA
  acc := EOSX.accA
  env := EOSX.envA
  fs := EOSX.fsA
  ctlA := EOSX.ctlA
  stackA := EOSX.stackA
  roomA := Nat.le_of_ble_eq_true EOSX.roomA_check
  arrA := EOSX.arrA
  newA := EOSX.newA
  sB := EOSX.s3
  SB := EOSX.S3
  stepB := EOSX.stepB
  okB0 := EOSX.okB0
  nB := 482
  sF := EOSX.s4
  SF := EOSX.S4
  runB := EOSX.runB
  halt := ⟨_, EOSX.haltF⟩
  emitG := ⟨_, EOSX.emit_get, EOSX.emit_kind⟩
  cell := EOSX.cell

end Host.Load.Run.Tpl
