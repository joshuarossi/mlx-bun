import host.sim.compose.a4b.vw15.VWBodyJ37
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B19
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl38 : Conv.NClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s373.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl38 (PRE_first_tail_x15_r0_body.cncl37 bodyNcl37)

theorem bodyClean38 : Conv.JClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s373 :=
  PRE_first_tail_x15_r0_body.gjcl38 (PRE_first_tail_x15_r0_body.cjcl37 bodyClean37)

kernel_rfl bodyJsLe38 : Nat.ble PRE_first_tail_x15_r0_body.s369.next PRE_first_tail_x15_r0_body.s373.next = true
kernel_rfl bodyJsList38 : (PRE_first_tail_x15_r0_body.gjh38 ++ PRE_first_tail_x15_r0_body.cl38).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s373.next) PRE_first_tail_x15_r0_body.s375) = true
theorem bodyJs38 : JsHeapAbove PRE_first_tail_x15_r0_body.s373.next PRE_first_tail_x15_r0_body.s375 :=
  JsHeapAbove.glueSite bodyJs37 (Nat.le_of_ble_eq_true bodyJsLe38) PRE_first_tail_x15_r0_body.gjk38 PRE_first_tail_x15_r0_body.gjbd38 PRE_first_tail_x15_r0_body.cheap38 PRE_first_tail_x15_r0_body.zclbd38 bodyJsList38

end Host.Ts.Sim.Compose.VWFirst.VW15
