import host.sim.compose.a4b.VWBodyBase
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.lin.Table
import host.sim.template.CallGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- The rows this chain's forward serves. -/
def fwdRows : List Row := [first_tail_x5.r0, first_tail_x7.r0, first_tail_x9.r0, first_tail_x11.r0, first_tail_x13.r0, first_tail_x15.r0, first_tail_x17.r0, first_tail_x19.r0, first_tail_x21.r0]

/-- The chain's canonical results and their terms. -/
noncomputable def bodyΘ : List Nat × List SymE := (PRE_first_tail_x15_r0_body.dws, PRE_first_tail_x15_r0_body.drs)

theorem bodyStartEq : (PRE_first_tail_x15_r0_body.s0 : St FF.S) = PRE_first_tail_x15_r0.s41 := bodyStartEqOf PRE_first_tail_x15_r0_body.s0_tok

theorem bodyStartClean : Conv.JClean (⟨18156, 15236, 2673488, 18⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s0 := by
  rw [bodyStartEq]
  exact startClean41

theorem bodyStartJs : JsHeapAbove 2673488 PRE_first_tail_x15_r0_body.s0 := by
  rw [bodyStartEq]
  exact startJs41

theorem bodyInactive0 : (bridgeOf PRE_first_tail_x15_r0_body.s0.ffi).active = false := by
  rw [bodyStartEq]
  exact inactive41

kernel_rfl bodyStart2665 : arrOf PRE_first_tail_x15_r0_body.s0 2665 = []
kernel_rfl bodyStartChunk : arrOf PRE_first_tail_x15_r0_body.s0 VWFrames.chunk = []

end Host.Ts.Sim.Compose.VWFirst.VW15
