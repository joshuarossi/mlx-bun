import host.sim.compose.a4b.vw15.VWBodyJ63
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B21
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl64 : Conv.NClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s628.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl64 (PRE_first_tail_x15_r0_body.cncl63 bodyNcl63)

theorem bodyClean64 : Conv.JClean (⟨19469, 16566, 2725299, 2816⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s628 :=
  PRE_first_tail_x15_r0_body.gjcl64 (PRE_first_tail_x15_r0_body.cjcl63 bodyClean63)

kernel_rfl bodyJsLe64 : Nat.ble PRE_first_tail_x15_r0_body.s620.next PRE_first_tail_x15_r0_body.s628.next = true
kernel_rfl bodyJsList64 : (PRE_first_tail_x15_r0_body.gjh64 ++ PRE_first_tail_x15_r0_body.cl64).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s628.next) PRE_first_tail_x15_r0_body.s630) = true
theorem bodyJs64 : JsHeapAbove PRE_first_tail_x15_r0_body.s628.next PRE_first_tail_x15_r0_body.s630 :=
  JsHeapAbove.glueSite bodyJs63 (Nat.le_of_ble_eq_true bodyJsLe64) PRE_first_tail_x15_r0_body.gjk64 PRE_first_tail_x15_r0_body.gjbd64 PRE_first_tail_x15_r0_body.cheap64 PRE_first_tail_x15_r0_body.zclbd64 bodyJsList64

end Host.Ts.Sim.Compose.VWFirst.VW15
