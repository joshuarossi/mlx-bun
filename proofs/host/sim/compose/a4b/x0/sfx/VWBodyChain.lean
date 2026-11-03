import host.sim.compose.a4b.x0.Base
import host.sim.template.a4pre_first_tail_x0_r0_suffix.m.B0
import host.sim.template.a4pre_first_tail_x0_r0_suffix.m.B3
import host.sim.compose.a4b.x0.sfx.VWBodyJsP7
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B27
import host.sim.template.a4pre_first_tail_x0_r0_body.m.B00
import host.sim.lin.Table
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X0.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- The rows this chain serves. -/
def fwdRows : List Row := [first_tail_x0.r0]

/-- No canonical results: the body's end table is already de-canonicalized. -/
noncomputable def bodyΘ : List Nat × List SymE := ([], [])

kernel_rfl tokensEnd : (mlxOf PRE_first_tail_x0_r0_body.s906.ffi).tokens = [.ref 1, .ref 2]

theorem bodyStartEq : (PRE_first_tail_x0_r0_suffix.s0 : St FF.S) = PRE_first_tail_x0_r0_body.s906 := startEqOf tokensEnd PRE_first_tail_x0_r0_suffix.s0_tok

theorem bodyStartClean : Conv.JClean (⟨21986, 17764, 2826749, 15⟩ : Conv.Cnt) PRE_first_tail_x0_r0_suffix.s0 := by
  rw [bodyStartEq]
  exact PRE_first_tail_x0_r0_body.gjcl0 Host.Ts.Sim.Compose.VWFirst.X0.bodyStartClean

theorem bodyStartJs : JsHeapAbove PRE_first_tail_x0_r0_body.s906.next PRE_first_tail_x0_r0_suffix.s0 := by
  rw [bodyStartEq]
  exact bodyJsPAt7

kernel_rfl bodyEndBridge : bridgeOf PRE_first_tail_x0_r0_body.s906.ffi = bridgeOf PRE_first_tail_x0_r0_body.s0.ffi

theorem bodyInactive0 : (bridgeOf PRE_first_tail_x0_r0_suffix.s0.ffi).active = false := by
  rw [bodyStartEq]
  exact (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyEndBridge).trans Host.Ts.Sim.Compose.VWFirst.X0.bodyInactive0

kernel_rfl bodyStart2665 : arrOf PRE_first_tail_x0_r0_suffix.s0 2665 = []
kernel_rfl bodyStartChunk : arrOf PRE_first_tail_x0_r0_suffix.s0 VWFrames.chunk = []

end Host.Ts.Sim.Compose.VWFirst.X0.Sfx
