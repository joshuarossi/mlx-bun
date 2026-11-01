import host.sim.compose.a4b.vw15.VWBodyJ31
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl32 : Conv.NClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s316.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl32 (PRE_first_tail_x15_r0_body.cncl31 bodyNcl31)

theorem bodyClean32 : Conv.JClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s316 :=
  PRE_first_tail_x15_r0_body.gjcl32 (PRE_first_tail_x15_r0_body.cjcl31 bodyClean31)

kernel_rfl bodyJsLe32 : Nat.ble PRE_first_tail_x15_r0_body.s312.next PRE_first_tail_x15_r0_body.s316.next = true
kernel_rfl bodyJsList32 : (PRE_first_tail_x15_r0_body.gjh32 ++ PRE_first_tail_x15_r0_body.cl32).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s316.next) PRE_first_tail_x15_r0_body.s318) = true
theorem bodyJs32 : JsHeapAbove PRE_first_tail_x15_r0_body.s316.next PRE_first_tail_x15_r0_body.s318 :=
  JsHeapAbove.glueSite bodyJs31 (Nat.le_of_ble_eq_true bodyJsLe32) PRE_first_tail_x15_r0_body.gjk32 PRE_first_tail_x15_r0_body.gjbd32 PRE_first_tail_x15_r0_body.cheap32 PRE_first_tail_x15_r0_body.zclbd32 bodyJsList32

end Host.Ts.Sim.Compose.VWFirst.VW15
