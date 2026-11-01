import host.sim.compose.a4b.vw15.VWBodyJ152
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl153 : Conv.NClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1482.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl153 (PRE_first_tail_x15_r0_body.cncl152 bodyNcl152)

theorem bodyClean153 : Conv.JClean (⟨21225, 18320, 2795500, 6630⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1482 :=
  PRE_first_tail_x15_r0_body.gjcl153 (PRE_first_tail_x15_r0_body.cjcl152 bodyClean152)

kernel_rfl bodyJsLe153 : Nat.ble PRE_first_tail_x15_r0_body.s1466.next PRE_first_tail_x15_r0_body.s1482.next = true
kernel_rfl bodyJsList153 : (PRE_first_tail_x15_r0_body.gjh153 ++ PRE_first_tail_x15_r0_body.cl153).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1482.next) PRE_first_tail_x15_r0_body.s1484) = true
theorem bodyJs153 : JsHeapAbove PRE_first_tail_x15_r0_body.s1482.next PRE_first_tail_x15_r0_body.s1484 :=
  JsHeapAbove.glueSite bodyJs152 (Nat.le_of_ble_eq_true bodyJsLe153) PRE_first_tail_x15_r0_body.gjk153 PRE_first_tail_x15_r0_body.gjbd153 PRE_first_tail_x15_r0_body.cheap153 PRE_first_tail_x15_r0_body.zclbd153 bodyJsList153

end Host.Ts.Sim.Compose.VWFirst.VW15
