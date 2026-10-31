import host.sim.template.a4pre_d1_body.Split261States2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts

host_stream_state D1BodySplit261Second 0
host_stream_state D1BodySplit261Second 1

noncomputable def D1BodySplit261.s2 := D1BodySplit261Second.s1
noncomputable def D1BodySplit261.originalS2 : SSrv := ⟨D1BodySplit261Second.S1.tab, D1BodySized.S261.oracle.drop (D1BodySplit261.O.length + D1BodySplit261Second.O.length)⟩

kernel_rfl D1BodySplit261Second.start_exact : D1BodySplit261Second.s0 = D1BodySplit261.s1
kernel_rfl D1BodySplit261Second.start_tab : D1BodySplit261Second.S0.tab = D1BodySplit261.S1.tab
kernel_rfl D1BodySplit261Second.oracle_prefix : D1BodySplit261Second.O = D1BodySplit261.originalS1.oracle.take D1BodySplit261Second.O.length

end Host.Load.Run.Tpl
