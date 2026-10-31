import host.sim.compose.a4b.VWBodyBase
import host.sim.template.a4pre_first_tail_x15_r0_body.NCl0
import host.sim.template.a4pre_first_tail_x15_r0_body.GlueN0
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteZ0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl0 : Conv.NClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s14.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl0 PRE_first_tail_x15_r0_body.ncl0

theorem bodyClean0 : Conv.JClean (⟨18189, 15254, 2674897, 83⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s14 :=
  PRE_first_tail_x15_r0_body.gjcl0 bodyStartClean

kernel_rfl bodyJsLe0 : Nat.ble 2673488 PRE_first_tail_x15_r0_body.s14.next = true
kernel_rfl bodyJsList0 : (PRE_first_tail_x15_r0_body.gjh0 ++ PRE_first_tail_x15_r0_body.cl0).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s14.next) PRE_first_tail_x15_r0_body.s16) = true
theorem bodyJs0 : JsHeapAbove PRE_first_tail_x15_r0_body.s14.next PRE_first_tail_x15_r0_body.s16 :=
  JsHeapAbove.glueSite bodyStartJs (Nat.le_of_ble_eq_true bodyJsLe0) PRE_first_tail_x15_r0_body.gjk0 PRE_first_tail_x15_r0_body.gjbd0 PRE_first_tail_x15_r0_body.cheap0 PRE_first_tail_x15_r0_body.zclbd0 bodyJsList0

end Host.Ts.Sim.Compose.VWFirst
