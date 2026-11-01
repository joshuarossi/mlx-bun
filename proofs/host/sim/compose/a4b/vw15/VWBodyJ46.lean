import host.sim.compose.a4b.vw15.VWBodyJ45
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl46 : Conv.NClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s455.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl46 (PRE_first_tail_x15_r0_body.cncl45 bodyNcl45)

theorem bodyClean46 : Conv.JClean (⟨19118, 16203, 2711337, 2045⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s455 :=
  PRE_first_tail_x15_r0_body.gjcl46 (PRE_first_tail_x15_r0_body.cjcl45 bodyClean45)

kernel_rfl bodyJsLe46 : Nat.ble PRE_first_tail_x15_r0_body.s447.next PRE_first_tail_x15_r0_body.s455.next = true
kernel_rfl bodyJsList46 : (PRE_first_tail_x15_r0_body.gjh46 ++ PRE_first_tail_x15_r0_body.cl46).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s455.next) PRE_first_tail_x15_r0_body.s457) = true
theorem bodyJs46 : JsHeapAbove PRE_first_tail_x15_r0_body.s455.next PRE_first_tail_x15_r0_body.s457 :=
  JsHeapAbove.glueSite bodyJs45 (Nat.le_of_ble_eq_true bodyJsLe46) PRE_first_tail_x15_r0_body.gjk46 PRE_first_tail_x15_r0_body.gjbd46 PRE_first_tail_x15_r0_body.cheap46 PRE_first_tail_x15_r0_body.zclbd46 bodyJsList46

end Host.Ts.Sim.Compose.VWFirst.VW15
