import host.sim.compose.a4b.vw15.VWBodyJ190
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl191 : Conv.NClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1839.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl191 (PRE_first_tail_x15_r0_body.cncl190 bodyNcl190)

theorem bodyClean191 : Conv.JClean (⟨21957, 19051, 2824653, 8218⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1839 :=
  PRE_first_tail_x15_r0_body.gjcl191 (PRE_first_tail_x15_r0_body.cjcl190 bodyClean190)

kernel_rfl bodyJsLe191 : Nat.ble PRE_first_tail_x15_r0_body.s1835.next PRE_first_tail_x15_r0_body.s1839.next = true
kernel_rfl bodyJsList191 : (PRE_first_tail_x15_r0_body.gjh191 ++ PRE_first_tail_x15_r0_body.cl191).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1839.next) PRE_first_tail_x15_r0_body.s1841) = true
theorem bodyJs191 : JsHeapAbove PRE_first_tail_x15_r0_body.s1839.next PRE_first_tail_x15_r0_body.s1841 :=
  JsHeapAbove.glueSite bodyJs190 (Nat.le_of_ble_eq_true bodyJsLe191) PRE_first_tail_x15_r0_body.gjk191 PRE_first_tail_x15_r0_body.gjbd191 PRE_first_tail_x15_r0_body.cheap191 PRE_first_tail_x15_r0_body.zclbd191 bodyJsList191

end Host.Ts.Sim.Compose.VWFirst.VW15
