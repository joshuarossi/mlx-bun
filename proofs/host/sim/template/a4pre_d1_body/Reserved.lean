import host.sim.template.a4pre_d1_body.Endpoint
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyReserved
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

kernel_rfl start : D1Call.S1.tab.take 9 = (List.range 9).map SymE.var
kernel_rfl finish : D1Body.S155.tab.take 9 = (List.range 9).map SymE.var
theorem agreement : D1Body.S155.tab.take 9 = D1Call.S1.tab.take 9 := finish.trans start.symm

end Host.Load.Run.Tpl.D1BodyReserved

-- rechecked: literal chunk length
