import host.sim.template.a4pre_d1_body.Split261States
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts

host_stream_state D1BodySplit261 0
host_stream_state D1BodySplit261 1

noncomputable def D1BodySplit261.originalS1 : SSrv := ⟨D1BodySplit261.S1.tab, D1BodySized.S261.oracle.drop D1BodySplit261.O.length⟩

kernel_rfl D1BodySplit261.start_exact : D1BodySplit261.s0 = D1BodySized.s261
kernel_rfl D1BodySplit261.start_tab : D1BodySplit261.S0.tab = D1BodySized.S261.tab
kernel_rfl D1BodySplit261.oracle_prefix : D1BodySplit261.O = D1BodySized.S261.oracle.take D1BodySplit261.O.length

end Host.Load.Run.Tpl
