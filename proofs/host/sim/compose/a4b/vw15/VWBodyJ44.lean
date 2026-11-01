import host.sim.compose.a4b.vw15.VWBodyJ43
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl44 : Conv.NClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl44 (PRE_first_tail_x15_r0_body.cncl43 bodyNcl43)

theorem bodyClean44 : Conv.JClean (⟨19061, 16159, 2709003, 1936⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s431 :=
  PRE_first_tail_x15_r0_body.gjcl44 (PRE_first_tail_x15_r0_body.cjcl43 bodyClean43)

kernel_rfl bodyJsLe44 : Nat.ble PRE_first_tail_x15_r0_body.s427.next PRE_first_tail_x15_r0_body.s431.next = true
kernel_rfl bodyJsList44 : (PRE_first_tail_x15_r0_body.gjh44 ++ PRE_first_tail_x15_r0_body.cl44).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s431.next) PRE_first_tail_x15_r0_body.s433) = true
theorem bodyJs44 : JsHeapAbove PRE_first_tail_x15_r0_body.s431.next PRE_first_tail_x15_r0_body.s433 :=
  JsHeapAbove.glueSite bodyJs43 (Nat.le_of_ble_eq_true bodyJsLe44) PRE_first_tail_x15_r0_body.gjk44 PRE_first_tail_x15_r0_body.gjbd44 PRE_first_tail_x15_r0_body.cheap44 PRE_first_tail_x15_r0_body.zclbd44 bodyJsList44

end Host.Ts.Sim.Compose.VWFirst.VW15
