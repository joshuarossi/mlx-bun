import host.sim.template.a4pre_d1_body.m.B11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Prefill

theorem D1BodySized.fullRun {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St} :
    CutStep (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s0 D1BodySized.S0) (D1BodyAdvance.cut NB T tk π K0 M0 y0 D1BodySized.s635 D1BodySized.S635) 1541184 :=
  (((((((((((D1BodySized.group0).trans D1BodySized.group1).trans D1BodySized.group2).trans D1BodySized.group3).trans D1BodySized.group4).trans D1BodySized.group5).trans D1BodySized.group6).trans D1BodySized.group7).trans D1BodySized.group8).trans D1BodySized.group9).trans D1BodySized.group10).trans D1BodySized.group11

end Host.Load.Run.Tpl
