import host.sim.compose.a4b.vw15.VWBodyJ17
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B17
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl18 : Conv.NClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s189.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl18 (PRE_first_tail_x15_r0_body.cncl17 bodyNcl17)

theorem bodyClean18 : Conv.JClean (⟨18566, 15641, 2689387, 854⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s189 :=
  PRE_first_tail_x15_r0_body.gjcl18 (PRE_first_tail_x15_r0_body.cjcl17 bodyClean17)

kernel_rfl bodyJsLe18 : Nat.ble PRE_first_tail_x15_r0_body.s172.next PRE_first_tail_x15_r0_body.s189.next = true
kernel_rfl bodyJsList18 : (PRE_first_tail_x15_r0_body.gjh18 ++ PRE_first_tail_x15_r0_body.cl18).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s189.next) PRE_first_tail_x15_r0_body.s191) = true
theorem bodyJs18 : JsHeapAbove PRE_first_tail_x15_r0_body.s189.next PRE_first_tail_x15_r0_body.s191 :=
  JsHeapAbove.glueSite bodyJs17 (Nat.le_of_ble_eq_true bodyJsLe18) PRE_first_tail_x15_r0_body.gjk18 PRE_first_tail_x15_r0_body.gjbd18 PRE_first_tail_x15_r0_body.cheap18 PRE_first_tail_x15_r0_body.zclbd18 bodyJsList18

end Host.Ts.Sim.Compose.VWFirst.VW15
