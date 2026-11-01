import host.sim.template.a4pre_d1_body.OutputProjection
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyOutputValue
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

theorem dimensions {M : Map} {C : CSrv} :
    DVSs M C ⟨D1Body.S155.tab, []⟩ [.lit 1, .lit 1, .lit 5120] [1, 1, 5120] :=
  ⟨DVS.lit _ _ _ 1, ⟨DVS.lit _ _ _ 1, ⟨DVS.lit _ _ _ 5120, trivial⟩⟩⟩

end Host.Load.Run.Tpl.D1BodyOutputValue
