import host.sim.compose.a4b.vw15.VWBodyJ144
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B29
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyNcl145 : Conv.NClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1404.ffi).mlx :=
  PRE_first_tail_x15_r0_body.gncl145 (PRE_first_tail_x15_r0_body.cncl144 bodyNcl144)

theorem bodyClean145 : Conv.JClean (⟨21064, 18162, 2788955, 6278⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1404 :=
  PRE_first_tail_x15_r0_body.gjcl145 (PRE_first_tail_x15_r0_body.cjcl144 bodyClean144)

kernel_rfl bodyJsLe145 : Nat.ble PRE_first_tail_x15_r0_body.s1396.next PRE_first_tail_x15_r0_body.s1404.next = true
kernel_rfl bodyJsList145 : (PRE_first_tail_x15_r0_body.gjh145 ++ PRE_first_tail_x15_r0_body.cl145).all (noBigAtP (jsAboveB PRE_first_tail_x15_r0_body.s1404.next) PRE_first_tail_x15_r0_body.s1406) = true
theorem bodyJs145 : JsHeapAbove PRE_first_tail_x15_r0_body.s1404.next PRE_first_tail_x15_r0_body.s1406 :=
  JsHeapAbove.glueSite bodyJs144 (Nat.le_of_ble_eq_true bodyJsLe145) PRE_first_tail_x15_r0_body.gjk145 PRE_first_tail_x15_r0_body.gjbd145 PRE_first_tail_x15_r0_body.cheap145 PRE_first_tail_x15_r0_body.zclbd145 bodyJsList145

end Host.Ts.Sim.Compose.VWFirst.VW15
