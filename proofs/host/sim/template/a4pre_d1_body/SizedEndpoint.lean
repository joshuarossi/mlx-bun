import host.sim.template.a4pre_d1_body.m.B0
import host.sim.template.a4pre_d1_body.Endpoint
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

kernel_rfl D1BodySized.start_exact : D1BodySized.s0 = D1Call.s1
kernel_rfl D1BodySized.tab_exact : D1BodySized.S0.tab = D1Call.S1.tab
kernel_rfl D1BodySized.end_exact : D1BodySized.s155 = D1Body.s155
kernel_rfl D1BodySized.end_tab : D1BodySized.S155.tab = D1Body.S155.tab
kernel_rfl D1BodySized.exactFuel : D1BodySized.ks.foldl (· + ·) 0 = 1541184
kernel_rfl D1BodySized.reportedFuel : D1BodySized.steps = 1541184

end Host.Load.Run.Tpl
