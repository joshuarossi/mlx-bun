import host.sim.compose.a4b.x1.Base
import host.sim.template.a4pre_first_tail_x1_r0_suffix.m.B0
import host.sim.template.a4pre_first_tail_x1_r0_suffix.m.B3
import host.sim.compose.a4b.x1.B7
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B23
import host.sim.template.a4pre_first_tail_x1_r0_body.m.B00
import host.sim.lin.Table
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- The rows this chain serves. -/
def fwdRows : List Row := [first_tail_x1.r0]

/-- No canonical results: the body's end table is already de-canonicalized. -/
noncomputable def bodyΘ : List Nat × List SymE := ([], [])

kernel_rfl tokensEnd : (mlxOf PRE_first_tail_x1_r0_body.s1396.ffi).tokens = [.ref 1, .ref 2]

theorem bodyStartEq : (PRE_first_tail_x1_r0_suffix.s0 : St FF.S) = PRE_first_tail_x1_r0_body.s1396 := startEqOf tokensEnd PRE_first_tail_x1_r0_suffix.s0_tok

theorem bodyStartClean : Conv.JClean (⟨21969, 19057, 2824581, 7442⟩ : Conv.Cnt) PRE_first_tail_x1_r0_suffix.s0 := by
  rw [bodyStartEq]
  exact PRE_first_tail_x1_r0_body.gjcl64 (PRE_first_tail_x1_r0_body.cjcl63 Host.Ts.Sim.Compose.VWFirst.X1.bodyClean63)

kernel_rfl bodyJsEnd : PRE_first_tail_x1_r0_body.gjh64.all (noBigAtP (jsAboveB PRE_first_tail_x1_r0_body.s1387.next) PRE_first_tail_x1_r0_body.s1396) = true

theorem bodyStartJs : JsHeapAbove PRE_first_tail_x1_r0_body.s1387.next PRE_first_tail_x1_r0_suffix.s0 := by
  rw [bodyStartEq]
  exact Host.Ts.Sim.Compose.VWFirst.X1.bodyJs63.step (Nat.le_refl _)
    (Conv.heap_off_setAll PRE_first_tail_x1_r0_body.gjk64
      (fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x1_r0_body.gjbd64 b hb))) bodyJsEnd

kernel_rfl bodyEndBridge : bridgeOf PRE_first_tail_x1_r0_body.s1396.ffi = bridgeOf PRE_first_tail_x1_r0_body.s0.ffi

theorem bodyInactive0 : (bridgeOf PRE_first_tail_x1_r0_suffix.s0.ffi).active = false := by
  rw [bodyStartEq]
  exact (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyEndBridge).trans Host.Ts.Sim.Compose.VWFirst.X1.bodyInactive0

kernel_rfl bodyStart2665 : arrOf PRE_first_tail_x1_r0_suffix.s0 2665 = []
kernel_rfl bodyStartChunk : arrOf PRE_first_tail_x1_r0_suffix.s0 VWFrames.chunk = []

end Host.Ts.Sim.Compose.VWFirst.X1.Sfx
