import host.sim.compose.a4b.vw15.VWBodyJ60
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl61 : Conv.NClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s599.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl61 (PRE_first_tail_x15_r0_body.cncl60 bodyNcl60)

theorem bodyClean61 : Conv.JClean (⟨19412, 16503, 2723043, 2687⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s599 :=
  PRE_first_tail_x15_r0_body.gjcl61 (PRE_first_tail_x15_r0_body.cjcl60 bodyClean60)

kernel_rfl bodyJsLe61 : Nat.ble PRE_first_tail_x15_r0_body.s591.next PRE_first_tail_x15_r0_body.s599.next = true
kernel_rfl bodyJsList61 : (PRE_first_tail_x15_r0_body.gjh61 ++ PRE_first_tail_x15_r0_body.cl61).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s599.next) PRE_first_tail_x15_r0_body.s601) = true
theorem bodyJs61 : JsHeapAbove PRE_first_tail_x15_r0_body.s599.next PRE_first_tail_x15_r0_body.s601 :=
  JsHeapAbove.glueSite bodyJs60 (Nat.le_of_ble_eq_true bodyJsLe61) PRE_first_tail_x15_r0_body.gjk61 PRE_first_tail_x15_r0_body.gjbd61 PRE_first_tail_x15_r0_body.cheap61 PRE_first_tail_x15_r0_body.zclbd61 bodyJsList61

end Host.Ts.Sim.Compose.VWFirst.VW15
