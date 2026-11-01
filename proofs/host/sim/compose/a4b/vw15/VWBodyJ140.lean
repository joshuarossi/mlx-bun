import host.sim.compose.a4b.vw15.VWBodyJ139
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl140 : Conv.NClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl140 (PRE_first_tail_x15_r0_body.cncl139 bodyNcl139)

theorem bodyClean140 : Conv.JClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1351 :=
  PRE_first_tail_x15_r0_body.gjcl140 (PRE_first_tail_x15_r0_body.cjcl139 bodyClean139)

kernel_rfl bodyJsLe140 : Nat.ble PRE_first_tail_x15_r0_body.s1347.next PRE_first_tail_x15_r0_body.s1351.next = true
kernel_rfl bodyJsList140 : (PRE_first_tail_x15_r0_body.gjh140 ++ PRE_first_tail_x15_r0_body.cl140).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1351.next) PRE_first_tail_x15_r0_body.s1353) = true
theorem bodyJs140 : JsHeapAbove PRE_first_tail_x15_r0_body.s1351.next PRE_first_tail_x15_r0_body.s1353 :=
  JsHeapAbove.glueSite bodyJs139 (Nat.le_of_ble_eq_true bodyJsLe140) PRE_first_tail_x15_r0_body.gjk140 PRE_first_tail_x15_r0_body.gjbd140 PRE_first_tail_x15_r0_body.cheap140 PRE_first_tail_x15_r0_body.zclbd140 bodyJsList140

end Host.Ts.Sim.Compose.VWFirst.VW15
