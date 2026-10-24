import host.sim.template.finalec0.Run
import host.sim.template.base.Facts
import host.sim.LoopExit
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Case `FINALEC0` as a checked EOS final case (`Host.Ts.Sim.ExitCase` from the final start): segment A
(`FINALEC0.runA`, 904 steps checked with `ok`) to `FINALEC0.s1`, the step to the epilogue
spread `FINALEC0.s2` (`FINALEC0.stepA`; `ok` rejects the spread's state), its step
(`FINALEC0.stepB`), and segment B (`FINALEC0.runB`, 495 steps checked with `FINALEC0.okB`, which
frames the spread's new array 3123627) to the halt `FINALEC0.s4`. The halt's `emitted` array appends
the cut's token only: the look-ahead token is EOS. -/

kernel_rfl FINALEC0.S0_tab : FINALEC0.S0.tab = Base.S0.tab ++ [.var 17]
kernel_rfl FINALEC0.start : FINALEC0.s0 = finalStart Base.s0 Base.S0.tab.length
kernel_rfl FINALEC0.okA0 : ok FINALEC0.s0 FINALEC0.S0 = true
kernel_rfl FINALEC0.okP : ok FINALEC0.s1 FINALEC0.S1 = true
kernel_rfl FINALEC0.haltP : isHalt FINALEC0.s1.ctl = false
kernel_rfl FINALEC0.ctlA : FINALEC0.s2.ctl = .ret (.obj 2673447)

/-- The spread frame's accumulator, environment and the frames below it. -/
noncomputable def FINALEC0.accA : List Val := match FINALEC0.s2.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def FINALEC0.envA : Env := match FINALEC0.s2.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def FINALEC0.fsA : List Frame := match FINALEC0.s2.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl FINALEC0.stackA : FINALEC0.s2.stack = .l (.spread FINALEC0.accA [] FINALEC0.envA) :: FINALEC0.fsA
kernel_rfl FINALEC0.roomA_check : Nat.blt (FINALEC0.s2.next + margin) Sim.bound = true
kernel_rfl FINALEC0.arrA : (FINALEC0.s2.heap.get aArrayProto).isSome = true
kernel_rfl FINALEC0.newA : FINALEC0.s2.next = 3123627
kernel_rfl FINALEC0.okB0 : FINALEC0.okB FINALEC0.s3 FINALEC0.S3 = true

/-- The halt's value. -/
noncomputable def FINALEC0.vF : Val := match FINALEC0.s4.ctl with
  | .halt (.normal v) => v
  | _ => .undef

kernel_rfl FINALEC0.haltF : FINALEC0.s4.ctl = .halt (.normal FINALEC0.vF)
kernel_rfl FINALEC0.emit_get : FINALEC0.s4.heap.get 12502 = some (.obj (objOf FINALEC0.s4 12502))
kernel_rfl FINALEC0.emit_kind :
  (objOf FINALEC0.s4 12502).kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79)])
kernel_rfl FINALEC0.cell : FINALEC0.s4.cell? 2590 = some (some (.obj 12502))

theorem FINALEC0.aN_ne : 3123627 ≠ 2673447 ∧ 3123627 ≠ 12502 := by decide

noncomputable def FINALEC0.exitCase :
    ExitCase ok FINALEC0.okB Base.s0 (finalStart Base.s0 Base.S0.tab.length) (Base.S0.tab ++ [.var 17]) 2590 3123627
      [.num (.ref 79)] where
  S0 := FINALEC0.S0
  tab := FINALEC0.S0_tab
  nA := 904
  sP := FINALEC0.s1
  SP := FINALEC0.S1
  okA0 := by rw [← FINALEC0.start]; exact FINALEC0.okA0
  runA := by rw [← FINALEC0.start]; exact FINALEC0.runA
  okP := FINALEC0.okP
  haltP := FINALEC0.haltP
  sA := FINALEC0.s2
  SA := FINALEC0.S2
  stepA := FINALEC0.stepA
  acc := FINALEC0.accA
  env := FINALEC0.envA
  fs := FINALEC0.fsA
  ctlA := FINALEC0.ctlA
  stackA := FINALEC0.stackA
  roomA := Nat.le_of_ble_eq_true FINALEC0.roomA_check
  arrA := FINALEC0.arrA
  newA := FINALEC0.newA
  sB := FINALEC0.s3
  SB := FINALEC0.S3
  stepB := FINALEC0.stepB
  okB0 := FINALEC0.okB0
  nB := 495
  sF := FINALEC0.s4
  SF := FINALEC0.S4
  runB := FINALEC0.runB
  halt := ⟨_, FINALEC0.haltF⟩
  emitG := ⟨_, FINALEC0.emit_get, FINALEC0.emit_kind⟩
  cell := FINALEC0.cell

end Host.Load.Run.Tpl
