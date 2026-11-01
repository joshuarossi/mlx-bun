import host.sim.compose.a4b.vw15.VWBodyJ46
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl47 : Conv.NClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s459.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl47 (PRE_first_tail_x15_r0_body.cncl46 bodyNcl46)

theorem bodyClean47 : Conv.JClean (⟨19125, 16207, 2711625, 2062⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s459 :=
  PRE_first_tail_x15_r0_body.gjcl47 (PRE_first_tail_x15_r0_body.cjcl46 bodyClean46)

kernel_rfl bodyJsLe47 : Nat.ble PRE_first_tail_x15_r0_body.s455.next PRE_first_tail_x15_r0_body.s459.next = true
kernel_rfl bodyJsList47 : (PRE_first_tail_x15_r0_body.gjh47 ++ PRE_first_tail_x15_r0_body.cl47).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s459.next) PRE_first_tail_x15_r0_body.s461) = true
theorem bodyJs47 : JsHeapAbove PRE_first_tail_x15_r0_body.s459.next PRE_first_tail_x15_r0_body.s461 :=
  JsHeapAbove.glueSite bodyJs46 (Nat.le_of_ble_eq_true bodyJsLe47) PRE_first_tail_x15_r0_body.gjk47 PRE_first_tail_x15_r0_body.gjbd47 PRE_first_tail_x15_r0_body.cheap47 PRE_first_tail_x15_r0_body.zclbd47 bodyJsList47

end Host.Ts.Sim.Compose.VWFirst.VW15
