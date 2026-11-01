import host.sim.compose.a4b.vw15.VWBodyJ189
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B33
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl190 : Conv.NClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1835.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl190 (PRE_first_tail_x15_r0_body.cncl189 bodyNcl189)

theorem bodyClean190 : Conv.JClean (⟨21950, 19047, 2824365, 8201⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1835 :=
  PRE_first_tail_x15_r0_body.gjcl190 (PRE_first_tail_x15_r0_body.cjcl189 bodyClean189)

kernel_rfl bodyJsLe190 : Nat.ble PRE_first_tail_x15_r0_body.s1827.next PRE_first_tail_x15_r0_body.s1835.next = true
kernel_rfl bodyJsList190 : (PRE_first_tail_x15_r0_body.gjh190 ++ PRE_first_tail_x15_r0_body.cl190).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1835.next) PRE_first_tail_x15_r0_body.s1837) = true
theorem bodyJs190 : JsHeapAbove PRE_first_tail_x15_r0_body.s1835.next PRE_first_tail_x15_r0_body.s1837 :=
  JsHeapAbove.glueSite bodyJs189 (Nat.le_of_ble_eq_true bodyJsLe190) PRE_first_tail_x15_r0_body.gjk190 PRE_first_tail_x15_r0_body.gjbd190 PRE_first_tail_x15_r0_body.cheap190 PRE_first_tail_x15_r0_body.zclbd190 bodyJsList190

end Host.Ts.Sim.Compose.VWFirst.VW15
